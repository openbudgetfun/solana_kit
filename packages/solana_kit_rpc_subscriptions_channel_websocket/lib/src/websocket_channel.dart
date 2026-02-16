import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// The normal closure code as defined by RFC 6455 Section 7.4.1.
const int normalClosureCode = 1000;

/// An abort signal that can be used to close a WebSocket channel.
///
/// Create with [AbortController] and pass the `signal` to
/// [createWebSocketChannel].
class AbortSignal {
  AbortSignal._(this._completer);

  final Completer<void> _completer;
  bool _isAborted = false;
  Object? _reason;

  /// Whether this signal has been aborted.
  bool get isAborted => _isAborted;

  /// The reason the signal was aborted, if any.
  Object? get reason => _reason;

  /// A future that completes when the signal is aborted.
  Future<void> get future => _completer.future;
}

/// A controller for creating and managing an [AbortSignal].
class AbortController {
  /// Creates a new [AbortController] with a fresh [AbortSignal].
  AbortController() : signal = AbortSignal._(Completer<void>());

  /// The signal associated with this controller.
  final AbortSignal signal;

  /// Abort the signal with an optional [reason].
  void abort([Object? reason]) {
    if (signal._isAborted) return;
    signal._isAborted = true;
    signal._reason = reason;
    if (!signal._completer.isCompleted) {
      signal._completer.complete();
    }
  }
}

/// Configuration for creating a WebSocket channel.
class WebSocketChannelConfig {
  /// Creates a [WebSocketChannelConfig].
  const WebSocketChannelConfig({
    required this.url,
    this.sendBufferHighWatermark = 128 * 1024,
    this.signal,
  });

  /// The WebSocket server URL (must use ws:// or wss:// protocol).
  final Uri url;

  /// The number of bytes to admit into the send buffer before queueing
  /// messages on the client.
  ///
  /// When you call [RpcSubscriptionsChannel.send] the runtime might add the
  /// message to a buffer rather than send it right away. In the event that the
  /// buffered amount exceeds the value configured here, messages will be added
  /// to a queue in your application code instead of being sent to the
  /// WebSocket, until such time as the buffered amount falls back below the
  /// high watermark.
  final int sendBufferHighWatermark;

  /// An optional signal to abort the connection.
  ///
  /// When the signal is aborted the WebSocket will be closed with a normal
  /// closure code (1000). If the channel has not been established yet, firing
  /// this signal will cause the [createWebSocketChannel] future to complete
  /// with the abort reason as an error.
  final AbortSignal? signal;
}

/// An RPC subscriptions channel that uses WebSocket transport.
///
/// Provides a [DataPublisher] interface for subscribing to `'message'` and
/// `'error'` events, plus a [send] method for outgoing messages.
abstract interface class RpcSubscriptionsChannel implements DataPublisher {
  /// Send a message through the WebSocket channel.
  ///
  /// Throws [SolanaError] with code
  /// [SolanaErrorCode.rpcSubscriptionsChannelConnectionClosed] if the
  /// channel is not open.
  Future<void> send(Object message);
}

/// Creates a WebSocket channel for RPC subscriptions.
///
/// Returns a [Future] that resolves to an [RpcSubscriptionsChannel] when the
/// WebSocket connection is successfully established.
///
/// Throws [SolanaError] with code:
/// - [SolanaErrorCode.rpcSubscriptionsChannelFailedToConnect] if the
///   connection fails.
/// - The abort signal's reason if aborted before connection.
///
/// Example:
/// ```dart
/// final controller = AbortController();
/// final channel = await createWebSocketChannel(
///   WebSocketChannelConfig(
///     url: Uri.parse('wss://api.mainnet-beta.solana.com'),
///     signal: controller.signal,
///   ),
/// );
///
/// channel.on('message', (data) {
///   print('Received: $data');
/// });
///
/// await channel.send('{"jsonrpc":"2.0","method":"accountSubscribe",...}');
///
/// // Later, close the channel:
/// controller.abort();
/// ```
Future<RpcSubscriptionsChannel> createWebSocketChannel(
  WebSocketChannelConfig config,
) async {
  // Check if already aborted.
  if (config.signal?.isAborted ?? false) {
    final reason = config.signal!.reason;
    if (reason is Exception || reason is Error) {
      // The reason is known to be an Exception or Error at this point.
      // ignore: only_throw_errors
      throw reason!;
    }
    throw SolanaError(SolanaErrorCode.rpcSubscriptionsChannelConnectionClosed);
  }

  final dataPublisher = createDataPublisher();

  WebSocketChannel webSocketChannel;

  try {
    webSocketChannel = WebSocketChannel.connect(config.url);
    // Wait for the connection to be established.
    await webSocketChannel.ready;
  } on Object {
    if (config.signal?.isAborted ?? false) {
      final reason = config.signal!.reason;
      if (reason is Exception || reason is Error) {
        // The reason is known to be an Exception or Error at this point.
        // ignore: only_throw_errors
        throw reason!;
      }
      throw SolanaError(
        SolanaErrorCode.rpcSubscriptionsChannelConnectionClosed,
      );
    }
    throw SolanaError(SolanaErrorCode.rpcSubscriptionsChannelFailedToConnect);
  }

  var isClosed = false;
  final subscriptions = <StreamSubscription<void>>[];

  // Handle abort signal.
  if (config.signal != null) {
    config.signal!.future.then((_) {
      if (!isClosed) {
        webSocketChannel.sink.close(normalClosureCode);
      }
      // Clean up subscriptions.
      for (final sub in subscriptions) {
        unawaited(sub.cancel());
      }
    }).ignore();
  }

  // Listen for messages from the WebSocket.
  final messageSub = webSocketChannel.stream.listen(
    (Object? data) {
      if (config.signal?.isAborted ?? false) return;
      dataPublisher.publish('message', data);
    },
    onError: (Object error) {
      if (config.signal?.isAborted ?? false) return;
      dataPublisher.publish('error', error);
    },
    onDone: () {
      isClosed = true;
      if (config.signal?.isAborted ?? false) return;
      // Connection closed unexpectedly.
      final closeCode = webSocketChannel.closeCode;
      if (closeCode != null && closeCode != normalClosureCode) {
        dataPublisher.publish(
          'error',
          SolanaError(SolanaErrorCode.rpcSubscriptionsChannelConnectionClosed, {
            'code': closeCode,
            'reason': webSocketChannel.closeReason ?? '',
          }),
        );
      }
    },
  );
  subscriptions.add(messageSub);

  return _WebSocketRpcChannel(
    dataPublisher: dataPublisher,
    webSocketChannel: webSocketChannel,
    isClosed: () => isClosed,
  );
}

class _WebSocketRpcChannel implements RpcSubscriptionsChannel {
  _WebSocketRpcChannel({
    required WritableDataPublisher dataPublisher,
    required WebSocketChannel webSocketChannel,
    required bool Function() isClosed,
  }) : _dataPublisher = dataPublisher,
       _webSocketChannel = webSocketChannel,
       _isClosed = isClosed;

  final WritableDataPublisher _dataPublisher;
  final WebSocketChannel _webSocketChannel;
  final bool Function() _isClosed;

  @override
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber) {
    return _dataPublisher.on(channelName, subscriber);
  }

  @override
  Future<void> send(Object message) async {
    if (_isClosed()) {
      throw SolanaError(
        SolanaErrorCode.rpcSubscriptionsChannelConnectionClosed,
      );
    }
    _webSocketChannel.sink.add(message);
  }
}
