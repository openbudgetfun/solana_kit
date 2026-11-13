import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:solana_kit_helius/src/types/parsed_streams_types.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Client for Helius Parsed Streams.
///
/// Parsed Streams pushes confirmed transactions that match a server-side filter
/// (program, instruction name, account, account role), already decoded through
/// Helius's IDL catalog. Delivery is at most once: the server does not replay
/// what confirmed while a connection was down. This client reconnects and
/// resubscribes automatically when the server closes the connection; it reports
/// the last delivered slot through `onDisconnect` as soon as the connection
/// drops and through `onReconnect` again once the subscriptions are back.
class ParsedStreamsClient {
  /// Creates a Parsed Streams client for the given API key.
  ParsedStreamsClient({
    required String apiKey,
    String? url,
    String? discoveryUrl,
    bool reconnect = true,
    int maxReconnectAttempts = 10,
    void Function(ParsedStreamsReconnectInfo)? onDisconnect,
    void Function(ParsedStreamsReconnectInfo)? onReconnect,
    WebSocketChannel Function(Uri)? channelFactory,
  }) : _url = url ?? parsedStreamsUrl(apiKey),
       _discoveryUrl = discoveryUrl ?? parsedStreamsDiscoveryUrl(apiKey),
       _reconnect = reconnect, // ignore: prefer_initializing_formals
       _maxReconnectAttempts = // ignore: prefer_initializing_formals
           maxReconnectAttempts,
       _onDisconnect = onDisconnect, // ignore: prefer_initializing_formals
       _onReconnect = onReconnect, // ignore: prefer_initializing_formals
       _channelFactory = channelFactory ?? WebSocketChannel.connect;

  final String _url;
  final String _discoveryUrl;
  final bool _reconnect;
  final int _maxReconnectAttempts;
  final void Function(ParsedStreamsReconnectInfo)? _onDisconnect;
  final void Function(ParsedStreamsReconnectInfo)? _onReconnect;
  final WebSocketChannel Function(Uri) _channelFactory;

  WebSocketChannel? _ws;
  // Cancelled by close(); the socket's own done/error handlers clear the rest.
  // ignore: cancel_subscriptions
  StreamSubscription<Object?>? _socketSubscription;
  Future<WebSocketChannel>? _connecting;
  final _pending = <int, Completer<Object?>>{};
  final _subs = <_SubState>{};
  final _byServerId = <int, _SubState>{};
  int _nextId = 1;
  int? _lastSlot;
  int _attempts = 0;
  bool _closed = false;
  Timer? _reconnectTimer;
  Timer? _stableTimer;
  ({int closeCode, int? lastSlot})? _outage;
  Future<void> _sendGate = Future<void>.value();
  int _lastSendAt = 0;

  static const _minSendIntervalMs = 100;
  static const _backoffBaseMs = 1000;
  static const _backoffMaxMs = 30000;
  static const _requestTimeoutMs = 15000;
  static const _stableConnectionMs = 30000;
  static const _slowConsumerCode = 1008;
  static const _transientCodes = [-32001, -32002];

  /// Subscribes to decoded transactions matching [filter].
  ///
  /// Resolves once the server accepts the filter; rejects with a
  /// [ParsedStreamsError] if it does not (for example `-32602` for an unknown
  /// field or bad pubkey).
  Future<ParsedTransactionSubscription> parsedTransactionSubscribe(
    ParsedTransactionFilter filter, {
    ParsedTransactionSubscribeOptions? options,
  }) async {
    if (_closed) {
      throw StateError('Parsed Streams client closed');
    }

    if (_reconnectTimer != null) unawaited(_restore());

    final details = options?.details ?? ParsedStreamDetails.full;
    final params = <Object?>[
      filter.toJson(),
      if (options != null) options.toJson(),
    ];
    late final _SubState sub;
    sub = _SubState(
      params: params,
      details: details,
      onOverflow: (state) {
        final error = ParsedStreamsError(
          null,
          'Parsed Streams subscription buffered 10000 unread notifications; '
          'the consumer is too slow',
        );
        unawaited(_unsubscribeSub(state));
        unawaited(state.end(error));
      },
    );

    try {
      await _subscribe(sub);
    } on Object {
      await sub.end();
      rethrow;
    }

    _subs.add(sub);

    return ParsedTransactionSubscription(
      notifications: sub.notifications,
      subscriptionId: () => sub.serverId,
      unsubscribe: () => _unsubscribeSub(sub),
    );
  }

  /// Unsubscribes the live subscription with [subscriptionId].
  Future<bool> parsedTransactionUnsubscribe(int subscriptionId) async {
    final sub = _byServerId[subscriptionId];

    return sub == null ? false : _unsubscribeSub(sub);
  }

  /// Lists a program's instruction names, events, and account roles.
  ///
  /// A catalog name also works, but names can be ambiguous across program
  /// versions, so check [ProgramDescription.id] in the result. Opens a
  /// short-lived connection to the discovery endpoint.
  Future<ProgramDescription> describeProgram(String program) async {
    final channel = _channelFactory(Uri.parse(_discoveryUrl));
    final completer = Completer<ProgramDescription>();
    late final StreamSubscription<Object?> subscription;
    Timer? timer;

    void finish([Object? error, ProgramDescription? result]) {
      if (completer.isCompleted) return;
      timer?.cancel();
      if (error != null) {
        completer.completeError(error);
      } else {
        completer.complete(result);
      }
      unawaited(subscription.cancel());
      unawaited(channel.sink.close());
    }

    timer = Timer(const Duration(milliseconds: _requestTimeoutMs), () {
      finish(ParsedStreamsError(null, 'describeProgram timed out'));
    });

    subscription = channel.stream.listen(
      (message) {
        if (message is! String) return;

        final Map<String, Object?> json;

        try {
          json = jsonDecode(message) as Map<String, Object?>;
        } on Object {
          return;
        }

        if (json['id'] != 1) return;

        final error = json['error'] as Map<String, Object?>?;

        if (error != null) {
          finish(
            ParsedStreamsError(
              error['code'] as int?,
              (error['message'] as String?) ?? 'describeProgram failed',
            ),
          );
          return;
        }

        final result = json['result'] as Map<String, Object?>?;

        if (result == null) {
          finish(
            ParsedStreamsError(null, 'describeProgram returned no result'),
          );
          return;
        }

        finish(null, ProgramDescription.fromJson(result));
      },
      onError: (Object _) =>
          finish(ParsedStreamsError(null, 'describeProgram connection failed')),
      onDone: () => finish(
        ParsedStreamsError(
          null,
          'describeProgram connection closed before a response',
        ),
      ),
    );

    try {
      await channel.ready;
    } on Object {
      finish(ParsedStreamsError(null, 'describeProgram connection failed'));
      return completer.future;
    }

    channel.sink.add(
      jsonEncode({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'describeProgram',
        'params': [
          {'program': program},
        ],
      }),
    );

    return completer.future;
  }

  /// Closes the connection and ends every subscription.
  void close() {
    if (_closed) return;
    _closed = true;
    _reconnectTimer?.cancel();
    _stableTimer?.cancel();
    _reconnectTimer = null;
    _stableTimer = null;
    final socket = _ws;
    final socketSubscription = _socketSubscription;
    _ws = null;
    _socketSubscription = null;
    _connecting = null;
    unawaited(_failAll());
    for (final completer in _pending.values) {
      completer.completeError(StateError('Parsed Streams client closed'));
    }
    _pending.clear();
    unawaited(socketSubscription?.cancel() ?? Future<void>.value());
    unawaited(socket?.sink.close() ?? Future<void>.value());
  }

  Future<void> _failAll([Object? error]) async {
    _attempts = 0;
    _outage = null;
    final subs = _subs.toList(growable: false);
    _subs.clear();
    _byServerId.clear();

    for (final sub in subs) {
      sub.active = false;
      await sub.end(error);
    }
  }

  void _handleClose(int code) {
    if (_closed) return;
    _stableTimer?.cancel();
    _ws = null;
    _socketSubscription = null;
    _connecting = null;

    final error = ParsedStreamsError(
      null,
      'Parsed Streams connection closed (code $code)',
    );

    for (final completer in _pending.values) {
      completer.completeError(error);
    }

    _pending.clear();
    _byServerId.clear();

    for (final sub in _subs) {
      sub.serverId = null;
    }

    if (_subs.isEmpty) return;

    // The first close of an outage marks where the gap starts. `onDisconnect`
    // reports it after the state above has settled, so a callback that closes
    // or (un)subscribes sees settled state (upstream #398).
    final freshOutage = _outage == null;
    final info = _outage ??= (closeCode: code, lastSlot: _lastSlot);

    if (code == _slowConsumerCode) {
      unawaited(
        _failAll(
          ParsedStreamsError(
            null,
            'Parsed Streams closed the connection because this client fell '
            'more than 2048 notifications behind (code 1008). Narrow the '
            'filter, use details: "matched" or "raw", or process '
            'notifications faster.',
          ),
        ),
      );
    } else if (!_reconnect) {
      unawaited(_failAll(error));
    } else {
      _attempts++;

      if (_attempts > _maxReconnectAttempts) {
        unawaited(
          _failAll(
            ParsedStreamsError(
              null,
              'Parsed Streams gave up after $_maxReconnectAttempts reconnect '
              'attempts (last close code $code)',
            ),
          ),
        );
      } else {
        final delay = math.min(
          _backoffBaseMs * (1 << (_attempts - 1)),
          _backoffMaxMs,
        );
        _reconnectTimer = Timer(Duration(milliseconds: delay), () {
          _reconnectTimer = null;
          unawaited(_restore());
        });
      }
    }

    if (freshOutage) {
      try {
        _onDisconnect?.call(
          ParsedStreamsReconnectInfo(
            closeCode: info.closeCode,
            lastSlot: info.lastSlot,
          ),
        );
      } on Object {
        // A throwing callback must not break the stream.
      }
    }
  }

  Future<WebSocketChannel> _connect() async {
    final existing = _ws;

    if (existing != null) return existing;

    final pendingConnection = _connecting;

    if (pendingConnection != null) return pendingConnection;
    if (_closed) throw StateError('Parsed Streams client closed');

    final completer = Completer<WebSocketChannel>();
    _connecting = completer.future;
    final channel = _channelFactory(Uri.parse(_url));

    try {
      await channel.ready.timeout(
        const Duration(milliseconds: _requestTimeoutMs),
      );
    } on Object {
      _connecting = null;
      unawaited(channel.sink.close());
      _handleClose(1006);
      throw ParsedStreamsError(null, 'Parsed Streams connection failed');
    }

    if (_closed) {
      _connecting = null;
      unawaited(channel.sink.close());
      throw StateError('Parsed Streams client closed');
    }

    _ws = channel;
    _connecting = null;
    _socketSubscription = channel.stream.listen(
      _onMessage,
      onError: (Object _) => _handleClose(1006),
      onDone: () => _handleClose(1006),
    );
    _stableTimer = Timer(
      const Duration(milliseconds: _stableConnectionMs),
      () => _attempts = 0,
    );
    completer.complete(channel);

    return channel;
  }

  Future<void> _restore() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    if (_closed || _subs.isEmpty) return;

    try {
      await _connect();

      for (final sub in _subs.toList(growable: false)) {
        if (sub.serverId != null || !sub.active) continue;

        try {
          await _subscribe(sub);
        } on ParsedStreamsError catch (error) {
          final code = error.code;

          if (code == null || _transientCodes.contains(code)) {
            unawaited(_ws?.sink.close() ?? Future<void>.value());
            _handleClose(1006);
            return;
          }

          _subs.remove(sub);
          sub.active = false;
          await sub.end(error);
        }
      }
    } on Object {
      return;
    }

    final outage = _outage;
    _outage = null;

    if (outage != null) {
      try {
        _onReconnect?.call(
          ParsedStreamsReconnectInfo(
            closeCode: outage.closeCode,
            lastSlot: outage.lastSlot,
          ),
        );
      } on Object {
        // A throwing callback must not break the stream.
      }
    }
  }

  Future<Object?> _request(String method, List<Object?> params) async {
    final channel = await _connect();
    final id = _nextId++;
    final completer = Completer<Object?>();
    _pending[id] = completer;
    final timer = Timer(
      const Duration(milliseconds: _requestTimeoutMs),
      () {
        if (_pending.remove(id) != null) {
          completer.completeError(
            ParsedStreamsError(null, 'Parsed Streams $method timed out'),
          );
          unawaited(_ws?.sink.close() ?? Future<void>.value());
        }
      },
    );

    try {
      await _send(
        channel,
        jsonEncode({
          'jsonrpc': '2.0',
          'id': id,
          'method': method,
          'params': params,
        }),
      );
    } on Object {
      _pending.remove(id);
      timer.cancel();
      rethrow;
    }

    return completer.future.whenComplete(timer.cancel);
  }

  Future<void> _send(WebSocketChannel channel, String payload) {
    final sent = _sendGate.then((_) async {
      final wait =
          _lastSendAt +
          _minSendIntervalMs -
          DateTime.now().millisecondsSinceEpoch;

      if (wait > 0) {
        await Future<void>.delayed(Duration(milliseconds: wait));
      }

      if (_ws != channel) {
        throw ParsedStreamsError(
          null,
          _closed
              ? 'Parsed Streams client closed'
              : 'Parsed Streams connection closed',
        );
      }

      _lastSendAt = DateTime.now().millisecondsSinceEpoch;
      channel.sink.add(payload);
    });
    _sendGate = sent.catchError((Object _) {});
    return sent;
  }

  Future<void> _subscribe(_SubState sub) async {
    final result = await _request('parsedTransactionSubscribe', sub.params);

    if (result is! int) {
      throw ParsedStreamsError(
        null,
        'parsedTransactionSubscribe returned no subscription id',
      );
    }

    if (_ws == null) {
      throw ParsedStreamsError(null, 'Parsed Streams connection closed');
    }

    if (!sub.active) {
      unawaited(
        _request('parsedTransactionUnsubscribe', [result]).catchError(
          (Object _) => false,
        ),
      );
      return;
    }

    sub.serverId = result;
    _byServerId[result] = sub;
  }

  Future<bool> _unsubscribeSub(_SubState sub) async {
    sub.active = false;
    _subs.remove(sub);
    await sub.end();
    final id = sub.serverId;

    if (id == null || _ws == null) return false;

    _byServerId.remove(id);

    try {
      return await _request('parsedTransactionUnsubscribe', [id]) == true;
    } on Object {
      return false;
    }
  }

  void _onMessage(Object? message) {
    if (message is! String) return;

    final Map<String, Object?> json;

    try {
      json = jsonDecode(message) as Map<String, Object?>;
    } on Object {
      return;
    }

    if (json['method'] == 'parsedTransactionNotification') {
      final params = json['params'] as Map<String, Object?>?;
      final subscriptionId = params?['subscription'] as int?;
      final result = params?['result'] as Map<String, Object?>?;

      if (subscriptionId == null || result == null) return;

      final sub = _byServerId[subscriptionId];

      if (sub == null) return;

      final context = result['context'] as Map<String, Object?>?;
      final slot = context?['slot'] as int?;

      if (slot != null && (_lastSlot == null || slot > _lastSlot!)) {
        _lastSlot = slot;
      }

      _attempts = 0;

      try {
        final value = result['value']! as Map<String, Object?>;

        sub.push(
          ParsedTransactionNotification(
            contextSlot: slot ?? 0,
            value: sub.details == ParsedStreamDetails.raw
                ? RawTransactionValue.fromJson(value)
                : ParsedTransactionValue.fromJson(value),
          ),
        );
      } on Object {
        unawaited(
          sub.end(
            ParsedStreamsError(
              null,
              'Parsed Streams delivered a malformed notification',
            ),
          ),
        );
        unawaited(_unsubscribeSub(sub));
      }

      return;
    }

    final id = json['id'];

    if (id is! int) return;

    final completer = _pending.remove(id);

    if (completer == null) return;

    final error = json['error'] as Map<String, Object?>?;

    if (error != null) {
      completer.completeError(
        ParsedStreamsError(
          error['code'] as int?,
          (error['message'] as String?) ?? 'Parsed Streams RPC error',
        ),
      );
      return;
    }

    completer.complete(json['result']);
  }
}

class _SubState {
  _SubState({
    required this.params,
    required this.details,
    required this.onOverflow,
  });

  final List<Object?> params;
  final ParsedStreamDetails details;
  final void Function(_SubState) onOverflow;
  final _buffer = <ParsedTransactionNotification>[];
  late final StreamController<ParsedTransactionNotification> _controller =
      StreamController<ParsedTransactionNotification>.broadcast(
        onListen: _flushBuffer,
      );
  int? serverId;
  bool active = true;
  bool _ended = false;

  Stream<ParsedTransactionNotification> get notifications => _controller.stream;

  void push(ParsedTransactionNotification notification) {
    if (_ended) return;

    if (_controller.hasListener) {
      _controller.add(notification);
      return;
    }

    if (_buffer.length >= 10000) {
      onOverflow(this);
      return;
    }

    _buffer.add(notification);
  }

  Future<void> end([Object? error]) async {
    if (_ended) return;
    _ended = true;

    if (error != null) _controller.addError(error);
    await _controller.close();
  }

  void _flushBuffer() {
    for (final notification in _buffer) {
      if (_controller.hasListener) _controller.add(notification);
    }
    _buffer.clear();
  }
}
