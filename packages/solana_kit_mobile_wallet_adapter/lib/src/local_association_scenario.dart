// ignore_for_file: public_member_api_docs
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/pigeon/client_api.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Manages the full lifecycle of a local MWA dApp session.
///
/// Flow:
/// 1. Generate association + ECDH keypairs
/// 2. Pick random port, build Intent URI
/// 3. Launch wallet via [MwaClientHostApi.launchIntent]
/// 4. Connect WebSocket to `ws://localhost:<port>/solana-wallet`
/// 5. Retry with backoff schedule, 30s total timeout
/// 6. Send HELLO_REQ, receive HELLO_RSP
/// 7. Derive shared secret, parse session properties
/// 8. Create [MobileWallet] proxy
/// 9. Clean shutdown on close
class LocalAssociationScenario {
  LocalAssociationScenario({MwaClientHostApi? clientApi, String? baseUri})
    : _clientApi = clientApi ?? MwaClientHostApi(),
      _baseUri = baseUri;

  final MwaClientHostApi _clientApi;
  final String? _baseUri;

  WebSocketChannel? _channel;
  StreamSubscription<Object?>? _subscription;

  late AssociationKeypair _associationKeyPair;
  late EcdhKeypair _ecdhKeyPair;
  Uint8List? _sharedSecret;
  late SessionProperties _sessionProps;

  Completer<Uint8List>? _helloResponseCompleter;
  final Map<int, Completer<Map<String, Object?>>> _pendingResponses =
      <int, Completer<Map<String, Object?>>>{};

  int _nextOutboundSequenceNumber = 1;
  int _lastKnownInboundSequenceNumber = 0;
  bool _closed = false;

  /// Starts the local association session and returns a [MobileWallet] proxy.
  ///
  /// This launches the wallet app via an Android Intent, connects via
  /// WebSocket, performs the HELLO handshake, and creates the encrypted
  /// session.
  Future<MobileWallet> start() async {
    // Step 1: Generate keypairs.
    _associationKeyPair = generateAssociationKeypair();

    // Step 2: Pick random port and build Intent URI.
    final port = getRandomAssociationPort();
    final intentUri = buildLocalAssociationUri(
      _associationKeyPair.publicKey,
      port,
      baseUri: _baseUri,
    );

    // Step 3: Launch wallet app via Intent.
    await _clientApi.launchIntent(intentUri.toString());

    try {
      // Step 4: Connect WebSocket with retry.
      _channel = await _connectWithRetry(port);
      _subscription = _channel!.stream.listen(
        _handleInboundMessage,
        onError: _handleInboundError,
        onDone: _handleInboundDone,
      );

      // Step 5: Perform handshake.
      _helloResponseCompleter = Completer<Uint8List>();
      _sendHelloReq();

      final helloRsp = await _helloResponseCompleter!.future.timeout(
        const Duration(milliseconds: mwaConnectionTimeoutMs),
        onTimeout: () => throw SolanaError(SolanaErrorCode.mwaSessionTimeout),
      );

      // Step 6: Parse HELLO_RSP and derive shared secret.
      final result = parseHelloRsp(helloRsp, _associationKeyPair, _ecdhKeyPair);
      _sharedSecret = result.sharedSecret;

      // Step 7: Parse session properties if present.
      if (result.encryptedSessionProps != null) {
        _assertAndAdvanceInboundSequence(result.encryptedSessionProps!);
        _sessionProps = parseSessionProps(
          result.encryptedSessionProps!,
          _sharedSecret!,
        );
      } else {
        _sessionProps = const SessionProperties(
          protocolVersion: ProtocolVersion.legacy,
        );
      }

      // Step 8: Create wallet proxy.
      return createMobileWalletProxy(_sendRequest, _sessionProps);
    } on Object {
      await close();
      rethrow;
    }
  }

  /// Closes the session and cleans up resources.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;

    final error = SolanaError(SolanaErrorCode.mwaSessionClosed);
    _failPendingOperations(error);

    await _subscription?.cancel();
    _subscription = null;

    await _channel?.sink.close();
    _channel = null;
  }

  /// Sends an encrypted JSON-RPC request and returns the decrypted response.
  Future<Map<String, Object?>> _sendRequest(
    String method,
    Map<String, Object?> params,
  ) async {
    if (_closed || _channel == null || _sharedSecret == null) {
      throw SolanaError(SolanaErrorCode.mwaSessionClosed);
    }

    final requestId = _nextOutboundSequenceNumber++;
    final encrypted = encryptJsonRpcRequest(
      requestId,
      method,
      params,
      _sharedSecret!,
    );

    final responseCompleter = Completer<Map<String, Object?>>();
    _pendingResponses[requestId] = responseCompleter;
    _channel!.sink.add(encrypted);

    try {
      return await responseCompleter.future.timeout(
        const Duration(milliseconds: mwaConnectionTimeoutMs),
        onTimeout: () => throw SolanaError(SolanaErrorCode.mwaSessionTimeout),
      );
    } finally {
      _pendingResponses.remove(requestId);
    }
  }

  void _sendHelloReq() {
    _ecdhKeyPair = generateEcdhKeypair();
    final helloReq = createHelloReq(_ecdhKeyPair, _associationKeyPair);
    _channel?.sink.add(helloReq);
  }

  void _handleInboundMessage(Object? message) {
    if (_closed) return;

    if (message is! List<int>) {
      _handleInboundError(
        SolanaError(SolanaErrorCode.mwaHandshakeFailed, {
          'reason': 'Unexpected non-binary WebSocket payload type',
        }),
      );
      return;
    }

    final payload = message is Uint8List
        ? message
        : Uint8List.fromList(message);

    try {
      if (_sharedSecret == null) {
        _handleHandshakeMessage(payload);
      } else {
        _handleEncryptedMessage(payload);
      }
    } on Object catch (error) {
      _handleInboundError(error);
    }
  }

  void _handleHandshakeMessage(Uint8List payload) {
    final helloCompleter = _helloResponseCompleter;
    if (helloCompleter == null || helloCompleter.isCompleted) {
      return;
    }

    // APP_PING (empty payload) can arrive before HELLO_RSP; resend HELLO_REQ.
    if (payload.isEmpty) {
      _sendHelloReq();
      return;
    }

    helloCompleter.complete(payload);
  }

  void _handleEncryptedMessage(Uint8List payload) {
    _assertAndAdvanceInboundSequence(payload);

    final decoded = _decryptJsonRpcMessage(payload, _sharedSecret!);
    final idValue = decoded['id'];
    final requestId = idValue is num ? idValue.toInt() : null;
    if (requestId == null) {
      throw SolanaError(SolanaErrorCode.mwaHandshakeFailed, {
        'reason': 'Missing or invalid JSON-RPC id in wallet response',
      });
    }

    final pending = _pendingResponses.remove(requestId);
    if (pending == null || pending.isCompleted) {
      return;
    }

    if (decoded.containsKey('error')) {
      final errorJson = decoded['error'];
      if (errorJson is! Map) {
        pending.completeError(
          SolanaError(SolanaErrorCode.mwaHandshakeFailed, {
            'reason': 'Invalid JSON-RPC error payload',
          }),
        );
        return;
      }
      final typedError = errorJson.cast<Object?, Object?>();
      pending.completeError(
        MwaProtocolError(
          jsonRpcMessageId: requestId,
          code: (typedError['code'] as num?)?.toInt() ?? -32603,
          message:
              typedError['message']?.toString() ??
              'Unknown wallet protocol error',
          data: typedError['data'],
        ),
      );
      return;
    }

    final result = decoded['result'];
    if (result is! Map) {
      pending.completeError(
        SolanaError(SolanaErrorCode.mwaHandshakeFailed, {
          'reason': 'Missing or invalid JSON-RPC result payload',
        }),
      );
      return;
    }

    pending.complete(result.cast<String, Object?>());
  }

  Map<String, Object?> _decryptJsonRpcMessage(
    Uint8List message,
    Uint8List sharedSecret,
  ) {
    final decrypted = decryptMessage(message, sharedSecret);
    final jsonRpcMessage = json.decode(decrypted.plaintext);
    if (jsonRpcMessage is! Map) {
      throw SolanaError(SolanaErrorCode.mwaHandshakeFailed, {
        'reason': 'Wallet response is not a JSON object',
      });
    }
    return jsonRpcMessage.cast<String, Object?>();
  }

  void _assertAndAdvanceInboundSequence(Uint8List message) {
    if (message.length < mwaSequenceNumberBytes) {
      throw SolanaError(SolanaErrorCode.mwaInvalidSequenceNumber, {
        'reason': 'Encrypted message shorter than sequence number prefix',
        'actualLength': message.length,
      });
    }

    final sequenceNumber = ByteData.sublistView(
      message,
      0,
      mwaSequenceNumberBytes,
    ).getUint32(0);
    final expectedSequence = _lastKnownInboundSequenceNumber + 1;
    if (sequenceNumber != expectedSequence) {
      throw SolanaError(SolanaErrorCode.mwaInvalidSequenceNumber, {
        'expected': expectedSequence,
        'actual': sequenceNumber,
      });
    }
    _lastKnownInboundSequenceNumber = sequenceNumber;
  }

  void _handleInboundError(Object error) {
    if (_closed) return;
    _closed = true;

    _failPendingOperations(error);

    unawaited(_subscription?.cancel());
    _subscription = null;

    unawaited(_channel?.sink.close());
    _channel = null;
  }

  void _handleInboundDone() {
    if (_closed) return;
    _handleInboundError(SolanaError(SolanaErrorCode.mwaSessionClosed));
  }

  void _failPendingOperations(Object error) {
    final helloCompleter = _helloResponseCompleter;
    if (helloCompleter != null && !helloCompleter.isCompleted) {
      helloCompleter.completeError(error);
    }
    _helloResponseCompleter = null;

    for (final completer in _pendingResponses.values) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }
    _pendingResponses.clear();
  }

  /// Connects to the wallet's WebSocket server with retry logic.
  Future<WebSocketChannel> _connectWithRetry(int port) async {
    final uri = Uri.parse('ws://localhost:$port$mwaLocalWebSocketPath');

    final deadline = DateTime.now().add(
      const Duration(milliseconds: mwaConnectionTimeoutMs),
    );

    var attempt = 0;
    while (DateTime.now().isBefore(deadline)) {
      try {
        final channel = WebSocketChannel.connect(
          uri,
          protocols: [mwaWebSocketProtocolBinary],
        );

        // Wait for the connection to be established.
        await channel.ready;
        return channel;
      } on Object {
        // Get retry delay from schedule, or use last value.
        final delay = attempt < mwaRetryDelayScheduleMs.length
            ? mwaRetryDelayScheduleMs[attempt]
            : mwaRetryDelayScheduleMs.last;
        attempt++;

        await Future<void>.delayed(Duration(milliseconds: delay));
      }
    }

    throw SolanaError(SolanaErrorCode.mwaSessionTimeout);
  }
}
