// ignore_for_file: public_member_api_docs
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/kit_mobile_wallet.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Result of starting a remote association session.
class RemoteAssociationResult {
  const RemoteAssociationResult({
    required this.associationUri,
    required this.wallet,
    required this.close,
  });

  /// The association URI to display to the user (e.g. as a QR code).
  final Uri associationUri;

  /// A future that resolves to the connected wallet proxy once the remote
  /// wallet connects.
  final Future<KitMobileWallet> wallet;

  /// Closes the remote session and cleans up resources.
  final void Function() close;
}

/// Starts a remote association session via a WebSocket reflector.
///
/// The reflector server relays messages between the dApp and wallet when
/// they are not on the same device.
///
/// The returned [RemoteAssociationResult.associationUri] includes the actual
/// reflector ID assigned by the server, and can be displayed directly as a QR
/// code.
Future<RemoteAssociationResult> startRemoteScenario(
  RemoteWalletAssociationConfig config,
) async {
  final session = _RemoteAssociationSession(config);
  return session.start();
}

enum _RemoteProtocolEncoding { binary, base64 }

enum _RemoteState { connecting, reflectorIdReceived, helloReqSent, connected }

class _RemoteAssociationSession {
  _RemoteAssociationSession(this._config)
    : _associationKeyPair = generateAssociationKeypair();

  final RemoteWalletAssociationConfig _config;
  final AssociationKeypair _associationKeyPair;

  WebSocketChannel? _channel;
  StreamSubscription<Object?>? _subscription;

  _RemoteProtocolEncoding _encoding = _RemoteProtocolEncoding.binary;
  _RemoteState _state = _RemoteState.connecting;

  late EcdhKeypair _ecdhKeyPair;
  Uint8List? _sharedSecret;
  SessionProperties _sessionProps = const SessionProperties(
    protocolVersion: ProtocolVersion.legacy,
  );

  final Completer<Uint8List> _reflectorIdCompleter = Completer<Uint8List>();
  final Completer<KitMobileWallet> _walletCompleter =
      Completer<KitMobileWallet>();
  final Map<int, Completer<Map<String, Object?>>> _pendingResponses =
      <int, Completer<Map<String, Object?>>>{};

  int _nextOutboundSequenceNumber = 1;
  int _lastKnownInboundSequenceNumber = 0;
  bool _closed = false;

  Future<RemoteAssociationResult> start() async {
    try {
      _channel = await _connectWithRetry();
      _encoding = _channel!.protocol == mwaWebSocketProtocolBase64
          ? _RemoteProtocolEncoding.base64
          : _RemoteProtocolEncoding.binary;

      _subscription = _channel!.stream.listen(
        _handleInboundMessage,
        onError: _handleInboundError,
        onDone: _handleInboundDone,
      );

      final reflectorIdBytes = await _reflectorIdCompleter.future.timeout(
        const Duration(milliseconds: mwaConnectionTimeoutMs),
        onTimeout: () => throw SolanaError(SolanaErrorCode.mwaSessionTimeout),
      );

      final associationUri = buildRemoteAssociationUri(
        _associationKeyPair.publicKey,
        _config.reflectorHost,
        reflectorIdBytes,
        baseUri: _config.baseUri,
      );

      return RemoteAssociationResult(
        associationUri: associationUri,
        wallet: _walletCompleter.future,
        close: () {
          unawaited(close());
        },
      );
    } on Object {
      await close();
      rethrow;
    }
  }

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

  void _handleInboundMessage(Object? message) {
    if (_closed) return;

    try {
      final payload = _decodeInboundPayload(message);
      switch (_state) {
        case _RemoteState.connecting:
          _handleReflectorIdMessage(payload);
        case _RemoteState.reflectorIdReceived:
          _handleReflectionEstablishedMessage(payload);
        case _RemoteState.helloReqSent:
          _handleHelloResponse(payload);
        case _RemoteState.connected:
          _handleEncryptedMessage(payload);
      }
    } on Object catch (error) {
      _handleInboundError(error);
    }
  }

  void _handleReflectorIdMessage(Uint8List payload) {
    if (payload.isEmpty) {
      throw SolanaError(SolanaErrorCode.mwaHandshakeFailed, {
        'reason': 'Expected reflector ID message before reflection ping',
      });
    }

    final reflectorId = _extractReflectorId(payload);
    _state = _RemoteState.reflectorIdReceived;

    if (!_reflectorIdCompleter.isCompleted) {
      _reflectorIdCompleter.complete(reflectorId);
    }
  }

  void _handleReflectionEstablishedMessage(Uint8List payload) {
    // Reflector sends an empty message when the wallet has joined and
    // reflection is active.
    if (payload.isNotEmpty) {
      throw SolanaError(SolanaErrorCode.mwaHandshakeFailed, {
        'reason': 'Expected empty reflection-established message',
      });
    }

    _sendHelloReq();
    _state = _RemoteState.helloReqSent;
  }

  void _handleHelloResponse(Uint8List payload) {
    if (payload.isEmpty) {
      throw SolanaError(SolanaErrorCode.mwaInvalidHelloResponse, {
        'reason': 'Received empty HELLO_RSP payload',
      });
    }

    final result = parseHelloRsp(payload, _associationKeyPair, _ecdhKeyPair);
    _sharedSecret = result.sharedSecret;

    if (result.encryptedSessionProps != null) {
      _assertAndAdvanceInboundSequence(result.encryptedSessionProps!);
      _sessionProps = parseSessionProps(
        result.encryptedSessionProps!,
        _sharedSecret!,
      );
    }

    _state = _RemoteState.connected;

    if (!_walletCompleter.isCompleted) {
      final wallet = createMobileWalletProxy(_sendRequest, _sessionProps);
      _walletCompleter.complete(wrapWithKitApi(wallet));
    }
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

    _sendEncoded(encrypted);

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
    _sendEncoded(helloReq);
  }

  void _sendEncoded(Uint8List message) {
    if (_encoding == _RemoteProtocolEncoding.base64) {
      _channel?.sink.add(base64.encode(message));
    } else {
      _channel?.sink.add(message);
    }
  }

  Uint8List _decodeInboundPayload(Object? message) {
    if (message is Uint8List) {
      return message;
    }
    if (message is List<int>) {
      return Uint8List.fromList(message);
    }
    if (message is String) {
      return Uint8List.fromList(base64.decode(message.trim()));
    }

    throw SolanaError(SolanaErrorCode.mwaHandshakeFailed, {
      'reason': 'Unexpected WebSocket payload type',
      'type': message.runtimeType.toString(),
    });
  }

  Uint8List _extractReflectorId(Uint8List payload) {
    final (length, offset) = _decodeVarUintLength(payload);
    if (length <= 0 || offset + length > payload.length) {
      throw SolanaError(SolanaErrorCode.mwaHandshakeFailed, {
        'reason': 'Malformed reflector ID payload',
        'payloadLength': payload.length,
        'declaredLength': length,
        'offset': offset,
      });
    }

    return payload.sublist(offset, offset + length);
  }

  (int, int) _decodeVarUintLength(Uint8List payload) {
    var value = 0;
    var shift = 0;
    var offset = 0;

    while (true) {
      if (offset >= payload.length || offset >= 10) {
        throw SolanaError(SolanaErrorCode.mwaHandshakeFailed, {
          'reason': 'Failed to decode reflector ID varint length',
        });
      }

      final byte = payload[offset];
      offset += 1;

      value |= (byte & 0x7f) << shift;
      if ((byte & 0x80) == 0) {
        break;
      }

      shift += 7;
    }

    return (value, offset);
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
    if (!_reflectorIdCompleter.isCompleted) {
      _reflectorIdCompleter.completeError(error);
    }

    if (!_walletCompleter.isCompleted) {
      _walletCompleter.completeError(error);
    }

    for (final completer in _pendingResponses.values) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }
    _pendingResponses.clear();
  }

  Future<WebSocketChannel> _connectWithRetry() async {
    final uri = Uri.parse('wss://${_config.reflectorHost}/reflect');

    final deadline = DateTime.now().add(
      const Duration(milliseconds: mwaConnectionTimeoutMs),
    );

    var attempt = 0;
    while (DateTime.now().isBefore(deadline)) {
      try {
        final channel = WebSocketChannel.connect(
          uri,
          protocols: [mwaWebSocketProtocolBinary, mwaWebSocketProtocolBase64],
        );

        await channel.ready;
        return channel;
      } on Object {
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
