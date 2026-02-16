# solana_kit_signers

Signer interfaces and utilities for signing Solana messages and transactions -- a Dart port of [`@solana/signers`](https://github.com/anza-xyz/kit/tree/main/packages/signers).

## Installation

Add `solana_kit_signers` to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_signers:
```

Or, if you are using the umbrella package:

```yaml
dependencies:
  solana_kit:
```

## Usage

### Creating a key pair signer

A `KeyPairSigner` is the most common signer -- it holds an Ed25519 key pair and implements both the `MessagePartialSigner` and `TransactionPartialSigner` interfaces.

```dart
import 'package:solana_kit_signers/solana_kit_signers.dart';

void main() {
  // Generate a new random key pair signer.
  final signer = generateKeyPairSigner();
  print('Address: ${signer.address.value}');
  print('Public key: ${signer.keyPair.publicKey}');
}
```

### Restoring a signer from bytes

Create a `KeyPairSigner` from existing key material.

```dart
import 'dart:typed_data';

import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';

void main() {
  // From a 64-byte array (32 private + 32 public).
  final fullBytes = Uint8List(64); // replace with real bytes
  final signer64 = createKeyPairSignerFromBytes(fullBytes);

  // From a 32-byte private key only (public key is derived).
  final privateKeyBytes = Uint8List(32); // replace with real bytes
  final signer32 = createKeyPairSignerFromPrivateKeyBytes(privateKeyBytes);

  // From an existing KeyPair instance.
  final keyPair = generateKeyPair();
  final signerFromPair = createSignerFromKeyPair(keyPair);

  print(signer64.address.value);
  print(signer32.address.value);
  print(signerFromPair.address.value);
}
```

### Signing messages

Create a `SignableMessage` and sign it with one or more signers. The `SignableMessage` class pairs message content with a map of existing signatures.

```dart
import 'dart:typed_data';

import 'package:solana_kit_signers/solana_kit_signers.dart';

Future<void> main() async {
  final signer = generateKeyPairSigner();

  // Create a signable message from a UTF-8 string.
  final message = createSignableMessage('Hello, Solana!');

  // Or from raw bytes.
  final messageFromBytes = createSignableMessage(
    Uint8List.fromList([1, 2, 3, 4]),
  );

  // Sign the message. Returns a list of signature dictionaries (one per message).
  final signaturesList = await signer.signMessages([message]);
  final signatures = signaturesList[0];

  print('Signed by: ${signatures.keys.first.value}');
  print('Signature length: ${signatures.values.first.value.length}'); // 64
}
```

### Using a noop signer

A `NoopSigner` implements the partial signer interfaces but returns empty signature dictionaries. This is useful as a placeholder in tests or when building transaction messages that will be signed later.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';

Future<void> main() async {
  final noopSigner = createNoopSigner(
    address('11111111111111111111111111111111'),
  );

  final message = createSignableMessage('test');
  final signaturesList = await noopSigner.signMessages([message]);

  // Noop signer returns empty signature maps.
  print('Signatures: ${signaturesList[0]}'); // {}
}
```

### Attaching signers to instructions

Use `addSignersToInstruction` to associate signer objects with the account metas of an instruction. The signer is attached when the account has a signer role and its address matches the signer's address.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';

void main() {
  final signer = generateKeyPairSigner();

  final instruction = Instruction(
    programAddress: address('11111111111111111111111111111111'),
    accounts: [
      AccountMeta(
        address: signer.address,
        role: AccountRole.writableSigner,
      ),
    ],
  );

  // Attach the signer to matching account metas.
  final updated = addSignersToInstruction([signer], instruction);

  // The matching account meta is now an AccountSignerMeta.
  print(updated.accounts![0] is AccountSignerMeta); // true
}
```

### Attaching signers to transaction messages

Use `addSignersToTransactionMessage` to attach signers to all instructions within a transaction message, and optionally to the fee payer.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

void main() {
  final signer = generateKeyPairSigner();

  final txMessage = TransactionMessage(
    version: TransactionVersion.v0,
    feePayer: signer.address,
    instructions: [
      Instruction(
        programAddress: address('11111111111111111111111111111111'),
        accounts: [
          AccountMeta(
            address: signer.address,
            role: AccountRole.writableSigner,
          ),
        ],
      ),
    ],
  );

  // Attach signers to all matching account metas and the fee payer.
  final updated = addSignersToTransactionMessage([signer], txMessage);

  // The fee payer is now stored as a signer.
  print(updated is TransactionMessageWithFeePayerSigner); // true
}
```

### Setting a fee payer signer

Use `setTransactionMessageFeePayerSigner` to set the fee payer of a transaction message to a signer object (rather than just an address).

```dart
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

void main() {
  final feePayer = generateKeyPairSigner();

  final txMessage = TransactionMessage(
    version: TransactionVersion.v0,
  );

  // Set the fee payer as a signer.
  final withFeePayer = setTransactionMessageFeePayerSigner(
    feePayer,
    txMessage,
  );

  print(withFeePayer.feePayer?.value); // the fee payer's address
}
```

### Signing a full transaction

Once signers are attached to a transaction message, use the high-level signing functions to produce a signed transaction.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

Future<void> main() async {
  final signer = generateKeyPairSigner();

  // Build a transaction message with attached signers.
  var txMessage = TransactionMessage(
    version: TransactionVersion.v0,
    instructions: [
      Instruction(
        programAddress: address('11111111111111111111111111111111'),
        accounts: [
          AccountMeta(
            address: signer.address,
            role: AccountRole.writableSigner,
          ),
        ],
      ),
    ],
  );

  // Set the fee payer signer and attach signers to instructions.
  txMessage = setTransactionMessageFeePayerSigner(signer, txMessage);
  txMessage = addSignersToTransactionMessage([signer], txMessage);

  // Partially sign -- does not assert all signatures are present.
  final partiallySigned = await partiallySignTransactionMessageWithSigners(
    txMessage,
  );
  print('Partially signed: ${partiallySigned.signatures}');

  // Fully sign -- asserts all required signatures are present.
  final fullySigned = await signTransactionMessageWithSigners(txMessage);
  print('Fully signed: ${fullySigned.signatures}');
}
```

### Signing and sending a transaction

Use `signAndSendTransactionMessageWithSigners` when your transaction message contains a `TransactionSendingSigner`. This function signs the transaction and immediately submits it to the network.

```dart
// Pseudocode -- requires a TransactionSendingSigner implementation
// (e.g. a wallet adapter).
//
// final sendingSigner = myWalletSendingSigner;
// final txMessage = setTransactionMessageFeePayerSigner(
//   sendingSigner,
//   transactionMessage,
// );
//
// final txSignature = await signAndSendTransactionMessageWithSigners(
//   txMessage,
// );
// print('Transaction signature: ${txSignature.value}');
```

### Deduplicating signers

When composing transactions from multiple sources, you may end up with duplicate signer references. Use `deduplicateSigners` to remove duplicates by address.

```dart
import 'package:solana_kit_signers/solana_kit_signers.dart';

void main() {
  final signer = generateKeyPairSigner();

  // Same signer referenced multiple times -- deduplicated to one.
  final deduplicated = deduplicateSigners([signer, signer, signer]);
  print('Count: ${deduplicated.length}'); // 1

  // Two different signers with the same address would throw SolanaError
  // with code signerAddressCannotHaveMultipleSigners.
}
```

### Type guards

The package provides type guard functions for each signer interface.

```dart
import 'package:solana_kit_signers/solana_kit_signers.dart';

void main() {
  final signer = generateKeyPairSigner();

  // Check signer interfaces.
  print(isKeyPairSigner(signer)); // true
  print(isMessagePartialSigner(signer)); // true
  print(isTransactionPartialSigner(signer)); // true
  print(isMessageModifyingSigner(signer)); // false
  print(isTransactionModifyingSigner(signer)); // false
  print(isTransactionSendingSigner(signer)); // false

  // Composite checks.
  print(isMessageSigner(signer)); // true (partial or modifying)
  print(isTransactionSigner(signer)); // true (partial, modifying, or sending)

  // Assert variants throw SolanaError on failure.
  assertIsKeyPairSigner(signer);
  assertIsMessagePartialSigner(signer);
  assertIsTransactionPartialSigner(signer);
}
```

## Signer interfaces

The package defines five abstract signer interfaces. Implementations can mix and match these as needed.

### Message signers

| Interface | Method | Description |
|-----------|--------|-------------|
| `MessagePartialSigner` | `signMessages(List<SignableMessage>)` | Signs messages without modifying content. Parallel-safe. |
| `MessageModifyingSigner` | `modifyAndSignMessages(List<SignableMessage>)` | May modify message content before signing. Must run sequentially, before partial signers. |

### Transaction signers

| Interface | Method | Description |
|-----------|--------|-------------|
| `TransactionPartialSigner` | `signTransactions(List<Transaction>)` | Signs transactions without modifying them. Parallel-safe. |
| `TransactionModifyingSigner` | `modifyAndSignTransactions(List<Transaction>)` | May modify transactions before signing. Must run sequentially, before partial signers. |
| `TransactionSendingSigner` | `signAndSendTransactions(List<Transaction>)` | Signs and immediately sends transactions. Only one per transaction. Must be the last signer. |

## API Reference

### Concrete signers

| Export | Description |
|--------|-------------|
| `KeyPairSigner` | Implements `MessagePartialSigner` and `TransactionPartialSigner` using an Ed25519 `KeyPair`. |
| `NoopSigner` | Implements `MessagePartialSigner` and `TransactionPartialSigner` returning empty signature maps. |

### Signer factories

| Function | Description |
|----------|-------------|
| `generateKeyPairSigner()` | Generates a random `KeyPairSigner`. |
| `createSignerFromKeyPair(KeyPair)` | Creates a `KeyPairSigner` from an existing key pair. |
| `createKeyPairSignerFromBytes(Uint8List)` | Creates a `KeyPairSigner` from a 64-byte array (32 private + 32 public). |
| `createKeyPairSignerFromPrivateKeyBytes(Uint8List)` | Creates a `KeyPairSigner` from a 32-byte private key. |
| `createNoopSigner(Address)` | Creates a `NoopSigner` for the given address. |

### Message utilities

| Export | Description |
|--------|-------------|
| `SignableMessage` | Class with `content` (`Uint8List`) and `signatures` (`Map<Address, SignatureBytes>`). |
| `createSignableMessage(Object, [Map?])` | Creates a `SignableMessage` from a `String` or `Uint8List`, with optional existing signatures. |

### Transaction signing

| Function | Description |
|----------|-------------|
| `partiallySignTransactionMessageWithSigners(TransactionMessage)` | Extracts signers from the message and returns a partially signed `Transaction`. |
| `signTransactionMessageWithSigners(TransactionMessage)` | Same as above but asserts all required signatures are present. |
| `signAndSendTransactionMessageWithSigners(TransactionMessage)` | Signs and sends via the embedded `TransactionSendingSigner`. Returns `Future<SignatureBytes>`. |

### Signer attachment

| Function | Description |
|----------|-------------|
| `addSignersToInstruction(List<Object>, Instruction)` | Attaches signers to matching account metas of an instruction. |
| `addSignersToTransactionMessage(List<Object>, TransactionMessage)` | Attaches signers to all instructions and the fee payer of a transaction message. |
| `setTransactionMessageFeePayerSigner(Object, TransactionMessage)` | Sets the fee payer of a transaction message to a signer. |

### Signer deduplication

| Function | Description |
|----------|-------------|
| `deduplicateSigners<T>(List<T>)` | Removes duplicate signers by address. Throws if two distinct signers share an address. |

### Type guards and assertions

| Function | Description |
|----------|-------------|
| `isKeyPairSigner(Object?)` | Returns `true` if value is a `KeyPairSigner`. |
| `isMessagePartialSigner(Object?)` | Returns `true` if value implements `MessagePartialSigner`. |
| `isMessageModifyingSigner(Object?)` | Returns `true` if value implements `MessageModifyingSigner`. |
| `isMessageSigner(Object?)` | Returns `true` if value is any message signer. |
| `isTransactionPartialSigner(Object?)` | Returns `true` if value implements `TransactionPartialSigner`. |
| `isTransactionModifyingSigner(Object?)` | Returns `true` if value implements `TransactionModifyingSigner`. |
| `isTransactionSendingSigner(Object?)` | Returns `true` if value implements `TransactionSendingSigner`. |
| `isTransactionSigner(Object?)` | Returns `true` if value is any transaction signer. |
| `assertIsKeyPairSigner(Object?)` | Asserts value is a `KeyPairSigner`. Throws `SolanaError` on failure. |
| `assertIsMessagePartialSigner(Object?)` | Asserts value implements `MessagePartialSigner`. |
| `assertIsMessageModifyingSigner(Object?)` | Asserts value implements `MessageModifyingSigner`. |
| `assertIsMessageSigner(Object?)` | Asserts value is any message signer. |
| `assertIsTransactionPartialSigner(Object?)` | Asserts value implements `TransactionPartialSigner`. |
| `assertIsTransactionModifyingSigner(Object?)` | Asserts value implements `TransactionModifyingSigner`. |
| `assertIsTransactionSendingSigner(Object?)` | Asserts value implements `TransactionSendingSigner`. |
| `assertIsTransactionSigner(Object?)` | Asserts value is any transaction signer. |

### Configuration

| Export | Description |
|--------|-------------|
| `SignerConfig` | Base configuration with an `aborted` flag for cancellation. |
| `TransactionSignerConfig` | Extends `SignerConfig` with an optional `minContextSlot` for simulation. |

### Advanced exports

| Export | Description |
|--------|-------------|
| `AccountSignerMeta` | Extends `AccountMeta` to hold a signer reference alongside the account metadata. |
| `TransactionMessageWithFeePayerSigner` | Extends `TransactionMessage` to store a signer as the fee payer. |
| `getSignersFromInstruction(Instruction)` | Extracts and deduplicates signers from an instruction's account metas. |
| `getSignersFromTransactionMessage(TransactionMessage)` | Extracts and deduplicates all signers from a transaction message. |
| `isTransactionMessageWithSingleSendingSigner(TransactionMessage)` | Returns `true` if the message has exactly one `TransactionSendingSigner`. |
| `assertIsTransactionMessageWithSingleSendingSigner(TransactionMessage)` | Asserts exactly one sending signer exists. |
