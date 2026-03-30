import 'dart:async';
import 'dart:convert';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket client for Helius real-time subscriptions.
///
/// Provides a streaming interface for subscribing to Solana events through
/// the Helius WebSocket endpoint. Each subscription returns a broadcast
/// [Stream] of notification payloads.
class HeliusWebSocket {
  /// Creates a new [HeliusWebSocket] with the given WebSocket [url].
  HeliusWebSocket({
    required this.url,
    this.allowInsecureWs = false,
  });

  /// The Helius WebSocket endpoint URL.
  final String url;

  /// Whether to allow insecure `ws://` URLs.
  ///
  /// Defaults to `false`, which enforces `wss://` URLs. Set to `true` only
  /// for local development and controlled tests.
  final bool allowInsecureWs;

  WebSocketChannel? _channel;
  // The WebSocket stream subscription is cancelled by close() and _onDone().
  // ignore: cancel_subscriptions
  StreamSubscription<Object?>? _subscription;
  final _controllers = <int, StreamController<Map<String, Object?>>>{};
  final _subscriptionIds = <int, int>{};
  final _subscriptionMethods = <int, String>{};
  int _nextId = 1;
  bool _isConnected = false;

  /// Whether the WebSocket connection is currently established.
  bool get isConnected => _isConnected;

  /// Connects to the Helius WebSocket endpoint.
  ///
  /// Must be called before [subscribe]. Throws if the connection fails.
  Future<void> connect() async {
    if (_isConnected) return;

    final uri = _validateAndNormalizeWebSocketUrl(
      url,
      allowInsecureWs: allowInsecureWs,
    );

    try {
      final channel = WebSocketChannel.connect(uri);
      await channel.ready;
      _channel = channel;
      _isConnected = true;
      _subscription = channel.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
    } on Object catch (error) {
      _channel = null;
      _subscription = null;
      _isConnected = false;
      throw SolanaError(SolanaErrorCode.heliusWebSocketError, {
        'message': 'Failed to connect to $uri: $error',
      });
    }
  }

  /// Subscribes to a JSON-RPC [method] with the given [params].
  ///
  /// Returns a broadcast [Stream] of notification payloads. The subscription
  /// is automatically unsubscribed when the stream is cancelled.
  ///
  /// Throws a [SolanaError] with [SolanaErrorCode.heliusWebSocketError] if
  /// the WebSocket is not connected.
  Stream<Map<String, Object?>> subscribe(String method, [Object? params]) {
    if (!_isConnected || _channel == null) {
      throw SolanaError(SolanaErrorCode.heliusWebSocketError, {
        'message': 'WebSocket not connected. Call connect() first.',
      });
    }

    final id = _nextId++;
    final controller = StreamController<Map<String, Object?>>.broadcast(
      onCancel: () => _unsubscribe(id),
    );
    _controllers[id] = controller;
    _subscriptionMethods[id] = method;

    _channel!.sink.add(
      jsonEncode({
        'jsonrpc': '2.0',
        'id': id,
        'method': method,
        if (params != null) 'params': params,
      }),
    );

    return controller.stream;
  }

  /// Closes the WebSocket connection and all active subscriptions.
  Future<void> close() async {
    final subscription = _subscription;
    final channel = _channel;

    _subscription = null;
    _channel = null;
    _isConnected = false;

    await subscription?.cancel();
    await channel?.sink.close();
    await _closeControllers();

    _subscriptionIds.clear();
    _subscriptionMethods.clear();
    _nextId = 1;
  }

  void _unsubscribe(int requestId) {
    final subId = _subscriptionIds.remove(requestId);
    final controller = _controllers.remove(requestId);
    final subscribeMethod = _subscriptionMethods.remove(requestId);

    if (controller != null && !controller.isClosed) {
      unawaited(controller.close());
    }

    if (subId != null && _channel != null && _isConnected) {
      _channel!.sink.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': _nextId++,
          'method': _unsubscribeMethodFor(subscribeMethod),
          'params': [subId],
        }),
      );
    }
  }

  void _onMessage(Object? data) {
    if (data is! String) return;

    final json = _tryParseMessage(data);
    if (json == null) return;

    // Subscription confirmation response.
    if (json.containsKey('id') && json.containsKey('result')) {
      final id = json['id'];
      final result = json['result'];
      if (id is int && result is int) {
        _subscriptionIds[id] = result;
      }
      return;
    }

    // Subscription error response.
    if (json.containsKey('id') && json.containsKey('error')) {
      final id = json['id'];
      if (id is int) {
        _controllers[id]?.addError(
          SolanaError(SolanaErrorCode.heliusWebSocketError, {
            'message': 'Helius subscription error: ${json['error']}',
          }),
        );
      }
      return;
    }

    // Notification message.
    if (json.containsKey('method') && json.containsKey('params')) {
      final params = json['params'];
      if (params is! Map) return;

      final subscription = params['subscription'] as int?;
      if (subscription == null) return;

      final result = params['result'];
      if (result is! Map) return;

      final typedResult = result.cast<String, Object?>();
      for (final entry in _subscriptionIds.entries) {
        if (entry.value == subscription) {
          _controllers[entry.key]?.add(typedResult);
          break;
        }
      }
    }
  }

  Map<String, Object?>? _tryParseMessage(String data) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is! Map) {
        _broadcastError(
          SolanaError(SolanaErrorCode.heliusWebSocketError, {
            'message': 'Received non-object WebSocket payload from Helius.',
          }),
        );
        return null;
      }
      return decoded.cast<String, Object?>();
    } on FormatException catch (error) {
      _broadcastError(
        SolanaError(SolanaErrorCode.heliusWebSocketError, {
          'message': 'Failed to decode Helius WebSocket payload: $error',
        }),
      );
      return null;
    }
  }

  void _onError(Object error) {
    _broadcastError(
      SolanaError(SolanaErrorCode.heliusWebSocketError, {
        'message': error.toString(),
      }),
    );
  }

  void _onDone() {
    final subscription = _subscription;
    _channel = null;
    _subscription = null;
    _isConnected = false;
    _subscriptionIds.clear();
    _subscriptionMethods.clear();
    _nextId = 1;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
    unawaited(_closeControllers());
  }

  void _broadcastError(Object error) {
    for (final controller in _controllers.values) {
      controller.addError(error);
    }
  }

  Future<void> _closeControllers() async {
    final controllers = _controllers.values.toList(growable: false);
    _controllers.clear();
    for (final controller in controllers) {
      await controller.close();
    }
  }
}

String _unsubscribeMethodFor(String? subscribeMethod) {
  if (subscribeMethod == null) return 'unsubscribe';
  const suffix = 'Subscribe';
  if (!subscribeMethod.endsWith(suffix)) return 'unsubscribe';
  return '${subscribeMethod.substring(0, subscribeMethod.length - suffix.length)}Unsubscribe';
}

Uri _validateAndNormalizeWebSocketUrl(
  String url, {
  required bool allowInsecureWs,
}) {
  final parsedUrl = Uri.parse(url);
  final scheme = parsedUrl.scheme.toLowerCase();

  if (!parsedUrl.isAbsolute || parsedUrl.host.isEmpty) {
    throw ArgumentError.value(
      url,
      'url',
      'Helius WebSocket URL must be an absolute URL.',
    );
  }

  if (scheme == 'wss') {
    return parsedUrl;
  }

  if (scheme == 'ws' && allowInsecureWs) {
    return parsedUrl;
  }

  if (scheme == 'ws') {
    throw ArgumentError.value(
      url,
      'url',
      'Insecure WebSocket endpoints are disabled by default. '
          'Use a wss:// URL or set allowInsecureWs: true for development.',
    );
  }

  throw ArgumentError.value(
    url,
    'url',
    "Helius WebSocket URL must use either 'wss' or 'ws'.",
  );
}
