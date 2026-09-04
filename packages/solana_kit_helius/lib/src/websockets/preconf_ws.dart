import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Base WebSocket URL for the Helius Pre Confirmations endpoint.
///
/// Pre Confirmations are served from the Gatekeeper endpoint
/// (`wss://beta.helius-rpc.com`). Despite the `beta` host name this is **not** a
/// beta product — it is where Pre Confirmations launch during the Gatekeeper
/// migration. The API key is appended as a query parameter.
String preconfWebsocketUrl(String apiKey) => Uri(
  scheme: 'wss',
  host: 'beta.helius-rpc.com',
  path: '/',
  queryParameters: {'api-key': apiKey},
).toString();

/// The wire schema version this client understands. Frames carrying any other
/// version in byte 0 are dropped rather than misparsed.
const preconfWireVersion = 1;

/// Header length before the bincode payload:
/// `version(1) + slot(8) + transaction_index(8) + status(1)`.
const preconfHeadLength = 18;

/// Landed status of a pre-confirmed transaction.
///
/// A pre-confirmation is an early signal; `PreconfNotification.status`
/// reflects the scheduler's current view and may still change before the
/// transaction is finalized.
class PreconfStatus {
  /// A failed transaction.
  static const failed = 0;

  /// A successful transaction.
  static const success = 1;

  /// An unknown status.
  static const unknown = 2;
}

/// Decode the on-the-wire `status` byte; any out-of-range value maps to
/// [PreconfStatus.unknown].
int _decodeStatus(int byte) => switch (byte) {
  0 => PreconfStatus.failed,
  1 => PreconfStatus.success,
  _ => PreconfStatus.unknown,
};

/// A single decoded Pre Confirmations notification.
///
/// A pre-confirmation is an **early signal, not a guarantee** — a streamed
/// transaction may still fail to land.
class PreconfNotification {
  /// Creates a pre-confirmation notification.
  const PreconfNotification({
    required this.version,
    required this.slot,
    required this.transactionIndex,
    required this.status,
    required this.transaction,
    required this.transactionBytes,
  });

  /// The wire schema version (byte 0). Currently always [preconfWireVersion].
  final int version;

  /// The slot the scheduled transaction targets.
  final int slot;

  /// The transaction's index within the scheduled batch for that slot.
  final int transactionIndex;

  /// The reported landed status of the transaction.
  final int status;

  /// The decoded transaction (`{ messageBytes, signatures }`), deserialized
  /// from the bincode `VersionedTransaction` payload.
  final Transaction transaction;

  /// The raw `bincode(VersionedTransaction)` bytes, exposed alongside the
  /// decoded form.
  final Uint8List transactionBytes;
}

/// Decodes a raw Pre Confirmations binary frame into a [PreconfNotification].
///
/// Layout:
/// `version:u8 | slot:u64_le | transaction_index:u64_le | status:u8 | bincode(VersionedTransaction)`.
///
/// The leading `version` byte is checked first; a frame with an unrecognized
/// version throws so future format changes fail loudly instead of being
/// silently misparsed.
///
/// Throws if the frame is shorter than the 18-byte header (+ at least 1
/// payload byte), the version is unknown, or the transaction payload fails to
/// decode.
PreconfNotification decodePreconfFrame(Uint8List bytes) {
  if (bytes.length < preconfHeadLength + 1) {
    throw StateError(
      'preconf frame too short: ${bytes.length} bytes (need > '
      '$preconfHeadLength)',
    );
  }

  final version = bytes[0];
  if (version != preconfWireVersion) {
    throw StateError(
      'unsupported preconf wire version $version (this client understands '
      '$preconfWireVersion)',
    );
  }

  final byteData = ByteData.sublistView(bytes);
  final slot = byteData.getUint64(1, Endian.little);
  final transactionIndex = byteData.getUint64(9, Endian.little);
  final status = _decodeStatus(bytes[17]);
  final transactionBytes = Uint8List.sublistView(bytes, preconfHeadLength);
  final transaction = getTransactionDecoder().decode(transactionBytes);

  return PreconfNotification(
    version: version,
    slot: slot,
    transactionIndex: transactionIndex,
    status: status,
    transaction: transaction,
    transactionBytes: transactionBytes,
  );
}

/// An active Pre Confirmations subscription.
class PreconfSubscription {
  /// Creates a pre-confirmation subscription.
  PreconfSubscription({
    required this.subscriptionId,
    required this.notifications,
    required this.unsubscribe,
  });

  /// The server-assigned subscription ID.
  final int subscriptionId;

  /// Stream of decoded notifications.
  final Stream<PreconfNotification> notifications;

  /// Sends a `preconfUnsubscribe` and stops receiving notifications.
  final Future<bool> Function() unsubscribe;
}

/// Client for Helius Pre Confirmations subscriptions.
///
/// Pre Confirmations are Helius's lowest-latency transaction stream: scheduled
/// transactions are delivered over WebSocket **before** they are shredded.
///
/// > A pre-confirmation is an **early signal, not a guarantee** — a streamed
/// > transaction may still fail to land.
///
/// Coverage is **not continuous**: the stream scales with the share of stake
/// forwarding scheduled transactions to Helius, so expect gaps — not every
/// slot or transaction will appear.
///
/// Pricing is **credit-based** (10 credits per notification message), the same
/// model as other Helius WebSocket subscriptions. It is **not** tip-based.
class PreconfWsClient {
  /// Creates a Pre Confirmations client for the given API key.
  ///
  /// [channelFactory] optionally supplies the connector used when [channel]
  /// is omitted. Connection failures reject pending calls without exposing
  /// the credential-bearing endpoint.
  PreconfWsClient({
    required String apiKey,
    WebSocketChannel? channel,
    WebSocketChannel Function(Uri)? channelFactory,
  }) : _channel =
           channel ??
           (channelFactory ?? WebSocketChannel.connect)(
             Uri.parse(preconfWebsocketUrl(apiKey)),
           ) {
    _streamSubscription = _channel.stream.listen(
      _onMessage,
      onError: (Object _) => _terminate(
        StateError('preconf WebSocket connection failed'),
      ),
      onDone: () =>
          _terminate(StateError('preconf WebSocket connection closed')),
    );
    unawaited(
      _channel.ready.then(
        (_) {
          if (!_ready.isCompleted) _ready.complete();
        },
        onError: (Object _) => _terminate(
          StateError('preconf WebSocket connection failed'),
        ),
      ),
    );
  }

  final WebSocketChannel _channel;
  final _ready = Completer<void>();
  final _pending = <int, Completer<Object?>>{};
  final _controllers = <int, StreamController<PreconfNotification>>{};
  int _nextId = 1;
  StateError? _failure;
  bool _closed = false;
  StreamSubscription<Object?>? _streamSubscription;

  void _terminate(StateError error, {bool notify = true}) {
    if (_failure != null) return;
    _failure = error;
    if (!_ready.isCompleted) _ready.complete();
    for (final completer in _pending.values) {
      completer.completeError(error);
    }
    _pending.clear();
    for (final controller in _controllers.values) {
      if (notify) controller.addError(error);
      unawaited(controller.close());
    }
    _controllers.clear();
    close();
  }

  void _onMessage(Object? message) {
    try {
      _handleMessage(message);
    } on Object {
      _terminate(StateError('Invalid preconf WebSocket message'));
    }
  }

  void _handleMessage(Object? message) {
    if (message is List<int>) {
      // Binary frames carry pre-confirmation notifications.
      final notification = decodePreconfFrame(Uint8List.fromList(message));
      for (final controller in _controllers.values) {
        controller.add(notification);
      }
      return;
    }
    if (message is String) {
      // Text frames are JSON-RPC 2.0 subscribe/unsubscribe responses.
      final response = jsonDecode(message) as Map<String, Object?>;
      final id = response['id'];
      if (id is int) {
        final completer = _pending.remove(id);
        if (completer != null) {
          final error = response['error'];
          if (error != null) {
            completer.completeError(StateError('preconf RPC error: $error'));
          } else {
            completer.complete(response['result']);
          }
        }
      }
    }
  }

  /// Subscribes to Pre Confirmations. Takes no filter parameters — streams
  /// **all** scheduled transactions.
  ///
  /// Returns a [PreconfSubscription] whose [PreconfSubscription.notifications]
  /// stream yields decoded [PreconfNotification]s.
  Future<PreconfSubscription> preconfSubscribe() async {
    final result = await _call('preconfSubscribe', const <Object?>[]);
    final subscriptionId = result! as int;

    final controller = StreamController<PreconfNotification>.broadcast();
    _controllers[subscriptionId] = controller;

    return PreconfSubscription(
      subscriptionId: subscriptionId,
      notifications: controller.stream,
      unsubscribe: () => preconfUnsubscribe(subscriptionId),
    );
  }

  /// Unsubscribes by server-assigned subscription ID.
  Future<bool> preconfUnsubscribe(int subscriptionId) async {
    final result = await _call('preconfUnsubscribe', [subscriptionId]);
    unawaited(_controllers.remove(subscriptionId)?.close());
    return result == true;
  }

  Future<Object?> _call(String method, List<Object?> params) async {
    await _ready.future;
    final failure = _failure;
    if (failure != null) throw failure;

    final id = _nextId++;
    final completer = Completer<Object?>();
    _pending[id] = completer;
    try {
      _channel.sink.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': id,
          'method': method,
          'params': params,
        }),
      );
    } on Object {
      _pending.remove(id);
      final error = StateError('preconf WebSocket send failed');
      _terminate(error);
      throw error;
    }
    return completer.future;
  }

  /// Manually closes the underlying WebSocket.
  ///
  /// Pending requests fail and notification streams close. Safe to repeat,
  /// including before the connection is ready.
  void close() {
    if (_closed) return;
    _closed = true;
    _terminate(StateError('preconf WebSocket client is closed'), notify: false);
    unawaited(_closeTransport());
  }

  Future<void> _closeTransport() async {
    try {
      await _streamSubscription?.cancel();
      await _channel.sink.close();
    } on Object {
      // Pending calls already have a credential-free terminal error.
    }
  }
}
