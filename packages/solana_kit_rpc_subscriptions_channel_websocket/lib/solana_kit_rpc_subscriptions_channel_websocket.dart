/// WebSocket channel for RPC subscriptions for the Solana Kit Dart SDK.
///
/// This package provides a WebSocket-based transport channel for Solana RPC
/// subscriptions. It is the Dart port of the TypeScript
/// `@solana/rpc-subscriptions-channel-websocket` package.
///
/// The primary entry point is `createWebSocketChannel`, which opens a WebSocket
/// connection and returns an `RpcSubscriptionsChannel` that provides:
///
/// - `on('message', subscriber)` to receive incoming messages
/// - `on('error', subscriber)` to receive error events
/// - `send(message)` to send outgoing messages
///
/// Use `AbortController` and `AbortSignal` to manage the channel lifecycle:
///
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
/// await channel.send('hello');
///
/// // Close the channel:
/// controller.abort();
/// ```
library;

export 'src/websocket_channel.dart';
