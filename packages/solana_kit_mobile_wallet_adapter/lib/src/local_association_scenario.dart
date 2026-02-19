import 'dart:async';
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
  Uint8List? _sharedSecret;
  late SessionProperties _sessionProps;
  int _nextOutboundSequenceNumber = 1;
  bool _closed = false;

  /// Starts the local association session and returns a [MobileWallet] proxy.
  ///
  /// This launches the wallet app via an Android Intent, connects via
  /// WebSocket, performs the HELLO handshake, and creates the encrypted
  /// session.
  Future<MobileWallet> start() async {
    // Step 1: Generate keypairs.
    final associationKeyPair = generateAssociationKeypair();
    final ecdhKeyPair = generateEcdhKeypair();

    // Step 2: Pick random port and build Intent URI.
    final port = getRandomAssociationPort();
    final intentUri = buildLocalAssociationUri(
      associationKeyPair.publicKey,
      port,
      baseUri: _baseUri,
    );

    // Step 3: Launch wallet app via Intent.
    await _clientApi.launchIntent(intentUri.toString());

    // Step 4: Connect WebSocket with retry.
    _channel = await _connectWithRetry(port);

    // Step 5: Perform handshake.
    final helloReq = createHelloReq(ecdhKeyPair, associationKeyPair);

    // Listen for the first response.
    final completer = Completer<Uint8List>();
    final subscription = _channel!.stream.listen(
      (message) {
        if (!completer.isCompleted) {
          if (message is List<int>) {
            completer.complete(Uint8List.fromList(message));
          }
        }
      },
      onError: (Object error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError(
            SolanaError(SolanaErrorCode.mwaSessionClosed),
          );
        }
      },
    );

    // Send HELLO_REQ.
    _channel!.sink.add(helloReq);

    // Wait for HELLO_RSP (handle APP_PING: empty message means resend).
    Uint8List helloRsp;
    try {
      helloRsp = await completer.future.timeout(
        const Duration(milliseconds: mwaConnectionTimeoutMs),
        onTimeout: () => throw SolanaError(SolanaErrorCode.mwaSessionTimeout),
      );
    } finally {
      await subscription.cancel();
    }

    // Handle APP_PING (empty response).
    if (helloRsp.isEmpty) {
      // Resend HELLO_REQ and wait again.
      final retryCompleter = Completer<Uint8List>();
      final retrySubscription = _channel!.stream.listen((message) {
        if (!retryCompleter.isCompleted && message is List<int>) {
          retryCompleter.complete(Uint8List.fromList(message));
        }
      });

      _channel!.sink.add(helloReq);

      try {
        helloRsp = await retryCompleter.future.timeout(
          const Duration(milliseconds: mwaConnectionTimeoutMs),
          onTimeout: () => throw SolanaError(SolanaErrorCode.mwaSessionTimeout),
        );
      } finally {
        await retrySubscription.cancel();
      }
    }

    // Step 6: Parse HELLO_RSP and derive shared secret.
    final result = parseHelloRsp(helloRsp, associationKeyPair, ecdhKeyPair);
    _sharedSecret = result.sharedSecret;

    // Step 7: Parse session properties if present.
    if (result.encryptedSessionProps != null) {
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
  }

  /// Closes the session and cleans up resources.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _channel?.sink.close();
  }

  /// Sends an encrypted JSON-RPC request and returns the decrypted response.
  Future<Map<String, Object?>> _sendRequest(
    String method,
    Map<String, Object?> params,
  ) async {
    if (_closed || _channel == null || _sharedSecret == null) {
      throw SolanaError(SolanaErrorCode.mwaSessionClosed);
    }

    final sequenceNumber = _nextOutboundSequenceNumber++;

    final encrypted = encryptJsonRpcRequest(
      sequenceNumber,
      method,
      params,
      _sharedSecret!,
    );

    _channel!.sink.add(encrypted);

    // Wait for the response.
    final completer = Completer<Uint8List>();
    final subscription = _channel!.stream.listen(
      (message) {
        if (!completer.isCompleted && message is List<int>) {
          completer.complete(Uint8List.fromList(message));
        }
      },
      onError: (Object error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError(
            SolanaError(SolanaErrorCode.mwaSessionClosed),
          );
        }
      },
    );

    try {
      final responseBytes = await completer.future.timeout(
        const Duration(milliseconds: mwaConnectionTimeoutMs),
        onTimeout: () => throw SolanaError(SolanaErrorCode.mwaSessionTimeout),
      );

      return decryptJsonRpcResponse(responseBytes, _sharedSecret!);
    } finally {
      await subscription.cancel();
    }
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
