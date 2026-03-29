---
title: RPC and Subscriptions
description: Typed RPC methods, transport choices, websocket subscriptions, and production guidance.
---

`solana_kit_rpc` and `solana_kit_rpc_subscriptions` are the backbone of most application-facing Solana I/O.

Use them together when you need both:

- **request/response flows** over JSON-RPC HTTP
- **realtime notifications** over websockets

## Typed RPC requests

<!-- {=docsTypedRpcSolanaKitSection} -->

### Typed RPC methods

When you already have an `Rpc`, prefer typed convenience helpers over raw
method-name strings. They keep parameter builders and response models attached
to the method itself, which makes refactors and autocomplete significantly
safer.

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');

  final slot = await rpc.getSlot().send();
  final epochInfo = await rpc.getEpochInfo().send();
  final latestBlockhash = await rpc.getLatestBlockhash().send();

  print('Slot: $slot');
  print('Epoch: ${epochInfo['epoch']}');
  print('Latest blockhash: ${latestBlockhash['blockhash']}');
}
```

These helpers forward to canonical request builders in `solana_kit_rpc_api`,
return lazy `PendingRpcRequest<T>` values, and make it clear which Solana RPC
shape each call expects.

<!-- {/docsTypedRpcSolanaKitSection} -->

## Why typed RPC matters

Typed RPC methods give you:

- discoverable method names in IDE autocomplete
- compile-time parameter shapes
- fewer raw `Map<String, Object?>` escape hatches in application code
- reusable request logic across services and tests

## Subscription clients

Use websocket subscriptions for account changes, signature updates, program logs, and slot notifications.

Packages involved:

- `solana_kit_rpc_subscriptions` — high-level orchestration
- `solana_kit_rpc_subscriptions_api` — typed subscription method builders
- `solana_kit_rpc_subscriptions_channel_websocket` — websocket transport/channel implementation
- `solana_kit_subscribable` — stream-friendly subscription primitives

## Typical split of responsibilities

- use `rpc` for reads, writes, and transaction submission
- use `rpcSubscriptions` for realtime updates
- keep transport setup at your app boundary so you can tune timeouts, headers, or connection reuse centrally

## Large payload handling

<!-- {=docsIsolateJsonDecodeHttpSection} -->

### Optional Isolate JSON Decoding

For large Solana RPC payloads, you can offload BigInt-aware JSON parsing to a
background isolate so the main isolate stays responsive.

```dart
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

void main() {
  final transport = createHttpTransportForSolanaRpc(
    url: 'https://api.mainnet-beta.solana.com',
    decodeSolanaJsonInIsolate: true,
    solanaJsonIsolateThreshold: 262144,
  );

  print(transport);
}
```

For direct parsing, use `parseJsonWithBigIntsAsync(...)` with
`runInIsolate: true`. Reserve isolate parsing for larger payloads where the
extra hop is worth the reduced UI or server-request blocking.

<!-- {/docsIsolateJsonDecodeHttpSection} -->

## Read next

- [Quick Start](../getting-started/quick-start)
- [Accounts](accounts)
- [Transactions](transactions)
- [Build an RPC Service](../guides/build-rpc-service)
- [Build a Realtime Observer](../guides/build-realtime-observer)
