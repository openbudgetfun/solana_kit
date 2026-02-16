# solana_kit_rpc_subscriptions

Subscription client for the Solana Kit Dart SDK -- the composition layer that ties together WebSocket channels, the subscriptions API, JSON serialization, and error handling.

This is the Dart port of [`@solana/rpc-subscriptions`](https://github.com/anza-xyz/kit/tree/main/packages/rpc-subscriptions) from the Solana TypeScript SDK.

## Installation

Add `solana_kit_rpc_subscriptions` to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_rpc_subscriptions:
```

Or, if you are using the umbrella package:

```yaml
dependencies:
  solana_kit:
```

## Usage

### Creating a subscription client

The primary entry point is `createSolanaRpcSubscriptions`, which composes a fully-featured subscription client with BigInt-safe JSON serialization, autopinging, channel pooling, and subscription coalescing.

```dart
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';

void main() async {
  // Create a subscription client for devnet.
  final subscriptions = createSolanaRpcSubscriptions(
    'wss://api.devnet.solana.com',
  );

  // Subscribe to account notifications.
  final controller = AbortController();
  final pending = subscriptions.request('accountNotifications', [
    '11111111111111111111111111111111',
    {'encoding': 'base64', 'commitment': 'confirmed'},
  ]);

  final stream = await pending.subscribe(
    RpcSubscribeOptions(abortSignal: controller.signal),
  );

  await for (final notification in stream) {
    print('Account changed: $notification');
    // Unsubscribe after the first notification.
    controller.abort();
  }
}
```

### Including unstable subscription methods

To access unstable subscription methods like `blockNotifications`, `slotsUpdatesNotifications`, and `voteNotifications`, use `createSolanaRpcSubscriptionsUnstable`:

```dart
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';

void main() async {
  final subscriptions = createSolanaRpcSubscriptionsUnstable(
    'wss://api.devnet.solana.com',
  );

  final controller = AbortController();
  final pending = subscriptions.request('slotsUpdatesNotifications');

  final stream = await pending.subscribe(
    RpcSubscribeOptions(abortSignal: controller.signal),
  );

  await for (final notification in stream) {
    print('Slot update: $notification');
    controller.abort();
  }
}
```

### Customizing channel configuration

The `DefaultRpcSubscriptionsChannelConfig` class lets you tune connection pooling, autopinging intervals, and send buffer sizes.

```dart
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';

void main() {
  final subscriptions = createSolanaRpcSubscriptions(
    'wss://api.mainnet-beta.solana.com',
    DefaultRpcSubscriptionsChannelConfig(
      url: 'wss://api.mainnet-beta.solana.com',
      intervalMs: 10000, // Ping every 10 seconds.
      maxSubscriptionsPerChannel: 200, // More subs per channel.
      minChannels: 2, // Start with 2 channels.
      sendBufferHighWatermark: 256 * 1024, // 256KB send buffer.
    ),
  );
}
```

### Building from a custom transport

When you need full control over the transport layer, use `createSolanaRpcSubscriptionsFromTransport`:

```dart
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';

void main() {
  // Create a custom transport with subscription coalescing.
  final transport = createDefaultRpcSubscriptionsTransport(
    DefaultRpcSubscriptionsTransportConfig(
      createChannel: createDefaultSolanaRpcSubscriptionsChannelCreator(
        DefaultRpcSubscriptionsChannelConfig(
          url: 'wss://api.devnet.solana.com',
        ),
      ),
    ),
  );

  final subscriptions = createSolanaRpcSubscriptionsFromTransport(transport);
}
```

### Subscription coalescing

When multiple callers subscribe to the same notification with the same parameters, the coalescer deduplicates them into a single server-side subscription. This happens automatically with `createSolanaRpcSubscriptions`.

```dart
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';

void main() async {
  final subscriptions = createSolanaRpcSubscriptions(
    'wss://api.devnet.solana.com',
  );

  // Both subscriptions share a single server-side subscription
  // because they have the same method and params.
  final controller1 = AbortController();
  final pending1 = subscriptions.request('slotNotifications');
  final stream1 = await pending1.subscribe(
    RpcSubscribeOptions(abortSignal: controller1.signal),
  );

  final controller2 = AbortController();
  final pending2 = subscriptions.request('slotNotifications');
  final stream2 = await pending2.subscribe(
    RpcSubscribeOptions(abortSignal: controller2.signal),
  );

  // Both streams receive the same notifications.
  stream1.listen((n) => print('Listener 1: $n'));
  stream2.listen((n) => print('Listener 2: $n'));
}
```

## API Reference

### Factory functions

| Function                                                                                                  | Description                                                                                          |
| --------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `createSolanaRpcSubscriptions(String clusterUrl, [DefaultRpcSubscriptionsChannelConfig? config])`         | Creates a fully-featured subscription client with BigInt JSON, autopinging, pooling, and coalescing. |
| `createSolanaRpcSubscriptionsUnstable(String clusterUrl, [DefaultRpcSubscriptionsChannelConfig? config])` | Same as above, but includes unstable subscription methods.                                           |
| `createSolanaRpcSubscriptionsFromTransport(RpcSubscriptionsTransport transport)`                          | Creates a subscription client from a custom transport.                                               |
| `createSubscriptionRpc(RpcSubscriptionsConfig config)`                                                    | Low-level factory from an API and transport pair.                                                    |
| `createDefaultRpcSubscriptionsTransport(DefaultRpcSubscriptionsTransportConfig config)`                   | Creates a transport with subscription coalescing from a channel creator.                             |
| `createRpcSubscriptionsTransportFromChannelCreator(RpcSubscriptionsChannelCreator creator)`               | Creates a transport from a raw channel creator.                                                      |

### Channel creators

| Function                                                                              | Description                                                                           |
| ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `createDefaultSolanaRpcSubscriptionsChannelCreator(config)`                           | Creates a channel creator with BigInt JSON serialization, autopinging, and pooling.   |
| `createDefaultRpcSubscriptionsChannelCreator(config)`                                 | Creates a channel creator with standard JSON serialization, autopinging, and pooling. |
| `getChannelPoolingChannelCreator(creator, {maxSubscriptionsPerChannel, minChannels})` | Wraps a channel creator with connection pooling.                                      |
| `getRpcSubscriptionsChannelWithAutoping({abortSignal, channel, intervalMs})`          | Wraps a channel to send periodic ping messages.                                       |
| `getRpcSubscriptionsTransportWithSubscriptionCoalescing(transport)`                   | Wraps a transport to deduplicate identical subscriptions.                             |

### Classes

| Class                                  | Description                                                                                                  |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `RpcSubscriptions`                     | The subscription client. Call `request(notificationName, [params])` to create pending subscription requests. |
| `PendingRpcSubscriptionsRequest<T>`    | A pending request. Call `subscribe(options)` to start receiving notifications as a `Stream<T>`.              |
| `RpcSubscribeOptions`                  | Options for subscribing, including an `AbortSignal`.                                                         |
| `RpcSubscriptionsPlan<T>`              | Describes a subscription plan with request details and execution logic.                                      |
| `DefaultRpcSubscriptionsChannelConfig` | Configuration for channel creation: URL, ping interval, pool size, buffer size.                              |
| `RpcSubscriptionsRequest`              | A subscription request with a method name and parameters.                                                    |
| `RpcSubscriptionsTransportConfig`      | Configuration passed to a transport function.                                                                |

### Type aliases

| Type                             | Description                                                                                         |
| -------------------------------- | --------------------------------------------------------------------------------------------------- |
| `RpcSubscriptionsTransport`      | `Future<DataPublisher> Function(RpcSubscriptionsTransportConfig)` -- the transport function type.   |
| `RpcSubscriptionsChannelCreator` | `Future<RpcSubscriptionsChannel> Function({required AbortSignal abortSignal})` -- creates channels. |
