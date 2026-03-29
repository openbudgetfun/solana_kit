---
title: Signers
description: Model fee payers, partial signers, modifying signers, and sending signers explicitly.
---

Solana Kit treats signers as capabilities, not just as key material. That gives you a better fit for real-world flows involving wallets, mobile adapters, remote signers, and multi-party signing.

## Why the signer model matters

In many SDKs, “a signer” is just a private key. In production Solana apps, that is often not enough.

You may need to represent:

- a local key pair that signs directly
- a wallet that signs and sends in one step
- a system that mutates the transaction before signing
- a fee payer that differs from another signing authority
- a partially signed transaction that must be completed later

## Common signer interfaces

- **`KeyPairSigner`** — local Ed25519 key pair plus signing methods
- **`FeePayerSigner`** — signer designated as the fee payer
- **`TransactionPartialSigner`** — can contribute one or more transaction signatures
- **`TransactionModifyingSigner`** — can edit a transaction before signature application
- **`TransactionSendingSigner`** — can sign and submit a transaction
- **`MessagePartialSigner`** — signs off-chain messages instead of transactions

## Build a transaction around signers

When your signers live on the transaction message itself, the message-level
helpers are still the most ergonomic path.

```dart
final signer = await generateKeyPair();

final message = createTransactionMessage()
    .pipe(setTransactionMessageFeePayerSigner(signer));
```

When signer resolution happens outside the message, drop to the explicit
transaction-level helpers:

<!-- {=docsTransactionSignerHelpersSection} -->

## Sign a compiled transaction with explicit signers

Use the transaction-level signer helpers when your signers are resolved outside
of the message itself or when you need to work with a compiled `Transaction`
directly.

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> partiallySign(
  List<Object> signers,
  Transaction transaction,
) async {
  final partiallySigned = await partiallySignTransactionWithSigners(
    signers,
    transaction,
  );

  print(partiallySigned.signatures.length);
}
```

This is especially useful for wallet adapters, remote signers, or orchestration
layers that gather signatures in more than one step.

<!-- {/docsTransactionSignerHelpersSection} -->

## Why explicit roles help

This separation gives you:

- better modeling for wallet integrations
- more honest test seams
- cleaner handling of partial signatures
- safer transaction pipelines for complex orchestration

## Read next

- [Generate a Signer](../getting-started/generate-a-signer)
- [First Transaction](../getting-started/first-transaction)
- [Transactions](transactions)
