---
title: Quick Start
description: Connect to RPC and execute your first typed Solana calls.
---

Create an RPC client and run strongly typed requests:

```dart
import 'package:solana_kit/solana_kit.dart';

final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');
final slot = await rpc.getSlot().send();
print('Current slot: $slot');
```

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

## Generate a Key Pair

```dart
final keyPair = await generateKeyPair();
print('Generated address: ${keyPair.address}');
```

Continue with [First Transaction](first-transaction) to build and sign a message.
