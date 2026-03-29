---
title: First Transaction
description: Build, sign, send, and confirm a Solana transaction with explicit typed steps.
---

A production-grade transaction flow usually has these phases:

1. create or obtain the required signers
2. fetch a recent blockhash
3. build a transaction message
4. compile and sign the transaction
5. send the signed transaction
6. confirm the result

This guide focuses on the shape of the workflow rather than a specific on-chain program client.

## 1. Create the dependencies

```dart
import 'dart:typed_data';

import 'package:solana_kit/solana_kit.dart';

final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
final signer = await generateKeyPair();
final latestBlockhash = await rpc.getLatestBlockhash().send();
```

## 2. Build an instruction

```dart
final instruction = Instruction(
  programAddress: const Address('11111111111111111111111111111111'),
  accounts: [
    AccountMeta(address: signer.address, role: AccountRole.writableSigner),
  ],
  data: Uint8List(0),
);
```

For a real application, this would usually come from a typed program client or an instruction builder backed by codecs.

## 3. Build the transaction message

```dart
final message = createTransactionMessage()
    .pipe(setTransactionMessageFeePayerSigner(signer))
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

## 4. Sign the message

```dart
final signedTransaction = await signTransactionMessageWithSigners(message);
```

This high-level helper resolves the signers attached to the message, compiles the transaction, and asserts that every required signature is present.

## 5. Send and confirm

<!-- {=docsSendAndConfirmSection} -->

## Send and confirm a signed transaction

Once you have a signed `Transaction`, use the additive confirmation helper for
an end-to-end “send then wait for confirmation” flow.

```dart
import 'package:solana_kit/solana_kit.dart';

final signature = await sendAndConfirmTransaction(
  rpc: rpc,
  transaction: signedTransaction,
);

print('Confirmed signature: ${signature.value}');
```

For lower-level control, `solana_kit_transaction_confirmation` also exposes
strategy factories for block-height expiry, durable nonce invalidation,
signature notifications, and timeout racing.

<!-- {/docsSendAndConfirmSection} -->

## Why this explicit flow is useful

The workflow may look more verbose than a single convenience function, but it gives you strong control over:

- signer attachment and signer role modeling
- blockhash expiry handling
- instruction ordering
- testability of each step
- substitution of wallet/mobile/remote signing behavior

## Next steps

- [Transactions](../core/transactions)
- [Signers](../core/signers)
- [Build a Token Transfer Flow](../guides/build-token-transfer-flow)
