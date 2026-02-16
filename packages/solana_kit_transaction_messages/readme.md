# solana_kit_transaction_messages

Build, compile, and decompile Solana transaction messages.

This is the Dart port of [`@solana/transaction-messages`](https://github.com/anza-xyz/kit/tree/main/packages/transaction-messages) from the Solana TypeScript SDK.

## Installation

```yaml
dependencies:
  solana_kit_transaction_messages:
```

Since this package is part of the `solana_kit` workspace, you can also use the umbrella package:

```yaml
dependencies:
  solana_kit:
```

## Usage

### Creating a transaction message

Transaction messages are built step by step using an immutable builder pattern. Each transform function returns a new `TransactionMessage` instance.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

// Create an empty v0 transaction message.
final message = createTransactionMessage(version: TransactionVersion.v0);
```

### Setting a fee payer

Every transaction needs a fee payer -- the account that pays for the transaction processing fees.

```dart
final feePayer = Address('mpngsFd4tmbUfzDYJayjKZwZcaR7aWb2793J6grLsGu');
final messageWithFeePayer = setTransactionMessageFeePayer(feePayer, message);
```

### Setting a blockhash lifetime

A transaction must include a recent blockhash to be eligible for execution on the network. The transaction remains valid until the blockhash expires.

```dart
final messageWithLifetime = setTransactionMessageLifetimeUsingBlockhash(
  BlockhashLifetimeConstraint(
    blockhash: 'EkSnNWid2cvwEVnVx9aBqawnmiCNiDgp3gUdkDPTKN1N',
    lastValidBlockHeight: BigInt.from(300000),
  ),
  messageWithFeePayer,
);
```

### Appending instructions

Instructions can be appended or prepended to the transaction message.

```dart
import 'dart:typed_data';

final transferInstruction = Instruction(
  programAddress: Address('11111111111111111111111111111111'),
  accounts: [
    AccountMeta(
      address: Address('mpngsFd4tmbUfzDYJayjKZwZcaR7aWb2793J6grLsGu'),
      role: AccountRole.writableSigner,
    ),
    AccountMeta(
      address: Address('GDhQoTpNbYUaCAjFKBMCPCdrCaKaLiSqhx5M7r4SrEFy'),
      role: AccountRole.writable,
    ),
  ],
  data: Uint8List.fromList([2, 0, 0, 0, 0, 202, 154, 59, 0, 0, 0, 0]),
);

// Append a single instruction.
final messageWithInstruction = appendTransactionMessageInstruction(
  transferInstruction,
  messageWithLifetime,
);

// Append multiple instructions at once.
final messageWithInstructions = appendTransactionMessageInstructions(
  [transferInstruction],
  messageWithLifetime,
);

// Prepend an instruction to the beginning.
final messageWithPrepended = prependTransactionMessageInstruction(
  transferInstruction,
  messageWithLifetime,
);
```

### Building a full transaction message using the pipeline pattern

The `pipe` extension (from `solana_kit_functional`) allows chaining transforms together in a readable pipeline:

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_functional/solana_kit_functional.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

final myAddress = Address('mpngsFd4tmbUfzDYJayjKZwZcaR7aWb2793J6grLsGu');
final recipient = Address('GDhQoTpNbYUaCAjFKBMCPCdrCaKaLiSqhx5M7r4SrEFy');

final txMessage = createTransactionMessage(version: TransactionVersion.v0)
    .pipe((m) => setTransactionMessageFeePayer(myAddress, m))
    .pipe(
      (m) => setTransactionMessageLifetimeUsingBlockhash(
        BlockhashLifetimeConstraint(
          blockhash: 'EkSnNWid2cvwEVnVx9aBqawnmiCNiDgp3gUdkDPTKN1N',
          lastValidBlockHeight: BigInt.from(300000),
        ),
        m,
      ),
    )
    .pipe(
      (m) => appendTransactionMessageInstruction(
        Instruction(
          programAddress: Address('11111111111111111111111111111111'),
          accounts: [
            AccountMeta(address: myAddress, role: AccountRole.writableSigner),
            AccountMeta(address: recipient, role: AccountRole.writable),
          ],
          data: Uint8List.fromList([
            2, 0, 0, 0, 0, 202, 154, 59, 0, 0, 0, 0,
          ]),
        ),
        m,
      ),
    );
```

### Durable nonce lifetime

For transactions that must remain valid indefinitely (until the nonce is consumed), use a durable nonce lifetime instead of a blockhash:

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

final messageWithNonce = setTransactionMessageLifetimeUsingDurableNonce(
  DurableNonceConfig(
    nonce: '4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi',
    nonceAccountAddress:
        Address('8GsjzsJwQa2BbJxifoKpH5nUBJWigQqoBWWBy4VLVBCR'),
    nonceAuthorityAddress:
        Address('mpngsFd4tmbUfzDYJayjKZwZcaR7aWb2793J6grLsGu'),
  ),
  txMessage,
);

// This automatically prepends an AdvanceNonceAccount instruction.
print(isTransactionMessageWithDurableNonceLifetime(messageWithNonce)); // true
```

### Compiling a transaction message

Once the transaction message is fully built, compile it into a `CompiledTransactionMessage` suitable for encoding and execution:

```dart
final compiledMessage = compileTransactionMessage(txMessage);
// compiledMessage contains: version, header, staticAccounts,
// lifetimeToken, instructions, and addressTableLookups.
```

### Decompiling a transaction message

You can reconstruct a `TransactionMessage` from a `CompiledTransactionMessage`. Because compilation is lossy, you may need to supply extra context:

```dart
final decompiled = decompileTransactionMessage(compiledMessage);

// With extra context for address lookup tables and block height:
final decompiledWithContext = decompileTransactionMessage(
  compiledMessage,
  DecompileTransactionMessageConfig(
    lastValidBlockHeight: BigInt.from(300000),
    addressesByLookupTableAddress: {
      Address('4wBqpZM9msxygPoFDEBSm7BKZRXBT6DzChAZ87UMVGim'): [
        Address('GDhQoTpNbYUaCAjFKBMCPCdrCaKaLiSqhx5M7r4SrEFy'),
      ],
    },
  ),
);
```

### Compressing with address lookup tables

For v0 transactions, you can compress a transaction message by replacing non-signer accounts with address lookup table references:

```dart
final compressedMessage =
    compressTransactionMessageUsingAddressLookupTables(
  txMessage,
  {
    Address('4wBqpZM9msxygPoFDEBSm7BKZRXBT6DzChAZ87UMVGim'): [
      Address('GDhQoTpNbYUaCAjFKBMCPCdrCaKaLiSqhx5M7r4SrEFy'),
    ],
  },
);
```

### Checking lifetime types

```dart
// Blockhash lifetime.
print(isTransactionMessageWithBlockhashLifetime(txMessage)); // true
assertIsTransactionMessageWithBlockhashLifetime(txMessage);

// Durable nonce lifetime.
print(isTransactionMessageWithDurableNonceLifetime(messageWithNonce)); // true
assertIsTransactionMessageWithDurableNonceLifetime(messageWithNonce);
```

## API Reference

### Classes

- **`TransactionMessage`** -- An immutable transaction message with `version`, `feePayer`, `instructions`, and `lifetimeConstraint`.
- **`CompiledTransactionMessage`** -- A compiled message ready for wire encoding, with `header`, `staticAccounts`, `instructions`, `lifetimeToken`, and `addressTableLookups`.
- **`MessageHeader`** -- Describes account roles in a compiled message (`numSignerAccounts`, `numReadonlySignerAccounts`, `numReadonlyNonSignerAccounts`).
- **`CompiledInstruction`** -- A compiled instruction with `programAddressIndex`, `accountIndices`, and `data`.
- **`AddressTableLookup`** -- An address table lookup with `lookupTableAddress`, `writableIndexes`, and `readonlyIndexes`.
- **`DecompileTransactionMessageConfig`** -- Configuration for decompiling with `addressesByLookupTableAddress` and `lastValidBlockHeight`.
- **`DurableNonceConfig`** -- Configuration for durable nonce lifetime with `nonce`, `nonceAccountAddress`, and `nonceAuthorityAddress`.

### Enums

- **`TransactionVersion`** -- `legacy` or `v0`.

### Sealed classes

- **`LifetimeConstraint`** -- Sealed base class.
  - **`BlockhashLifetimeConstraint`** -- Blockhash-based lifetime with `blockhash` and `lastValidBlockHeight`.
  - **`DurableNonceLifetimeConstraint`** -- Nonce-based lifetime with `nonce`.

### Functions

| Function | Description |
| --- | --- |
| `createTransactionMessage` | Creates a new empty transaction message with the given version. |
| `setTransactionMessageFeePayer` | Returns a new message with the fee payer set. |
| `setTransactionMessageLifetimeUsingBlockhash` | Returns a new message with a blockhash lifetime constraint. |
| `setTransactionMessageLifetimeUsingDurableNonce` | Returns a new message with a durable nonce lifetime. |
| `appendTransactionMessageInstruction` | Returns a new message with an instruction appended. |
| `appendTransactionMessageInstructions` | Returns a new message with multiple instructions appended. |
| `prependTransactionMessageInstruction` | Returns a new message with an instruction prepended. |
| `prependTransactionMessageInstructions` | Returns a new message with multiple instructions prepended. |
| `compileTransactionMessage` | Compiles a `TransactionMessage` into a `CompiledTransactionMessage`. |
| `decompileTransactionMessage` | Reconstructs a `TransactionMessage` from a compiled message. |
| `compressTransactionMessageUsingAddressLookupTables` | Replaces non-signer accounts with lookup table references. |
| `isTransactionMessageWithBlockhashLifetime` | Returns `true` if the message has a blockhash lifetime. |
| `assertIsTransactionMessageWithBlockhashLifetime` | Throws if the message does not have a blockhash lifetime. |
| `isTransactionMessageWithDurableNonceLifetime` | Returns `true` if the message has a durable nonce lifetime. |
| `assertIsTransactionMessageWithDurableNonceLifetime` | Throws if the message does not have a durable nonce lifetime. |
| `getCompiledTransactionMessageEncoder` | Returns an encoder for compiled transaction messages. |
| `getCompiledTransactionMessageDecoder` | Returns a decoder for compiled transaction messages. |
| `getCompiledTransactionMessageCodec` | Returns a codec for compiled transaction messages. |

### Constants

- **`maxSupportedTransactionVersion`** -- The maximum supported transaction version (currently `0`).
