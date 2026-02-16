# solana_kit_rpc_subscriptions_channel_websocket

WebSocket channel transport for Solana RPC subscriptions in the Solana Kit Dart SDK.

This is the Dart port of [`@solana/rpc-subscriptions-channel-websocket`](https://github.com/anza-xyz/kit/tree/main/packages/rpc-subscriptions-channel-websocket) from the Solana TypeScript SDK.

## Installation

Add `solana_kit_rpc_subscriptions_channel_websocket` to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_rpc_subscriptions_channel_websocket:
```

Or, if you are using the umbrella package:

```yaml
dependencies:
  solana_kit:
```

## Usage

### Creating a WebSocket channel

The `createWebSocketChannel` function opens a WebSocket connection and returns an `RpcSubscriptionsChannel` that supports the `DataPublisher` interface for receiving messages and errors.

```dart
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';

void main() async {
  final controller = AbortController();

  final channel = await createWebSocketChannel(
    WebSocketChannelConfig(
      url: Uri.parse('wss://api.devnet.solana.com'),
      signal: controller.signal,
    ),
  );

  // Subscribe to incoming messages.
  channel.on('message', (data) {
    print('Received: $data');
  });

  // Subscribe to errors.
  channel.on('error', (error) {
    print('Error: $error');
  });

  // Send a message through the channel.
  await channel.send('{"jsonrpc":"2.0","id":1,"method":"slotSubscribe"}');

  // Later, close the channel.
  controller.abort();
}
```

### Abort lifecycle management

The `AbortController` and `AbortSignal` classes manage the lifecycle of WebSocket connections. When you abort the signal, the WebSocket is closed with a normal closure code (1000).

```dart
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';

void main() async {
  final controller = AbortController();

  // Check signal state.
  print(controller.signal.isAborted); // false

  // Open a channel with the signal.
  final channel = await createWebSocketChannel(
    WebSocketChannelConfig(
      url: Uri.parse('wss://api.devnet.solana.com'),
      signal: controller.signal,
    ),
  );

  // Abort with a reason.
  controller.abort('User cancelled');

  print(controller.signal.isAborted); // true
  print(controller.signal.reason); // 'User cancelled'

  // Sending on a closed channel throws SolanaError with code
  // rpcSubscriptionsChannelConnectionClosed.
}
```

### Waiting for abort asynchronously

The `AbortSignal` provides a `future` that completes when the signal is aborted. This is useful for composing with other async operations.

```dart
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';

void main() async {
  final controller = AbortController();

  // Wait for the signal to fire.
  controller.signal.future.then((_) {
    print('Signal was aborted!');
  });

  // Abort after some delay.
  await Future<void>.delayed(Duration(seconds: 5));
  controller.abort();
  // Prints: 'Signal was aborted!'
}
```

### Configuring the send buffer

The `sendBufferHighWatermark` parameter controls how much data is allowed into the WebSocket's send buffer before messages are queued on the client.

```dart
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';

void main() async {
  final controller = AbortController();

  final channel = await createWebSocketChannel(
    WebSocketChannelConfig(
      url: Uri.parse('wss://api.devnet.solana.com'),
      sendBufferHighWatermark: 256 * 1024, // 256KB buffer.
      signal: controller.signal,
    ),
  );

  // Use the channel...
  controller.abort();
}
```

### Error handling

The function throws `SolanaError` in several situations:

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';

void main() async {
  final controller = AbortController();

  try {
    final channel = await createWebSocketChannel(
      WebSocketChannelConfig(
        url: Uri.parse('wss://invalid-host.example.com'),
        signal: controller.signal,
      ),
    );
  } on SolanaError catch (e) {
    if (isSolanaError(e, SolanaErrorCode.rpcSubscriptionsChannelFailedToConnect)) {
      print('Connection failed');
    }
  }

  // Already-aborted signals prevent connection.
  final abortedController = AbortController()..abort();
  try {
    await createWebSocketChannel(
      WebSocketChannelConfig(
        url: Uri.parse('wss://api.devnet.solana.com'),
        signal: abortedController.signal,
      ),
    );
  } on SolanaError catch (e) {
    if (isSolanaError(
      e,
      SolanaErrorCode.rpcSubscriptionsChannelConnectionClosed,
    )) {
      print('Channel was already closed');
    }
  }
}
```

## API Reference

### Functions

| Function                                                | Description                                                                 |
| ------------------------------------------------------- | --------------------------------------------------------------------------- |
| `createWebSocketChannel(WebSocketChannelConfig config)` | Opens a WebSocket connection and returns `Future<RpcSubscriptionsChannel>`. |

### Classes

| Class                     | Description                                                                                                                                      |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `RpcSubscriptionsChannel` | An interface extending `DataPublisher` with a `send(Object)` method for outgoing messages. Supports `on('message', ...)` and `on('error', ...)`. |
| `WebSocketChannelConfig`  | Configuration: `url` (Uri), `sendBufferHighWatermark` (int, default 128KB), `signal` (AbortSignal?).                                             |
| `AbortController`         | Creates and manages an `AbortSignal`. Call `abort([reason])` to fire the signal.                                                                 |
| `AbortSignal`             | Represents an abort signal. Properties: `isAborted`, `reason`, `future`.                                                                         |

### Constants

| Constant            | Description                                                              |
| ------------------- | ------------------------------------------------------------------------ |
| `normalClosureCode` | `1000` -- the RFC 6455 normal closure code used when aborting a channel. |
