---
title: Quick Start
description: Connect to RPC, create a signer, and read your first typed Solana data.
---

This page gives you a fast tour of the three building blocks most apps start with:

1. a typed RPC client
2. a signer
3. an account read

<!-- {=docsCreateRpcClientSection} -->

## Create an RPC client

Start with a typed RPC client. It gives you method-specific helpers instead of
building raw JSON-RPC requests by hand.

```dart
import 'package:solana_kit/solana_kit.dart';

final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');

final slot = await rpc.getSlot().send();
final latestBlockhash = await rpc.getLatestBlockhash().send();

print('Current slot: $slot');
print('Latest blockhash: ${latestBlockhash.value.blockhash}');
```

Use `solana_kit_rpc_subscriptions` alongside `solana_kit_rpc` when you also
need websocket notifications for accounts, signatures, logs, or slots.

<!-- {/docsCreateRpcClientSection} -->

<!-- {=docsGenerateSignerSection} -->

## Generate a signer

Most app flows need a signer for fee payment, message signing, or transaction
submission. `generateKeyPair()` creates a new Ed25519 key pair and returns a
`KeyPairSigner`.

```dart
import 'package:solana_kit/solana_kit.dart';

final signer = await generateKeyPair();

print('Address: ${signer.address}');
```

Use key-pair signers for local development, testing, and server-side flows.
For wallet-driven applications, you can also model fee-payer, partial, and
sending signers explicitly with `solana_kit_signers`.

<!-- {/docsGenerateSignerSection} -->

<!-- {=docsFetchAccountSection} -->

## Fetch an account

Use `fetchEncodedAccount` when you want the raw account bytes plus its Solana
metadata. Decode it later with the codec or parser that matches your program.

```dart
import 'dart:typed_data';

import 'package:solana_kit/solana_kit.dart';

final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
const address = Address('11111111111111111111111111111111');

final maybeAccount = await fetchEncodedAccount(rpc, address);

switch (maybeAccount) {
  case ExistingAccount<Uint8List>(:final account):
    print('Owner: ${account.programAddress}');
    print('Bytes: ${account.data.length}');
  case NonExistingAccount():
    print('No account exists at $address');
}
```

Use `fetchJsonParsedAccount` when the RPC can return a structured
`jsonParsed` representation for a well-known program.

<!-- {/docsFetchAccountSection} -->

## What to read next

- [Create Instructions](create-instructions)
- [Build a Transaction](build-a-transaction)
- [First Transaction](first-transaction)
- [RPC and Subscriptions](../core/rpc-and-subscriptions)
- [Accounts](../core/accounts)
