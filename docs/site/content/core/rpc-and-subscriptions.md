---
title: RPC and Subscriptions
description: Typed RPC methods, subscriptions, and transport guidance.
---

Use `solana_kit_rpc` for request orchestration and `solana_kit_rpc_subscriptions` for websocket notifications.

<!-- {=docsTypedRpcSolanaKitSection} -->

### Typed RPC methods

When working with an `Rpc`, prefer typed convenience helpers over stringly method calls:

```dart
import 'package:solana_kit/solana_kit.dart';

final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');
final slot = await rpc.getSlot().send();
final blockHeight = await rpc.getBlockHeight().send();
final epochInfo = await rpc.getEpochInfo().send();
```

These helpers forward to canonical params builders in `solana_kit_rpc_api` and return lazy `PendingRpcRequest<T>` values.

<!-- {/docsTypedRpcSolanaKitSection} -->

## Subscription Clients

Use websocket subscriptions for account updates, logs, and slot notifications.

- `solana_kit_rpc_subscriptions`: high-level subscription client.
- `solana_kit_rpc_subscriptions_api`: typed subscription method definitions.
- `solana_kit_rpc_subscriptions_channel_websocket`: websocket transport implementation.

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
