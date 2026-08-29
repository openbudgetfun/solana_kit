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
String preconfWebsocketUrl(String apiKey) =>
    'wss://beta.helius-rpc.com/?api-key=$apiKey';

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
  PreconfWsClient({required String apiKey, WebSocketChannel? channel})
    : _channel =
          channel ??
          WebSocketChannel.connect(Uri.parse(preconfWebsocketUrl(apiKey)));

  final WebSocketChannel _channel;
  final _pending = <int, Completer<Object?>>{};
  final _controllers = <int, StreamController<PreconfNotification>>{};
  int _nextId = 1;
  StreamSubscription<Object?>? _streamSubscription;

  StreamSubscription<Object?> _ensureListener() {
    return _streamSubscription ??= _channel.stream.listen(_onMessage);
  }

  void _onMessage(Object? message) {
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
    _ensureListener();

    final id = _nextId++;
    final completer = Completer<Object?>();
    _pending[id] = completer;

    _channel.sink.add(
      jsonEncode({
        'jsonrpc': '2.0',
        'id': id,
        'method': 'preconfSubscribe',
        'params': const <Object?>[],
      }),
    );

    final result = await completer.future;
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
    _ensureListener();

    final id = _nextId++;
    final completer = Completer<Object?>();
    _pending[id] = completer;

    _channel.sink.add(
      jsonEncode({
        'jsonrpc': '2.0',
        'id': id,
        'method': 'preconfUnsubscribe',
        'params': [subscriptionId],
      }),
    );

    final result = await completer.future;
    unawaited(_controllers.remove(subscriptionId)?.close());
    return result == true;
  }

  /// Manually closes the underlying WebSocket.
  void close() {
    _streamSubscription?.cancel();
    _channel.sink.close();
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}
