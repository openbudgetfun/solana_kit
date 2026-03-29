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

When working with an `Rpc`, prefer typed convenience helpers over stringly method calls:

```dart
import 'package:solana_kit/solana_kit.dart';

final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');
final slot = await rpc.getSlot().send();
final blockHeight = await rpc.getBlockHeight().send();
```

These helpers forward to canonical params builders in `solana_kit_rpc_api` and return lazy `PendingRpcRequest<T>` values.

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
background isolate.

```dart
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

final transport = createHttpTransportForSolanaRpc(
  url: 'https://api.mainnet-beta.solana.com',
  decodeSolanaJsonInIsolate: true,
  solanaJsonIsolateThreshold: 262144,
);
```

For direct parsing, use `parseJsonWithBigIntsAsync(...)` with
`runInIsolate: true`.

<!-- {/docsIsolateJsonDecodeHttpSection} -->

## Read next

- [Quick Start](../getting-started/quick-start)
- [Accounts](accounts)
- [Transactions](transactions)
- [Build an RPC Service](../guides/build-rpc-service)
- [Build a Realtime Observer](../guides/build-realtime-observer)
