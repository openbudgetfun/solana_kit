/// WebSocket channel for RPC subscriptions for the Solana Kit Dart SDK.
///
/// This package provides a WebSocket-based transport channel for Solana RPC
/// subscriptions. It is the Dart port of the TypeScript
/// `@solana/rpc-subscriptions-channel-websocket` package.
///
/// The primary entry point is `createWebSocketChannel`, which opens a WebSocket
/// connection and returns an `RpcSubscriptionsChannel` that provides:
///
/// - `streams.notifications` to receive incoming messages
/// - `streams.errors` to receive error events
/// - `send(message)` to send outgoing messages
///
/// Use `CancellationTokenSource` and `CancellationToken` to manage the channel
/// lifecycle:
///
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
/// await channel.send('hello');
///
/// // Close the channel:
/// source.cancel();
/// ```
library;

export 'package:solana_kit_subscribable/solana_kit_subscribable.dart'
    show CancellationToken, CancellationTokenSource;

export 'src/websocket_channel.dart';
