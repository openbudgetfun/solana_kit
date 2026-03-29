---
title: Generate a Signer
description: Create local key-pair signers and understand the signer roles used across the SDK.
---

Signers are the bridge between transaction intent and cryptographic authorization.

In Solana Kit, the signer model is intentionally more expressive than “just a key pair” because real applications often need to distinguish:

- a fee payer
- a partial signer
- a signer that can modify a transaction before signing
- a signer that can also send a transaction

## Start with a key-pair signer

```dart
import 'package:solana_kit/solana_kit.dart';

final signer = await generateKeyPair();

print('Signer address: ${signer.address}');
```

A generated key pair is useful for:

- local testing
- backend automation
- server-side services
- examples and fixtures

## Sign a message

```dart
import 'package:solana_kit/solana_kit.dart';

final signer = await generateKeyPair();
final message = createSignableMessage('hello from Solana Kit');

final signatures = await signer.signMessages([message]);
print('Produced ${signatures.length} signature map(s)');
```

## Attach a signer to a transaction message

```dart
import 'package:solana_kit/solana_kit.dart';

final signer = await generateKeyPair();

final message = createTransactionMessage()
    .pipe(setTransactionMessageFeePayerSigner(signer));
```

This is the most common starting point for building a signable transaction.

## Understand signer roles

`solana_kit_signers` separates roles so transaction pipelines stay explicit.

- **`KeyPairSigner`** — local Ed25519 key pair plus signing methods
- **`MessagePartialSigner`** — can sign signable off-chain messages
- **`TransactionPartialSigner`** — can sign a compiled transaction
- **`TransactionModifyingSigner`** — can mutate a transaction before signing
- **`TransactionSendingSigner`** — can sign and immediately submit a transaction
- **`FeePayerSigner`** — indicates the signer is also the transaction fee payer

This modeling matters when integrating wallets, mobile adapters, remote signers, or multi-party signing flows.

## Next steps

- [Create Instructions](create-instructions)
- [Build a Transaction](build-a-transaction)
- [Signers](../core/signers)
