import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:solana_kit_helius/src/internal/http_request.dart';
import 'package:solana_kit_helius/src/internal/redact_url.dart';
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

/// The wire schema version this client understands for transaction frames.
/// Frames carrying any other version in byte 0 are handled as slot frames or
/// dropped rather than misparsed.
const preconfWireVersion = 1;

/// The wire schema version of slot (bank lifecycle) frames.
const preconfSlotWireVersion = 128;

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

/// Slot leader's bank lifecycle.
class PreconfSlotStatus {
  /// The slot started.
  static const bankCreated = 0;

  /// The slot ended.
  static const bankFrozen = 1;
}

/// Preconfirmation source.
enum PreconfSource {
  /// Helius validators.
  helius('helius'),

  /// BAM validators.
  bam('bam');

  const PreconfSource(this.value);

  /// Wire value.
  final String value;

  /// Serializes this value to its wire string.
  String toJson() => value;
}

/// Base type for Pre Confirmations notifications.
///
/// Narrow on [type] before reading transaction or slot fields.
sealed class PreconfEvent {
  const PreconfEvent();

  /// The notification kind: `transaction` or `slot`.
  String get type;
}

/// Decode the on-the-wire `status` byte; any out-of-range value maps to
/// [PreconfStatus.unknown].
int _decodeStatus(int byte) => switch (byte) {
  0 => PreconfStatus.failed,
  1 => PreconfStatus.success,
  _ => PreconfStatus.unknown,
};

/// A single decoded Pre Confirmations transaction notification.
///
/// A pre-confirmation is an **early signal, not a guarantee** — a streamed
/// transaction may still fail to land.
class PreconfNotification extends PreconfEvent {
  /// Creates a pre-confirmation notification.
  const PreconfNotification({
    required this.version,
    required this.slot,
    required this.transactionIndex,
    required this.status,
    required this.transaction,
    required this.transactionBytes,
  });

  @override
  String get type => 'transaction';

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

/// A leader-bank lifecycle event for a slot.
class PreconfSlotNotification extends PreconfEvent {
  /// Creates a slot notification.
  const PreconfSlotNotification({
    required this.slot,
    required this.status,
  });

  @override
  String get type => 'slot';

  /// The wire schema version (byte 0): [preconfSlotWireVersion].
  int get version => preconfSlotWireVersion;

  /// The slot whose leader bank was created or frozen.
  final int slot;

  /// [PreconfSlotStatus.bankCreated] or [PreconfSlotStatus.bankFrozen].
  final int status;
}

/// A JSON-RPC error from Pre Confirmations, with its `code` when provided.
class PreconfRpcError extends Error {
  /// Creates a Pre Confirmations RPC error.
  PreconfRpcError(this.code, this.message);

  /// JSON-RPC error code (for example `-32602`).
  final int? code;

  /// Human-readable error message.
  final String message;

  @override
  String toString() => 'PreconfRpcError(${code ?? 'unknown'}): $message';
}

/// Decodes a raw Pre Confirmations binary frame into a
/// [PreconfNotification].
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

/// Decodes a transaction frame (see [decodePreconfFrame]) or a slot frame.
///
/// Slot frames are `version:u8 (128) | slot:u64_le | status:u8`.
///
/// Throws on a slot frame of the wrong length or with an unknown status, or on
/// anything [decodePreconfFrame] throws on.
PreconfEvent decodePreconfEvent(Uint8List bytes) {
  if (bytes.isEmpty || bytes[0] != preconfSlotWireVersion) {
    return decodePreconfFrame(bytes);
  }

  if (bytes.length != 10) {
    throw StateError('preconf slot frame has ${bytes.length} bytes');
  }

  final status = bytes[9];

  if (status > PreconfSlotStatus.bankFrozen) {
    throw StateError('unknown preconf slot status $status');
  }

  final byteData = ByteData.sublistView(bytes);

  return PreconfSlotNotification(
    slot: byteData.getUint64(1, Endian.little),
    status: status,
  );
}

/// Matches a top-level instruction (not CPIs) by program and data.
class PreconfInstructionFilter {
  /// Creates an instruction filter.
  const PreconfInstructionFilter({
    required this.programId,
    this.memcmp,
    this.dataSize,
  });

  /// Program invoked by the instruction.
  final String programId;

  /// Byte comparisons that all must match.
  final List<PreconfMemcmp>? memcmp;

  /// Exact instruction data length in bytes.
  final int? dataSize;

  /// Serializes this filter to a JSON map.
  Map<String, Object?> toJson() => {
    'programId': programId,
    if (memcmp != null) 'memcmp': memcmp!.map((e) => e.toJson()).toList(),
    if (dataSize != null) 'dataSize': dataSize,
  };
}

/// A byte comparison within instruction data.
class PreconfMemcmp {
  /// Creates a byte comparison.
  const PreconfMemcmp({
    required this.offset,
    required this.bytes,
    this.encoding,
  });

  /// Byte offset into the instruction data.
  final int offset;

  /// Bytes to compare, in [encoding].
  final String bytes;

  /// Encoding of [bytes]: `base58`, `base64`, or `hex`.
  final String? encoding;

  /// Serializes this comparison to a JSON map.
  Map<String, Object?> toJson() => {
    'offset': offset,
    'bytes': bytes,
    if (encoding != null) 'encoding': encoding,
  };
}

/// Server-side filter for [PreconfWsClient.preconfSubscribe].
///
/// Every field is optional; set fields combine with AND. Account filters also
/// match accounts loaded through address lookup tables. [includeSource] and the
/// deprecated [includeBam] cannot be combined.
class PreconfFilter {
  /// Creates a filter.
  PreconfFilter({
    this.failed,
    this.regionInclude,
    this.accountInclude,
    this.accountExclude,
    this.accountRequired,
    this.signerInclude,
    this.signerExclude,
    this.signatures,
    this.instructions,
    this.includeSource,
    this.includeBam,
  }) {
    if (includeSource != null && includeBam != null) {
      throw ArgumentError(
        'includeSource and includeBam cannot be combined; use includeSource.',
      );
    }
  }

  /// `true`: only failed transactions; `false`: only successful ones.
  final bool? failed;

  /// Only transactions from one of these regions.
  final List<String>? regionInclude;

  /// Must reference at least one of these accounts.
  final List<String>? accountInclude;

  /// Dropped if it references any of these accounts.
  final List<String>? accountExclude;

  /// Must reference all of these accounts.
  final List<String>? accountRequired;

  /// Must be signed by at least one of these accounts.
  final List<String>? signerInclude;

  /// Dropped if signed by any of these accounts.
  final List<String>? signerExclude;

  /// First signature must match one of these.
  final List<String>? signatures;

  /// At least one top-level instruction must match one of these.
  final List<PreconfInstructionFilter>? instructions;

  /// Sources to deliver; omit for both.
  final List<PreconfSource>? includeSource;

  /// Deprecated source toggle: `false` is the same as Helius only.
  final bool? includeBam;

  /// Serializes this filter to a JSON map.
  Map<String, Object?> toJson() => {
    if (failed != null) 'failed': failed,
    if (regionInclude != null) 'regionInclude': regionInclude,
    if (accountInclude != null) 'accountInclude': accountInclude,
    if (accountExclude != null) 'accountExclude': accountExclude,
    if (accountRequired != null) 'accountRequired': accountRequired,
    if (signerInclude != null) 'signerInclude': signerInclude,
    if (signerExclude != null) 'signerExclude': signerExclude,
    if (signatures != null) 'signatures': signatures,
    if (instructions != null)
      'instructions': instructions!.map((e) => e.toJson()).toList(),
    if (includeSource != null)
      'includeSource': includeSource!.map((e) => e.toJson()).toList(),
    if (includeBam != null) 'includeBam': includeBam,
  };
}

/// Options for [PreconfWsClient.preconfSubscribe].
class PreconfSubscribeOptions {
  /// Creates subscribe options.
  const PreconfSubscribeOptions({this.slots = false});

  /// Also deliver slot (bank created/frozen) events.
  final bool slots;
}

/// An active Pre Confirmations subscription.
class PreconfSubscription {
  PreconfSubscription._({
    required this.subscriptionId,
    required this.events,
    required this.unsubscribe,
  });

  /// The server-assigned subscription ID.
  final int subscriptionId;

  /// Every notification, including slot events when the subscription requested
  /// them.
  final Stream<PreconfEvent> events;

  /// Transaction notifications only.
  Stream<PreconfNotification> get notifications => events
      .where((event) => event is PreconfNotification)
      .cast<PreconfNotification>();

  /// Closes this subscription's connection and stops notifications.
  final Future<bool> Function() unsubscribe;
}

/// Coverage reported by `getPreConfCoverage`.
class PreconfCoverage {
  /// Creates coverage information.
  const PreconfCoverage({
    required this.networkSharePercent,
    required this.coverageByRegion,
  });

  /// Builds coverage from a JSON map.
  factory PreconfCoverage.fromJson(Map<String, Object?> json) {
    final networkShare = json['networkSharePercent']! as num;
    final regions = (json['coverageByRegion'] as Map?) ?? const {};

    return PreconfCoverage(
      networkSharePercent: networkShare.toDouble(),
      coverageByRegion: {
        for (final entry in regions.entries)
          entry.key! as String: (entry.value! as num).toDouble(),
      },
    );
  }

  /// Percentage of total network stake covered by Helius and BAM.
  final double networkSharePercent;

  /// Share of covered stake per region.
  final Map<String, double> coverageByRegion;
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
/// forwarding scheduled transactions to Helius, so expect gaps.
///
/// Each subscription opens its own connection, because binary notification
/// frames do not say which subscription they belong to. That makes filters and
/// slot events unambiguous.
class PreconfWsClient {
  /// Creates a Pre Confirmations client for the given API key.
  ///
  /// [channelFactory] optionally supplies the connector used for each
  /// subscription. It receives the credential-bearing endpoint, so tests can
  /// route to a local server.
  PreconfWsClient({
    required String apiKey,
    WebSocketChannel Function(Uri)? channelFactory,
    http.Client? httpClient,
  }) : _apiKey = apiKey, // ignore: prefer_initializing_formals
       _channelFactory = channelFactory ?? WebSocketChannel.connect,
       _httpClient = httpClient; // ignore: prefer_initializing_formals

  final String _apiKey;
  final WebSocketChannel Function(Uri) _channelFactory;
  final http.Client? _httpClient;
  final _live = <_LiveSubscription>{};
  bool _closed = false;

  /// Subscribes to Pre Confirmations, optionally filtered server-side.
  ///
  /// Rejects with a [PreconfRpcError] for an invalid filter (JSON-RPC
  /// `-32602`).
  Future<PreconfSubscription> preconfSubscribe({
    PreconfFilter? filter,
    PreconfSubscribeOptions options = const PreconfSubscribeOptions(),
  }) async {
    if (_closed) {
      throw StateError('Pre Confirmations WebSocket client closed');
    }

    final uri = Uri.parse(preconfWebsocketUrl(_apiKey));
    final channel = _channelFactory(uri);
    final live = _LiveSubscription(
      channel: channel,
      slots: options.slots,
    );
    _live.add(live);

    try {
      await channel.ready;
    } on Object {
      _live.remove(live);
      throw PreconfRpcError(
        null,
        'Pre Confirmations WebSocket connection failed to '
        '${redactUrl(uri.toString())}',
      );
    }

    live.start();
    final ack = live.ack.future;
    final request = <String, Object?>{
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'preconfSubscribe',
      if (filter != null) 'params': [filter.toJson()],
    };

    try {
      channel.sink.add(jsonEncode(request));
    } on Object {
      await live.close();
      throw PreconfRpcError(null, 'preconf WebSocket send failed');
    }

    final subscriptionId = await ack.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        unawaited(live.close());
        throw PreconfRpcError(null, 'preconfSubscribe timed out');
      },
    );

    return PreconfSubscription._(
      subscriptionId: subscriptionId,
      events: live.events,
      unsubscribe: live.unsubscribe,
    );
  }

  /// Closes the live subscription with the given server-assigned ID.
  ///
  /// Resolves `true` when a live subscription had this ID, `false` when none
  /// did. Throws if multiple live subscriptions report the same ID; prefer
  /// [PreconfSubscription.unsubscribe], which always targets its own
  /// connection.
  Future<bool> preconfUnsubscribe(int subscriptionId) async {
    final matches = _live
        .where((subscription) => subscription.id == subscriptionId)
        .toList(growable: false);

    if (matches.length > 1) {
      throw StateError(
        'Subscription id $subscriptionId matches ${matches.length} '
        'subscriptions; call unsubscribe() on the subscription instead',
      );
    }

    if (matches.isEmpty) return false;
    return matches.single.unsubscribe();
  }

  /// Returns the current coverage: share of network stake and its regional
  /// distribution.
  Future<PreconfCoverage> getPreConfCoverage() async {
    final wsUri = Uri.parse(preconfWebsocketUrl(_apiKey));
    final uri = wsUri.replace(
      scheme: wsUri.scheme == 'ws' ? 'http' : 'https',
    );
    final client = _httpClient ?? http.Client();
    final shouldClose = _httpClient == null; // coverage:ignore-line

    try {
      final response = await sendHeliusRequest(
        uri,
        () => client.post(
          uri,
          headers: const {'content-type': 'application/json'},
          body: jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'method': 'getPreConfCoverage',
          }),
        ),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw PreconfRpcError(
          null,
          'getPreConfCoverage HTTP ${response.statusCode}: '
          '${response.reasonPhrase ?? 'Unknown error'}',
        );
      }

      final body = jsonDecode(response.body) as Map<String, Object?>;
      final error = body['error'] as Map<String, Object?>?;

      if (error != null) {
        throw PreconfRpcError(
          error['code'] as int?,
          (error['message'] as String?) ?? 'Unknown RPC error',
        );
      }

      final result = body['result'] as Map<String, Object?>?;

      if (result == null) {
        throw PreconfRpcError(
          null,
          'Unexpected getPreConfCoverage response',
        );
      }

      return PreconfCoverage.fromJson(result);
    } finally {
      if (shouldClose) client.close(); // coverage:ignore-line
    }
  }

  /// Closes every connection and ends every subscription.
  void close() {
    if (_closed) return;
    _closed = true;

    for (final subscription in _live.toList(growable: false)) {
      unawaited(subscription.close());
    }

    _live.clear();
  }
}

class _LiveSubscription {
  _LiveSubscription({required this.channel, required this.slots});

  final WebSocketChannel channel;
  final bool slots;
  final ack = Completer<int>();
  final _buffer = <PreconfEvent>[];
  late final StreamController<PreconfEvent> _controller =
      StreamController<PreconfEvent>.broadcast(onListen: _flushBuffer);
  StreamSubscription<Object?>? _subscription;
  Timer? _ackTimer;
  Timer? _keepalive;
  int? id;
  bool _closed = false;

  Stream<PreconfEvent> get events => _controller.stream;

  void start() {
    _ackTimer = Timer(const Duration(seconds: 10), () {
      if (!ack.isCompleted) {
        ack.completeError(PreconfRpcError(null, 'preconfSubscribe timed out'));
      }
    });
    _keepalive = Timer.periodic(const Duration(seconds: 30), (_) {
      try {
        channel.sink.add(
          jsonEncode({'jsonrpc': '2.0', 'id': 0, 'method': 'ping'}),
        );
      } on Object {
        // A dead socket closes through its stream.
      }
    });
    _subscription = channel.stream.listen(
      _onMessage,
      onError: (Object error) =>
          _fail(PreconfRpcError(null, 'preconf WebSocket connection error')),
      onDone: () => _fail(
        PreconfRpcError(null, 'preconf WebSocket connection closed'),
      ),
      cancelOnError: true,
    );
  }

  Future<bool> unsubscribe() async {
    if (_closed || id == null) return false;
    await close();
    return true;
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _ackTimer?.cancel();
    _keepalive?.cancel();
    await _subscription?.cancel();
    await channel.sink.close();
    await _controller.close();
  }

  Future<void> _fail(PreconfRpcError error) async {
    if (_closed) return;
    if (!ack.isCompleted) ack.completeError(error);
    _controller.addError(error);
    await close();
  }

  void _flushBuffer() {
    for (final event in _buffer) {
      if (_controller.hasListener) _controller.add(event);
    }
    _buffer.clear();
  }

  void _onMessage(Object? message) {
    if (_closed) return;

    if (message is List<int>) {
      _onBinary(Uint8List.fromList(message));
      return;
    }

    if (message is String) {
      _onText(message);
    }
  }

  void _onBinary(Uint8List bytes) {
    if (id == null) return;

    try {
      final event = slots
          ? decodePreconfEvent(bytes)
          : decodePreconfFrame(bytes);
      _add(event);
    } on Object {
      // Skip a bad frame rather than end the stream.
    }
  }

  void _onText(String message) {
    final Map<String, Object?> json;

    try {
      json = jsonDecode(message) as Map<String, Object?>;
    } on Object {
      return;
    }

    final responseId = json['id'];
    final error = json['error'];
    final isSubscribeResponse =
        !ack.isCompleted &&
        (responseId == 1 || (responseId == null && error != null));

    if (!isSubscribeResponse) return;

    _ackTimer?.cancel();

    if (error != null) {
      final map = error as Map<String, Object?>?;
      ack.completeError(
        PreconfRpcError(
          map?['code'] as int?,
          (map?['message'] as String?) ?? '$error',
        ),
      );
      unawaited(close());
      return;
    }

    final result = json['result'];

    if (result is! int) {
      ack.completeError(
        PreconfRpcError(null, 'preconfSubscribe returned no subscription id'),
      );
      unawaited(close());
      return;
    }

    id = result;
    ack.complete(result);
  }

  void _add(PreconfEvent event) {
    if (_controller.hasListener) {
      _controller.add(event);
      return;
    }

    if (_buffer.length >= 10000) _buffer.removeAt(0);
    _buffer.add(event);
  }
}
