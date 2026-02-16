# solana_kit_program_client_core

Core building blocks for generated Solana program clients in the Solana Kit Dart SDK.

This package provides the foundational types and utilities used by generated program clients, including instruction types that track storage changes, self-fetch functions for decoder-based account retrieval, and instruction input resolution helpers.

## Installation

Add `solana_kit_program_client_core` to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_program_client_core:
```

Or, if you are using the umbrella package:

```yaml
dependencies:
  solana_kit:
```

## Usage

### Instructions with byte delta

The `InstructionWithByteDelta` class extends the base `Instruction` with a `byteDelta` field that tracks the net change in account storage size. This is useful for calculating rent-exemption balances for a transaction.

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_program_client_core/solana_kit_program_client_core.dart';

void main() {
  const programAddress = Address(
    'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
  );

  // An instruction that allocates 165 bytes of account space.
  final createInstruction = InstructionWithByteDelta(
    programAddress: programAddress,
    byteDelta: 165, // Positive means bytes are allocated.
    data: Uint8List.fromList([0, 1, 2, 3]),
  );

  print(createInstruction.byteDelta); // 165
  print(createInstruction.programAddress); // TokenkegQ...

  // An instruction that frees 100 bytes of account space.
  final closeInstruction = InstructionWithByteDelta(
    programAddress: programAddress,
    byteDelta: -100, // Negative means bytes are freed.
  );

  print(closeInstruction.byteDelta); // -100

  // Calculate total byte delta for a transaction.
  final instructions = [createInstruction, closeInstruction];
  final totalDelta = instructions.fold<int>(
    0,
    (sum, ix) => sum + ix.byteDelta,
  );
  print('Net storage change: $totalDelta bytes'); // 65
}
```

### Self-fetch functions

The `SelfFetchFunctions<TData>` class augments a decoder with RPC fetch methods, enabling a fluent API where you fetch and decode accounts in one step.

```dart
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_program_client_core/solana_kit_program_client_core.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';

// Example: a simple counter account.
class CounterData {
  const CounterData(this.count);
  final int count;
}

Future<void> main() async {
  final rpc = createSolanaRpc('https://api.devnet.solana.com');

  // Assume `counterDecoder` is a Decoder<CounterData> for your program's
  // account layout.
  final counterDecoder = /* your decoder here */ null as Decoder<CounterData>;

  // Wrap the decoder with self-fetch methods.
  final fetchable = addSelfFetchFunctions(rpc, counterDecoder);

  const counterAddress = Address('YourCounterAccountAddress1111111111111111111');
  const address1 = Address('FirstAddress11111111111111111111111111111111');
  const address2 = Address('SecondAddress1111111111111111111111111111111');

  // Fetch and decode a single account (throws if not found).
  final account = await fetchable.fetch(counterAddress);
  print(account.data.count);

  // Fetch and decode, allowing the account to not exist.
  final maybeAccount = await fetchable.fetchMaybe(counterAddress);
  if (maybeAccount case ExistingAccount<CounterData>(:final account)) {
    print('Found: ${account.data.count}');
  }

  // Fetch and decode multiple accounts (throws if any missing).
  final accounts = await fetchable.fetchAll([address1, address2]);

  // Fetch multiple, allowing some to not exist.
  final maybeAccounts = await fetchable.fetchAllMaybe([address1, address2]);
}
```

### Instruction input resolution

When building instructions for generated program clients, account inputs must be resolved to their final form. The resolution helpers handle extracting addresses from various account input types.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_program_client_core/solana_kit_program_client_core.dart';

void main() {
  // Resolve an address from various account input types.
  const addr = Address('11111111111111111111111111111111');

  // From a plain Address.
  final resolved = getAddressFromResolvedInstructionAccount('myAccount', addr);
  print(resolved); // Address('11111...')

  // From a ProgramDerivedAddress (tuple of Address and bump).
  final pda = (addr, 255);
  final pdaAddress = getAddressFromResolvedInstructionAccount('myPda', pda);
  print(pdaAddress); // Address('11111...')

  // Validate non-null inputs.
  // Throws SolanaError if the value is null.
  final nonNull = getNonNullResolvedInstructionInput<String>(
    'myInput',
    'hello',
  );
  print(nonNull); // 'hello'
}
```

### Account meta factory

The `getAccountMetaFactory` function creates a converter from resolved instruction accounts to account metas, handling optional accounts and signer detection.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_program_client_core/solana_kit_program_client_core.dart';

void main() {
  const programAddress = Address('11111111111111111111111111111111');

  // Create a factory that omits optional accounts.
  final factory = getAccountMetaFactory(
    programAddress,
    OptionalAccountStrategy.omitted,
  );

  // Convert a resolved account to an AccountMeta.
  final meta = factory(
    'authority',
    ResolvedInstructionAccount(
      isWritable: true,
      value: const Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
    ),
  );
  print(meta?.address); // TokenkegQ...

  // Optional accounts with null values are omitted.
  final nullMeta = factory(
    'optionalAccount',
    ResolvedInstructionAccount(isWritable: false, value: null),
  );
  print(nullMeta); // null

  // With programId strategy, null accounts get the program address instead.
  final programIdFactory = getAccountMetaFactory(
    programAddress,
    OptionalAccountStrategy.programId,
  );
  final fallbackMeta = programIdFactory(
    'optionalAccount',
    ResolvedInstructionAccount(isWritable: false, value: null),
  );
  print(fallbackMeta?.address); // Address('11111...')
}
```

## API Reference

### Classes

| Class                        | Description                                                                                         |
| ---------------------------- | --------------------------------------------------------------------------------------------------- |
| `InstructionWithByteDelta`   | Extends `Instruction` with a `byteDelta` tracking net storage size changes.                         |
| `SelfFetchFunctions<TData>`  | Wraps a `Decoder<TData>` and `Rpc` with `fetch`, `fetchMaybe`, `fetchAll`, `fetchAllMaybe` methods. |
| `ResolvedInstructionAccount` | A resolved account input with `isWritable` and `value` (Address, PDA, signer, or null).             |

### Functions

| Function                                                                 | Description                                                                     |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------------------- |
| `addSelfFetchFunctions<T>(rpc, decoder)`                                 | Wraps a decoder in a `SelfFetchFunctions<T>` for fluent fetch-and-decode.       |
| `getAddressFromResolvedInstructionAccount(inputName, value)`             | Extracts an `Address` from an Address, PDA, or transaction signer.              |
| `getResolvedInstructionAccountAsProgramDerivedAddress(inputName, value)` | Validates and returns a `ProgramDerivedAddress` from a resolved account.        |
| `getResolvedInstructionAccountAsTransactionSigner(inputName, value)`     | Validates and returns a transaction signer from a resolved account.             |
| `getNonNullResolvedInstructionInput<T>(inputName, value)`                | Validates that a resolved input is non-null.                                    |
| `getAccountMetaFactory(programAddress, strategy)`                        | Creates a function that converts `ResolvedInstructionAccount` to `AccountMeta`. |

### Enums

| Enum                                | Description                                                                          |
| ----------------------------------- | ------------------------------------------------------------------------------------ |
| `OptionalAccountStrategy.omitted`   | Optional null accounts are excluded from the instruction.                            |
| `OptionalAccountStrategy.programId` | Optional null accounts are replaced with the program address as a read-only account. |
