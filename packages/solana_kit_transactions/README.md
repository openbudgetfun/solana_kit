# solana_kit_transactions

[![pub package](https://img.shields.io/pub/v/solana_kit_transactions.svg)](https://pub.dev/packages/solana_kit_transactions) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_transactions/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_transactions) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_transactions)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_transactions)

Compile, sign, encode, and decode Solana transactions. Wrap a compiled message with signatures, verify completeness, and produce the base64 wire format that the RPC `sendTransaction` endpoint accepts.

`Transaction` takes immutable snapshots of message and signature bytes. Retaining or mutating an input buffer cannot change the payload after review, and exposed buffers cannot be edited by partial signers. Create a new transaction to change its message. The wire codec supports legacy and v0 signatures-first envelopes and v1 message-first envelopes.

<!-- {=packageInstallSection:"solana_kit_transactions"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_transactions": ^0.9.2
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

<!-- {=docsCompileTransactionSection} -->

## Compile a transaction for signing

Once a transaction message has a fee payer, lifetime, and instructions, compile it into the wire-ready transaction shape that signers and senders consume.

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

void main() {
  final message = createTransactionMessage(version: TransactionVersion.v0)
      .withFeePayer(const Address('11111111111111111111111111111111'))
      .withBlockhashLifetime(
        BlockhashLifetimeConstraint(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
      )
      .appendInstruction(
        Instruction(
          programAddress: const Address('11111111111111111111111111111111'),
          accounts: const [
            AccountMeta(
              address: Address('11111111111111111111111111111111'),
              role: AccountRole.readonly,
            ),
          ],
          data: Uint8List(0),
        ),
      );

  final transaction = compileTransaction(message);

  print(transaction.signatures.length);
}
```

Compilation is the boundary where account ordering, signer sets, and lifetime constraints are frozen into the bytes that will actually be signed.

<!-- {/docsCompileTransactionSection} -->

## Usage

### Sign a transaction

`signTransaction` adds a signature for a given signer address to the transaction's signature map. Call it once per signer.

```dart
Future<void> main() async {
  // After compiling a message and creating a key pair signer:
  // final message = createTransactionMessage(version: TransactionVersion.v0)
  //     .withFeePayer(signer.address)
  //     .withBlockhashLifetime(...)
  //     .appendInstruction(...);
  // final transactionWithLifetime = compileTransaction(message);
  // final signed = await signTransaction(transactionWithLifetime, signer);
}
```

### Get the signature

`getSignatureFromTransaction` extracts the fee payer's signature as a `Signature` object. The transaction must be fully signed by the fee payer.

```dart
void main() {
  // After signing, extract the fee payer's signature.
  // final sig = getSignatureFromTransaction(signedTransaction);
  // print(sig.value);
}
```

### Verify signatures

`isFullySignedTransaction` checks whether every required signer has a non-null signature in the map. `partiallySignTransaction` adds a signature without requiring all signers to be present.

### Encode and decode

`getTransactionEncoder` and `getTransactionDecoder` return codec objects from `solana_kit_codecs_core`. `getTransactionCodec` returns a combined encoder/decoder. `getBase64EncodedWireTransaction` produces the base64 string accepted by `sendTransaction`.

```dart
void main() {
  // After signing, encode the transaction for the RPC.
  // final base64 = getBase64EncodedWireTransaction(signedTransaction);
  // Pass `base64` to rpc.sendTransaction.
}
```

### Lifetime constraints

`TransactionBlockhashLifetime` and `TransactionDurableNonceLifetime` are the two sealed subtypes of `TransactionLifetimeConstraint`. Guard functions check which kind a transaction carries:

- `isTransactionWithBlockhashLifetime(transaction)` returns `true` if the lifetime is blockhash-based.
- `isTransactionWithDurableNonceLifetime(transaction)` returns `true` if the lifetime is nonce-based.

### Transaction size helpers

`getTransactionSize` estimates the serialized size of a compiled transaction message. `assertTransactionIsWithinSizeLimit` throws if the message exceeds the network limit.

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
