---
title: Build a Realtime Observer
description: Turn Solana websocket notifications into a reusable observer layer for your app or service.
---

Realtime apps often need a thin layer between raw websocket subscriptions and the rest of the application.

That observer layer should own:

- websocket connection setup
- subscription registration
- cancellation
- stream fanout
- reconnect/replay policy

## Step 1: create a subscription client

```dart
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';

final subscriptions = createSolanaRpcSubscriptions(
  'wss://api.devnet.solana.com',
);
```

## Step 2: register a typed subscription request

```dart
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';

final controller = AbortController();
final pending = subscriptions.slotNotifications();

final stream = await pending.subscribe(
  RpcSubscribeOptions(abortSignal: controller.signal),
);
```

## Step 3: adapt that stream to your own observer interface

```dart
class SlotObserver {
  SlotObserver(this._subscriptions);

  final RpcSubscriptions _subscriptions;

  Stream<Object?> watchSlots() async* {
    final controller = AbortController();
    final pending = _subscriptions.slotNotifications();
    final stream = await pending.subscribe(
      RpcSubscribeOptions(abortSignal: controller.signal),
    );

    yield* stream;
  }
}
```

In a production app, you would usually hold onto the abort controller so your service can cancel the subscription on shutdown or when the last listener disconnects.

## Step 4: subscribe to account or logs updates

The same pattern works for account or logs subscriptions; only the typed helper and config change.

```dart
final pending = subscriptions.accountNotifications(
  const Address('11111111111111111111111111111111'),
  const AccountNotificationsConfig(
    encoding: 'base64',
    commitment: Commitment.confirmed,
  ),
);
```

## Step 5: make reconnect policy explicit

Transport disruptions are normal. Decide up front how your observer should behave when the socket drops:

- reconnect immediately or with backoff?
- replay active subscriptions automatically?
- publish a disconnected state to downstream consumers?
- buffer, debounce, or drop noisy updates?

Keeping this logic in one observer layer prevents UI code from learning socket lifecycle rules.

## Related docs

- [RPC and Subscriptions](../core/rpc-and-subscriptions)
- [Build an RPC Service](build-rpc-service)
- [Package Catalog](../reference/package-catalog)
