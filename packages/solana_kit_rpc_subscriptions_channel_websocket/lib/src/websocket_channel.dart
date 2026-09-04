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

/// Wraps [future] so it completes with the cancel reason if [cancellationToken]
/// fires.
Future<T> getAbortableFuture<T>(
  Future<T> future, [
  CancellationToken? cancellationToken,
]) {
  if (cancellationToken == null) return future;

  final completer = Completer<T>();
  void abort() => _completeAbort(completer, cancellationToken);

  if (cancellationToken.isCancelled) {
    abort();
  } else {
    unawaited(cancellationToken.future.then((_) => abort()));
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

void _completeAbort<T>(Completer<T> completer, CancellationToken token) {
  if (completer.isCompleted) return;
  final reason = token.reason ?? const AbortError();
  if (reason is Error) {
    completer.completeError(reason, reason.stackTrace);
  } else {
    completer.completeError(reason);
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
  /// Defaults to `false`, which blocks localhost plus loopback, private,
  /// link-local, non-canonical, and reserved IP literals. Hostnames are not
  /// DNS-resolved, so callers must not treat this as a complete SSRF boundary
  /// when the URL itself comes from an untrusted source.
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
  /// WebSocket, until such time that the buffered amount falls back below the
  /// high watermark.
  final int sendBufferHighWatermark;

  /// An optional cancellation token used to abort the connection.
  ///
  /// When the token is cancelled the WebSocket will be closed with a normal
  /// closure code (1000). If the channel has not been established yet, firing
  /// this token will cause the [createWebSocketChannel] future to complete
  /// with the cancel reason as an error.
  final CancellationToken? signal;
}

/// An RPC subscriptions channel that uses WebSocket transport.
///
/// Provides a [NotificationStreams] interface for subscribing to message and
/// error events, plus a [send] method for outgoing messages.
abstract interface class RpcSubscriptionsChannel {
  /// The broadcast streams carrying notifications and errors.
  NotificationStreams get streams;

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
/// - The cancellation token's reason if cancelled before connection.
///
/// Example:
/// ```dart
/// final source = CancellationTokenSource();
/// final channel = await createWebSocketChannel(
///   WebSocketChannelConfig(
///     url: Uri.parse('wss://api.mainnet-beta.solana.com'),
///     signal: source.token,
///   ),
/// );
///
/// channel.streams.notifications.listen((data) {
///   print('Received: $data');
/// });
///
/// await channel.send('{"jsonrpc":"2.0","method":"accountSubscribe",...}');
///
/// // Later, close the channel:
/// source.cancel();
/// ```
Future<RpcSubscriptionsChannel> createWebSocketChannel(
  WebSocketChannelConfig config,
) async {
  // Check if already cancelled.
  if (config.signal?.isCancelled ?? false) {
    final reason = config.signal!.reason;
    if (reason is Exception || reason is Error) {
      // The reason is known to be an Exception or Error at this point.
      // ignore: only_throw_errors
      throw reason!;
    }
    throw SolanaError(SolanaErrorCode.rpcSubscriptionsChannelConnectionClosed);
  }

  validateWebSocketUrl(
    config.url,
    allowInsecureWs: config.allowInsecureWs,
    allowPrivateHosts: config.allowPrivateHosts,
  );

  final messagesController = StreamController<Object?>.broadcast(sync: true);
  final errorsController = StreamController<Object?>.broadcast(sync: true);

  WebSocketChannel? connectingChannel;
  final WebSocketChannel webSocketChannel;

  try {
    connectingChannel = WebSocketChannel.connect(config.url);
    webSocketChannel = connectingChannel;
    // Wait for the connection to be established.
    await getAbortableFuture(webSocketChannel.ready, config.signal);
  } on Object {
    connectingChannel?.sink.close(normalClosureCode).ignore();
    unawaited(messagesController.close());
    unawaited(errorsController.close());
    if (config.signal?.isCancelled ?? false) {
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

  void closeStreams() {
    isClosed = true;
    unawaited(messagesController.close());
    unawaited(errorsController.close());
  }

  // Handle cancellation token.
  if (config.signal != null) {
    config.signal!.future.then((_) {
      if (!isClosed) {
        webSocketChannel.sink.close(normalClosureCode).ignore();
      }
      closeStreams();
      // Clean up subscriptions.
      for (final sub in subscriptions) {
        unawaited(sub.cancel());
      }
    }).ignore();
  }

  // Listen for messages from the WebSocket.
  final messageSub = webSocketChannel.stream.listen(
    (data) {
      if (config.signal?.isCancelled ?? false) return;
      if (!messagesController.isClosed) messagesController.add(data);
    },
    onError: (Object error) {
      if (config.signal?.isCancelled ?? false) return;
      if (!errorsController.isClosed) errorsController.addError(error);
    },
    onDone: () {
      // Connection closed unexpectedly.
      final closeCode = webSocketChannel.closeCode;
      if (!(config.signal?.isCancelled ?? false) &&
          closeCode != null &&
          closeCode != normalClosureCode) {
        if (!errorsController.isClosed) {
          errorsController.add(
            SolanaError(
              SolanaErrorCode.rpcSubscriptionsChannelConnectionClosed,
              {
                'code': closeCode,
                'reason': webSocketChannel.closeReason ?? '',
              },
            ),
          );
        }
      }
      closeStreams();
    },
  );
  subscriptions.add(messageSub);

  return _WebSocketRpcChannel(
    messagesController: messagesController,
    errorsController: errorsController,
    webSocketChannel: webSocketChannel,
    isClosed: () => isClosed || (config.signal?.isCancelled ?? false),
  );
}

/// Validates a WebSocket endpoint using the channel's transport and private
/// IP-literal security policy, and returns [url] unchanged.
///
/// This is useful for WebSocket clients that need the same URL policy but
/// manage their own protocol session. The private-host check is best effort:
/// it does not resolve DNS names.
Uri validateWebSocketUrl(
  Uri url, {
  bool allowInsecureWs = false,
  bool allowPrivateHosts = false,
}) {
  _validateWebSocketUrl(
    url,
    allowInsecureWs: allowInsecureWs,
    allowPrivateHosts: allowPrivateHosts,
  );
  return url;
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

    if (isProduction) {
      throw ArgumentError.value(
        url.toString(),
        'url',
        'Insecure WebSocket endpoints are not allowed in release mode. '
            'Use a wss:// URL instead.',
      );
    }

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
  '0:0:0:0:0:0:0:0',
  '0:0:0:0:0:0:0:1',
};

/// Throws [ArgumentError] if [url] targets a private/internal host.
///
/// This is a best-effort SSRF mitigation. It blocks known private hostnames
/// and non-public IP-literal ranges. It does NOT perform DNS resolution.
void _assertHostIsNotPrivate(Uri url) {
  // DNS's trailing root label does not change a destination's identity.
  final rawHost = url.host.toLowerCase();
  final host = rawHost.endsWith('.')
      ? rawHost.substring(0, rawHost.length - 1)
      : rawHost;

  if (_blockedHostnames.contains(host)) {
    throw ArgumentError.value(
      url.toString(),
      'url',
      'WebSocket URL must not target a private or loopback host.',
    );
  }

  // IPv4 private ranges: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16
  if (_isPrivateIpv4(host) || _looksLikeNonCanonicalIpv4(host)) {
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
  final third = int.tryParse(parts[2]);
  final fourth = int.tryParse(parts[3]);
  if (first == null ||
      second == null ||
      third == null ||
      fourth == null ||
      first < 0 ||
      first > 255 ||
      second < 0 ||
      second > 255 ||
      third < 0 ||
      third > 255 ||
      fourth < 0 ||
      fourth > 255) {
    return false;
  }

  // Unspecified, loopback, and carrier-grade NAT.
  if (first == 0 || first == 127) return true;
  if (first == 100 && second >= 64 && second <= 127) return true;

  // 10.0.0.0/8
  if (first == 10) return true;

  // 172.16.0.0/12
  if (first == 172 && second >= 16 && second <= 31) return true;

  // 192.168.0.0/16
  if (first == 192 && second == 168) return true;

  // 169.254.0.0/16 (link-local)
  if (first == 169 && second == 254) return true;

  // IETF protocol assignments and TEST-NET ranges are not globally routable.
  if (first == 192 && second == 0 && third == 0) return true;
  if (first == 192 && second == 0 && third == 2) return true;
  if (first == 198 && (second == 18 || second == 19)) return true;
  if (first == 198 && second == 51 && third == 100) return true;
  if (first == 203 && second == 0 && third == 113) return true;

  // Multicast, reserved, and limited broadcast ranges.
  if (first >= 224) return true;

  return false;
}

bool _looksLikeNonCanonicalIpv4(String host) {
  // Reject alternate numeric forms such as 127.1, 2130706433, octal, and
  // hexadecimal. Different socket stacks normalize these differently, which
  // makes literal-only SSRF filters easy to bypass.
  if (RegExp(r'^\d+(?:\.\d+){0,3}$').hasMatch(host)) {
    final parts = host.split('.');
    if (parts.length != 4) return true;
    return parts.any(
      (part) => part.length > 1 && part.startsWith('0'),
    );
  }
  return RegExp(
    r'^(?:0x[0-9a-f]+|\d+)(?:\.(?:0x[0-9a-f]+|\d+)){0,3}$',
    caseSensitive: false,
  ).hasMatch(host);
}

bool _isPrivateIpv6(String host) {
  if (!host.contains(':')) return false;

  // Compare bytes so compressed/expanded zero groups and hexadecimal embedded
  // IPv4 spellings cannot evade the private-address policy.
  final address = Uri.parseIPv6Address(
    host.replaceAll('[', '').replaceAll(']', '').split('%').first,
  );
  final hasIpv4Prefix = address.take(10).every((byte) => byte == 0);
  final isCompatible = address[10] == 0 && address[11] == 0;
  final isMapped = address[10] == 0xff && address[11] == 0xff;

  if (hasIpv4Prefix && (isCompatible || isMapped)) {
    // Includes the unspecified and loopback IPv6 addresses (:: and ::1).
    return _isPrivateIpv4(address.skip(12).join('.'));
  }

  // fc00::/7 unique-local; fe80::/10 link-local; ff00::/8 multicast.
  if ((address[0] & 0xfe) == 0xfc || address[0] == 0xff) {
    return true;
  }

  if (address[0] == 0xfe && (address[1] & 0xc0) == 0x80) {
    return true;
  }

  // Documentation range; never a legitimate public endpoint.
  return address[0] == 0x20 &&
      address[1] == 0x01 &&
      address[2] == 0x0d &&
      address[3] == 0xb8;
}

class _WebSocketRpcChannel implements RpcSubscriptionsChannel {
  _WebSocketRpcChannel({
    required this._messagesController,
    required this._errorsController,
    required this._webSocketChannel,
    required this._isClosed,
  });

  final StreamController<Object?> _messagesController;
  final StreamController<Object?> _errorsController;
  final WebSocketChannel _webSocketChannel;
  final bool Function() _isClosed;

  @override
  NotificationStreams get streams => NotificationStreams(
    notifications: _messagesController.stream,
    errors: _errorsController.stream,
  );

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
