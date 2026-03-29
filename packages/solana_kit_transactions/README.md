# solana_kit_transactions

[![pub package](https://img.shields.io/pub/v/solana_kit_transactions.svg)](https://pub.dev/packages/solana_kit_transactions)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_transactions/latest/)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Compile, sign, encode, and decode Solana transactions.

This is the Dart port of [`@solana/transactions`](https://github.com/anza-xyz/kit/tree/main/packages/transactions) from the Solana TypeScript SDK.

<!-- {=packageInstallSection:"solana_kit_transactions"} -->

## Installation

Install the package directly:

```bash
dart pub add solana_kit_transactions
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_transactions"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_transactions
- API reference: https://pub.dev/documentation/solana_kit_transactions/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_transactions
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_transactions

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Compiling a transaction

A `Transaction` is compiled from a `TransactionMessage` that has a fee payer and a lifetime constraint. The compiled transaction includes the wire-format message bytes and a signatures map with `null` entries for each required signer.

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

final myAddress = Address('mpngsFd4tmbUfzDYJayjKZwZcaR7aWb2793J6grLsGu');

// Build a transaction message (see solana_kit_transaction_messages).
final txMessage = TransactionMessage(
  version: TransactionVersion.v0,
  feePayer: myAddress,
  instructions: [
    Instruction(
      programAddress: Address('11111111111111111111111111111111'),
      accounts: [
        AccountMeta(address: myAddress, role: AccountRole.writableSigner),
        AccountMeta(
          address: Address('GDhQoTpNbYUaCAjFKBMCPCdrCaKaLiSqhx5M7r4SrEFy'),
          role: AccountRole.writable,
        ),
      ],
      data: Uint8List.fromList([2, 0, 0, 0, 0, 202, 154, 59, 0, 0, 0, 0]),
    ),
  ],
  lifetimeConstraint: BlockhashLifetimeConstraint(
    blockhash: 'EkSnNWid2cvwEVnVx9aBqawnmiCNiDgp3gUdkDPTKN1N',
    lastValidBlockHeight: BigInt.from(300000),
  ),
);

// Compile the message into a transaction. Signatures are initially null.
final transaction = compileTransaction(txMessage);
print(transaction.signatures); // {Address('mpngs...'): null}
```

### Signing transactions

Sign a transaction with one or more `KeyPair` objects. Use `signTransaction` to sign and assert all required signatures are present, or `partiallySignTransaction` when you only have a subset of signers.

```dart
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

Future<void> main() async {
  // Generate an Ed25519 key pair for the fee payer.
  final keyPair = await generateKeyPair();

  // Sign the transaction (throws if not all signers are provided).
  final signedTx = await signTransaction([keyPair], transaction);

  // Or partially sign (does not require all signers).
  final partiallySigned = await partiallySignTransaction(
    [keyPair],
    transaction,
  );

  // Check if a transaction is fully signed.
  print(isFullySignedTransaction(signedTx)); // true
}
```

### Getting the transaction signature

The transaction signature (also called the transaction ID) is the fee payer's signature:

```dart
final signature = getSignatureFromTransaction(signedTx);
print(signature); // The base58-encoded transaction signature.
```

### Checking the transaction size

Solana transactions must fit within 1232 bytes (the MTU minus network header overhead). This package provides helpers to check and assert size constraints:

```dart
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

// Get the size in bytes of a compiled transaction.
final size = getTransactionSize(transaction);
print(size);

// Check against the 1232-byte limit.
print(isTransactionWithinSizeLimit(transaction)); // true or false

// Throws SolanaError if the transaction exceeds the size limit.
assertIsTransactionWithinSizeLimit(transaction);

// You can also check the size directly from a TransactionMessage,
// which compiles it internally.
final messageSize = getTransactionMessageSize(txMessage);
print(isTransactionMessageWithinSizeLimit(txMessage));
```

### Encoding and decoding transactions

Use codecs to convert transactions to and from their wire format:

```dart
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

void main() {
  // Encode a transaction to bytes (wire format).
  final encoder = getTransactionEncoder();
  final wireBytes = encoder.encode(signedTx);

  // Decode a transaction from wire bytes.
  final decoder = getTransactionDecoder();
  final (decodedTx, _) = decoder.read(wireBytes, 0);

  // Or use the combined codec.
  final codec = getTransactionCodec();
  final roundTripped = codec.decode(codec.encode(signedTx));
}
```

### Getting a base64 wire transaction

For sending transactions via RPC, you typically need the base64-encoded wire transaction:

```dart
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

void main() {
  final base64Wire = getBase64EncodedWireTransaction(signedTx);
  print(base64Wire); // Base64-encoded string ready for sendTransaction RPC.
}
```

### Sendable transaction checks

A transaction is sendable if it is fully signed and within the size limit:

```dart
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

void main() {
  print(isSendableTransaction(signedTx)); // true

  // Throws if not sendable.
  assertIsSendableTransaction(signedTx);
}
```

### Transaction lifetime constraints

Transactions carry lifetime metadata. This package provides types and checkers for both blockhash and durable nonce lifetimes:

```dart
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

void main() {
  // Check blockhash lifetime.
  print(isTransactionWithBlockhashLifetime(transaction)); // true

  // Check durable nonce lifetime.
  print(isTransactionWithDurableNonceLifetime(transaction)); // false
}
```

## API Reference

### Classes

- **`Transaction`** -- A compiled transaction with `messageBytes` and `signatures` map.
- **`TransactionWithLifetime`** -- Extends `Transaction` with a `lifetimeConstraint` (either `TransactionBlockhashLifetime` or `TransactionDurableNonceLifetime`).
- **`TransactionBlockhashLifetime`** -- Blockhash-based lifetime with `blockhash` and `lastValidBlockHeight`.
- **`TransactionDurableNonceLifetime`** -- Durable nonce lifetime with `nonce` and `nonceAccountAddress`.

### Functions

| Function                                      | Description                                                        |
| --------------------------------------------- | ------------------------------------------------------------------ |
| `compileTransaction`                          | Compiles a `TransactionMessage` into a `TransactionWithLifetime`.  |
| `signTransaction`                             | Signs a transaction and asserts it is fully signed.                |
| `partiallySignTransaction`                    | Signs a transaction with a subset of required signers.             |
| `isFullySignedTransaction`                    | Returns `true` if all signers have provided signatures.            |
| `assertIsFullySignedTransaction`              | Throws if any signer signature is missing.                         |
| `getSignatureFromTransaction`                 | Returns the fee payer's signature (the transaction ID).            |
| `getTransactionSize`                          | Returns the encoded size in bytes.                                 |
| `isTransactionWithinSizeLimit`                | Returns `true` if the transaction fits within 1232 bytes.          |
| `assertIsTransactionWithinSizeLimit`          | Throws if the transaction exceeds the size limit.                  |
| `getTransactionMessageSize`                   | Returns the compiled transaction size from a `TransactionMessage`. |
| `isTransactionMessageWithinSizeLimit`         | Returns `true` if the compiled message fits within the limit.      |
| `assertIsTransactionMessageWithinSizeLimit`   | Throws if the compiled message exceeds the limit.                  |
| `isSendableTransaction`                       | Returns `true` if fully signed and within size limit.              |
| `assertIsSendableTransaction`                 | Throws if the transaction is not sendable.                         |
| `getTransactionEncoder`                       | Returns a wire-format encoder for `Transaction`.                   |
| `getTransactionDecoder`                       | Returns a wire-format decoder for `Transaction`.                   |
| `getTransactionCodec`                         | Returns a combined encoder/decoder codec.                          |
| `getBase64EncodedWireTransaction`             | Returns a base64-encoded wire transaction string.                  |
| `isTransactionWithBlockhashLifetime`          | Returns `true` if the transaction has a blockhash lifetime.        |
| `assertIsTransactionWithBlockhashLifetime`    | Throws if the transaction does not have a blockhash lifetime.      |
| `isTransactionWithDurableNonceLifetime`       | Returns `true` if the transaction has a durable nonce lifetime.    |
| `assertIsTransactionWithDurableNonceLifetime` | Throws if the transaction does not have a durable nonce lifetime.  |

### Constants

- **`transactionPacketSize`** -- Maximum network packet size: `1280` bytes.
- **`transactionPacketHeader`** -- Network header overhead: `48` bytes (IPv6 + fragment header).
- **`transactionSizeLimit`** -- Maximum transaction content size: `1232` bytes.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_transactions"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_transactions/solana_kit_transactions.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_transactions`.

- Import path: `package:solana_kit_transactions/solana_kit_transactions.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
