import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// The normal closure code as defined by RFC 6455 Section 7.4.1.
const int normalClosureCode = 1000;

/// Error used when an operation is canceled without a custom abort reason.
class AbortError implements Exception {
  /// Creates a new [AbortError].
  const AbortError([this.message = 'The operation was aborted.']);

  /// Human-readable abort message.
  final String message;

  @override
  String toString() => 'AbortError: $message';
}

/// Returns whether [error] represents an abort cancellation.
bool isAbortError(Object? error) => error is AbortError;

/// Wraps [future] so it completes with the abort reason if [abortSignal] fires.
Future<T> getAbortableFuture<T>(Future<T> future, [AbortSignal? abortSignal]) {
  if (abortSignal == null) return future;

  final completer = Completer<T>();
  void abort() => _completeAbort(completer, abortSignal);

  if (abortSignal.isAborted) {
    abort();
  } else {
    unawaited(abortSignal.future.then((_) => abort()));
  }

  unawaited(
    future.then(
      (value) {
        if (!completer.isCompleted) completer.complete(value);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
    ),
  );

  return completer.future;
}

void _completeAbort<T>(Completer<T> completer, AbortSignal signal) {
  if (completer.isCompleted) return;
  final reason = signal.reason ?? const AbortError();
  if (reason is Error) {
    completer.completeError(reason, reason.stackTrace);
  } else {
    completer.completeError(reason);
  }
}

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
    this.allowInsecureWs = false,
    this.allowPrivateHosts = false,
    this.sendBufferHighWatermark = 128 * 1024,
    this.signal,
  });

  /// The WebSocket server URL.
  ///
  /// By default only `wss://` URLs are allowed. Set [allowInsecureWs] to
  /// `true` to allow `ws://` URLs for local development and testing.
  final Uri url;

  /// Whether to allow insecure `ws://` URLs.
  ///
  /// Defaults to `false`, which enforces `wss://` URLs.
  /// When set to `true`, insecure `ws://` URLs are only allowed in
  /// debug mode. In release/profile mode, this flag is ignored and
  /// `wss://` is always required.
  final bool allowInsecureWs;

  /// Whether to allow connections to private/internal hosts.
  ///
  /// Defaults to `false`, which blocks connections to localhost, loopback,
  /// and private IP ranges (10.x, 172.16-31.x, 192.168.x, 169.254.x, fc/fd::).
  ///
  /// Set to `true` for local development and testing against local validators.
  final bool allowPrivateHosts;

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

  _validateWebSocketUrl(
    config.url,
    allowInsecureWs: config.allowInsecureWs,
    allowPrivateHosts: config.allowPrivateHosts,
  );

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
        unawaited(webSocketChannel.sink.close(normalClosureCode));
      }
      // Clean up subscriptions.
      for (final sub in subscriptions) {
        unawaited(sub.cancel());
      }
    }).ignore();
  }

  // Listen for messages from the WebSocket.
  final messageSub = webSocketChannel.stream.listen(
    (data) {
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

void _validateWebSocketUrl(
  Uri url, {
  required bool allowInsecureWs,
  required bool allowPrivateHosts,
}) {
  final scheme = url.scheme.toLowerCase();

  if (!url.isAbsolute || url.host.isEmpty) {
    throw ArgumentError.value(
      url.toString(),
      'url',
      'WebSocket URL must be an absolute URL.',
    );
  }

  // SSRF protection: block connections to private/internal hosts.
  if (!allowPrivateHosts) {
    _assertHostIsNotPrivate(url);
  }

  if (scheme == 'wss') {
    return;
  }

  if (scheme == 'ws' && allowInsecureWs) {
    // In release/profile mode, ws:// is never allowed regardless of
    // the allowInsecureWs flag. This prevents accidental use of
    // insecure WebSocket connections in production.
    const isProduction = bool.fromEnvironment('dart.vm.product');
    // coverage:ignore-start - unreachable in debug/test mode
    if (isProduction) {
      throw ArgumentError.value(
        url.toString(),
        'url',
        'Insecure WebSocket endpoints are not allowed in release mode. '  
            'Use a wss:// URL instead.',
      );
    }
    // coverage:ignore-end
    return;
  }

  if (scheme == 'ws') {
    throw ArgumentError.value(
      url.toString(),
      'url',
      'Insecure WebSocket endpoints are disabled by default. '
          'Use a wss:// URL or set allowInsecureWs: true for development.',
    );
  }

  throw ArgumentError.value(
    url.toString(),
    'url',
    "WebSocket URL must use either 'wss' or 'ws'.",
  );
}

/// Hostnames that are always blocked to prevent SSRF attacks.
const _blockedHostnames = {
  'localhost',
  '0.0.0.0',
  '::',
  '::1',
  '0:0:0:0:0:0:0:1',
};

/// Throws [ArgumentError] if [url] targets a private/internal host.
///
/// This is a best-effort SSRF mitigation. It blocks known private hostnames
/// and IP-literal ranges (10.x, 172.16-31.x, 192.168.x, 169.254.x, fc-fd::).
/// It does NOT perform DNS resolution.
void _assertHostIsNotPrivate(Uri url) {
  final host = url.host.toLowerCase();

  if (_blockedHostnames.contains(host)) {
    throw ArgumentError.value(
      url.toString(),
      'url',
      'WebSocket URL must not target a private or loopback host.',
    );
  }

  // IPv4 private ranges: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16
  if (_isPrivateIpv4(host)) {
    throw ArgumentError.value(
      url.toString(),
      'url',
      'WebSocket URL must not target a private IPv4 address.',
    );
  }

  // IPv6 private range: fc00::/7 (unique local addresses)
  if (_isPrivateIpv6(host)) {
    throw ArgumentError.value(
      url.toString(),
      'url',
      'WebSocket URL must not target a private IPv6 address.',
    );
  }
}

bool _isPrivateIpv4(String host) {
  // Strip port if present (e.g., '192.168.1.1:8080')
  final ip = host.contains(':') && !host.contains('[')
      ? host.substring(0, host.lastIndexOf(':'))
      : host;

  final parts = ip.split('.');
  if (parts.length != 4) return false;

  final first = int.tryParse(parts[0]);
  final second = int.tryParse(parts[1]);
  if (first == null || second == null) return false;

  // 10.0.0.0/8
  if (first == 10) return true;

  // 172.16.0.0/12
  if (first == 172 && second >= 16 && second <= 31) return true;

  // 192.168.0.0/16
  if (first == 192 && second == 168) return true;

  // 169.254.0.0/16 (link-local)
  if (first == 169 && second == 254) return true;

  return false;
}

bool _isPrivateIpv6(String host) {
  // Normalize: strip brackets and zone ID
  var h = host.replaceAll('[', '').replaceAll(']', '');
  if (h.contains('%')) h = h.substring(0, h.indexOf('%'));

  // fc00::/7 covers fc00:: through fdff:...
  return h.startsWith('fc') || h.startsWith('fd');
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
