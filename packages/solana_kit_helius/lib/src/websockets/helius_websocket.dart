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
  HeliusWebSocket({required this.url});

  /// The Helius WebSocket endpoint URL.
  final String url;

  WebSocketChannel? _channel;
  StreamSubscription<Object?>? _subscription;
  final _controllers = <int, StreamController<Map<String, Object?>>>{};
  int _nextId = 1;
  final _subscriptionIds = <int, int>{};

  /// Connects to the Helius WebSocket endpoint.
  ///
  /// Must be called before [subscribe]. Throws if the connection fails.
  Future<void> connect() async {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    await _channel!.ready;
    _subscription = _channel!.stream.listen(
      _onMessage,
      onError: _onError,
      onDone: _onDone,
    );
  }

  /// Subscribes to a JSON-RPC [method] with the given [params].
  ///
  /// Returns a broadcast [Stream] of notification payloads. The subscription
  /// is automatically unsubscribed when the stream is cancelled.
  ///
  /// Throws a [SolanaError] with [SolanaErrorCode.heliusWebSocketError] if
  /// the WebSocket is not connected.
  Stream<Map<String, Object?>> subscribe(String method, [Object? params]) {
    if (_channel == null) {
      throw SolanaError(SolanaErrorCode.heliusWebSocketError, {
        'message': 'WebSocket not connected. Call connect() first.',
      });
    }

    final id = _nextId++;
    final controller = StreamController<Map<String, Object?>>.broadcast(
      onCancel: () => _unsubscribe(id),
    );
    _controllers[id] = controller;

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
    for (final controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();
    _subscriptionIds.clear();
    await _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
  }

  void _unsubscribe(int requestId) {
    final subId = _subscriptionIds.remove(requestId);
    _controllers.remove(requestId)?.close();
    if (subId != null && _channel != null) {
      _channel!.sink.add(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': _nextId++,
          'method': 'unsubscribe',
          'params': [subId],
        }),
      );
    }
  }

  void _onMessage(Object? data) {
    if (data is! String) return;
    final json = jsonDecode(data) as Map<String, Object?>;

    // Subscription confirmation response.
    if (json.containsKey('id') && json.containsKey('result')) {
      final id = json['id']! as int;
      final result = json['result'];
      if (result is int) {
        _subscriptionIds[id] = result;
      }
      return;
    }

    // Notification message.
    if (json.containsKey('method') && json.containsKey('params')) {
      final params = json['params']! as Map<String, Object?>;
      final subscription = params['subscription'] as int?;
      if (subscription != null) {
        final result = params['result'] as Map<String, Object?>?;
        if (result != null) {
          for (final entry in _subscriptionIds.entries) {
            if (entry.value == subscription) {
              _controllers[entry.key]?.add(result);
              break;
            }
          }
        }
      }
    }
  }

  void _onError(Object error) {
    for (final controller in _controllers.values) {
      controller.addError(
        SolanaError(SolanaErrorCode.heliusWebSocketError, {
          'message': error.toString(),
        }),
      );
    }
  }

  void _onDone() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
    _subscriptionIds.clear();
    _channel = null;
  }
}
