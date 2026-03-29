---
title: Build a Transaction
description: Assemble a transaction message with a fee payer, a lifetime, and one or more instructions.
---

Solana Kit models transaction construction as a sequence of immutable transformations. This keeps the transaction pipeline easy to inspect and test.

<!-- {=docsBuildTransactionSection} -->

## Build a transaction message

Transaction messages are assembled incrementally. The most common pattern is:

1. Create an empty message.
2. Set the fee payer.
3. Set a lifetime constraint using a recent blockhash.
4. Append one or more instructions.

```dart
import 'dart:typed_data';

import 'package:solana_kit/solana_kit.dart';

final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
final feePayer = await generateKeyPair();
final latestBlockhash = await rpc.getLatestBlockhash().send();

final instruction = Instruction(
  programAddress: const Address('11111111111111111111111111111111'),
  accounts: [
    AccountMeta(address: feePayer.address, role: AccountRole.writableSigner),
  ],
  data: Uint8List(0),
);

final message = createTransactionMessage()
    .pipe(setTransactionMessageFeePayer(feePayer.address))
    .pipe(
      setTransactionMessageLifetimeUsingBlockhash(
        BlockhashLifetimeConstraint(
          blockhash: latestBlockhash.value.blockhash,
          lastValidBlockHeight: latestBlockhash.value.lastValidBlockHeight,
        ),
      ),
    )
    .pipe(appendTransactionMessageInstruction(instruction));
```

This separation keeps transaction construction explicit and makes it easier to
reason about fee payment, expiry, and instruction ordering.

<!-- {/docsBuildTransactionSection} -->

## Why the lifetime constraint matters

Without a recent blockhash or a durable nonce, the network cannot determine whether a transaction is still valid. Solana Kit makes lifetime setup explicit so expiry handling is not hidden behind a large helper.

### Blockhash-based lifetime

Use `BlockhashLifetimeConstraint` for the common case.

### Durable nonce lifetime

Use `setTransactionMessageLifetimeUsingDurableNonce(...)` when the transaction must remain valid until a nonce account changes.

## Compile the message

Once the message is fully assembled, compile it into the wire-level message representation:

```dart
final compiledMessage = compileTransactionMessage(message);
```

At this stage you have a canonical message layout that can be signed and serialized.

## Next steps

- [First Transaction](first-transaction)
- [Send and confirm a transaction](../core/transactions)
- [Signers](../core/signers)
