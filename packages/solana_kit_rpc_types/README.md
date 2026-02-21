# solana_kit_rpc_types

Shared RPC types for the Solana Kit Dart SDK.

This is the Dart port of [`@solana/rpc-types`](https://github.com/anza-xyz/kit/tree/main/packages/rpc-types) from the Solana TypeScript SDK.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_rpc_types:
```

If you are working within the `solana_kit` monorepo, the package resolves through the Dart workspace. Otherwise, specify a version or path as needed.

## Usage

### Commitment levels

The `Commitment` enum represents the three finality levels for Solana RPC queries. The `commitmentComparator` orders them by finality (processed < confirmed < finalized).

```dart
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

// The three commitment levels.
const c1 = Commitment.processed;
const c2 = Commitment.confirmed;
const c3 = Commitment.finalized;

// Compare commitments by finality level.
print(commitmentComparator(Commitment.processed, Commitment.finalized)); // -1
print(commitmentComparator(Commitment.finalized, Commitment.finalized)); // 0
print(commitmentComparator(Commitment.finalized, Commitment.confirmed)); // 1

// Use the comparator to sort a list.
final commitments = [Commitment.finalized, Commitment.processed, Commitment.confirmed];
commitments.sort(commitmentComparator);
print(commitments); // [processed, confirmed, finalized]
```

### Lamports

`Lamports` is an extension type wrapping `BigInt` that represents a value denominated in the smallest unit of SOL (1 SOL = 10^9 lamports). It includes validation, encoding, and decoding utilities.

```dart
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

// Create a Lamports value from a trusted BigInt.
const oneSol = Lamports(BigInt.from(1000000000)); // 1 SOL

// Create from untrusted input (validates range 0 to 2^64-1).
final validated = lamports(BigInt.from(500000));

// Check validity without throwing.
print(isLamports(BigInt.from(100))); // true
print(isLamports(BigInt.from(-1))); // false

// Assert validity (throws SolanaError if out of range).
assertIsLamports(BigInt.from(100)); // OK
// assertIsLamports(BigInt.from(-1)); // throws SolanaError

// Encode/decode Lamports as 8-byte little-endian (u64).
final encoder = getDefaultLamportsEncoder();
final decoder = getDefaultLamportsDecoder();
final codec = getDefaultLamportsCodec();
```

### Blockhash

`Blockhash` is an extension type wrapping `String` that represents a validated base58-encoded blockhash (same format as a Solana address -- 32 bytes).

```dart
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

// Create from a trusted string.
const bh = Blockhash('4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY');

// Create from untrusted input (validates base58 encoding and byte length).
final validated = blockhash('4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY');

// Check validity.
print(isBlockhash('4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY')); // true
print(isBlockhash('too-short')); // false

// Encode/decode as 32 bytes.
final encoder = getBlockhashEncoder();
final decoder = getBlockhashDecoder();
final codec = getBlockhashCodec();

// Sort blockhashes using base58 collation.
final comparator = getBlockhashComparator();
final sorted = ['Zzz', 'Aaa', 'aaa']..sort(comparator);
```

### Unix timestamps

`UnixTimestamp` is an extension type wrapping `BigInt` that represents a Unix timestamp in seconds (i64 range).

```dart
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

// Create from a trusted BigInt.
const ts = UnixTimestamp(BigInt.from(1700000000));

// Create from untrusted input (validates i64 range).
final validated = unixTimestamp(BigInt.from(1700000000));

// Check validity.
print(isUnixTimestamp(BigInt.from(1700000000))); // true
```

### Cluster URLs

Branded extension types for cluster URLs provide compile-time safety when working with different Solana clusters.

```dart
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

// Create branded URLs for each cluster.
final mainnetUrl = mainnet('https://api.mainnet-beta.solana.com');
final devnetUrl = devnet('https://api.devnet.solana.com');
final testnetUrl = testnet('https://api.testnet.solana.com');

// All are still Strings underneath, but typed for safety.
print(mainnetUrl is MainnetUrl); // true
print(devnetUrl is DevnetUrl); // true
```

### Slot and Epoch

`Slot` and `Epoch` are type aliases for `BigInt`, representing slot numbers and epoch numbers on the Solana blockchain.

```dart
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

Slot currentSlot = BigInt.from(250000000);
Epoch currentEpoch = BigInt.from(580);

// MicroLamports is an extension type for priority fee calculations.
const fee = MicroLamports(BigInt.from(5000));
```

### Stringified BigInt and Number

These extension types represent values that the RPC returns as strings to avoid precision loss during JSON transit.

```dart
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

// StringifiedBigInt: a BigInt encoded as a string.
final amount = stringifiedBigInt('1000000000');
print(isStringifiedBigInt('1000000000')); // true
print(isStringifiedBigInt('not-a-number')); // false

// StringifiedNumber: a number encoded as a string.
final uiAmount = stringifiedNumber('1.5');
print(isStringifiedNumber('1.5')); // true
```

### Token amounts

The `TokenAmount` class represents a token balance as returned by the Solana RPC, including the raw amount, decimal configuration, and human-readable string.

```dart
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

final tokenAmount = TokenAmount(
  amount: StringifiedBigInt('1000000'),
  decimals: 6,
  uiAmountString: StringifiedNumber('1'),
);

print(tokenAmount.amount); // '1000000'
print(tokenAmount.decimals); // 6
print(tokenAmount.uiAmountString); // '1'
```

### Account info

`AccountInfoBase` provides the core fields common to all account info variants. Specialized subclasses handle different data encodings.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

final accountInfo = AccountInfoBase(
  executable: false,
  lamports: Lamports(BigInt.from(1000000)),
  owner: Address('11111111111111111111111111111111'),
  space: BigInt.from(165),
);

print(accountInfo.executable); // false
print(accountInfo.lamports); // Lamports(1000000)
print(accountInfo.owner); // 11111111111111111111111111111111
```

Data encoding variants:

- `AccountInfoWithBase64EncodedData` -- base64-encoded data
- `AccountInfoWithBase64EncodedZStdCompressedData` -- base64+zstd-compressed data
- `AccountInfoWithJsonData` -- JSON-parsed data (sealed: `AccountInfoJsonDataParsed` or `AccountInfoJsonDataBase64` fallback)
- `AccountInfoWithPubkey<T>` -- wraps any account info variant with its public key

### Transaction and instruction errors

Sealed class hierarchies provide type-safe representations of Solana runtime errors.

```dart
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

// Transaction errors.
const simpleError = TransactionErrorSimple('BlockhashNotFound');
print(simpleError.label); // 'BlockhashNotFound'

const instructionError = TransactionErrorInstructionError(
  0,
  InstructionErrorCustom(42),
);
print(instructionError.instructionIndex); // 0
print(instructionError.instructionError.label); // 'Custom'
print((instructionError.instructionError as InstructionErrorCustom).code); // 42

// Pattern matching on sealed types.
void handleError(TransactionError error) {
  switch (error) {
    case TransactionErrorSimple(:final label):
      print('Simple error: $label');
    case TransactionErrorInstructionError(:final instructionIndex, :final instructionError):
      print('Instruction $instructionIndex failed: ${instructionError.label}');
    case TransactionErrorDuplicateInstruction(:final instructionIndex):
      print('Duplicate instruction at index $instructionIndex');
    case TransactionErrorInsufficientFundsForRent(:final accountIndex):
      print('Insufficient funds for rent at account $accountIndex');
    case TransactionErrorProgramExecutionTemporarilyRestricted(:final accountIndex):
      print('Program execution restricted for account $accountIndex');
  }
}
```

## API Reference

### Enums

- **`Commitment`** -- Finality levels: `processed`, `confirmed`, `finalized`.

### Extension Types

- **`Lamports(BigInt)`** -- A value denominated in lamports (10^-9 SOL).
- **`Blockhash(String)`** -- A validated base58-encoded blockhash.
- **`UnixTimestamp(BigInt)`** -- A Unix timestamp in seconds (i64 range).
- **`MainnetUrl(String)`** -- A branded mainnet cluster URL.
- **`DevnetUrl(String)`** -- A branded devnet cluster URL.
- **`TestnetUrl(String)`** -- A branded testnet cluster URL.
- **`MicroLamports(BigInt)`** -- A value denominated in micro-lamports (10^-6 lamports).
- **`StringifiedBigInt(String)`** -- A BigInt encoded as a string.
- **`StringifiedNumber(String)`** -- A number encoded as a string.

### Classes

- **`AccountInfoBase`** -- Base account info with `executable`, `lamports`, `owner`, `space`.
- **`AccountInfoWithBase64EncodedData`** -- Account info with base64-encoded data.
- **`AccountInfoWithBase64EncodedZStdCompressedData`** -- Account info with zstd-compressed data.
- **`AccountInfoWithJsonData`** -- Account info with JSON-parsed data.
- **`AccountInfoWithPubkey<T>`** -- Account info paired with its public key address.
- **`ParsedAccountData`** -- Parsed account data with `type`, `program`, `space`, and optional `info`.
- **`TokenAmount`** -- Token balance with `amount`, `decimals`, `uiAmountString`.
- **`InstructionError`** -- Sealed class for instruction-level errors (`InstructionErrorCustom`, `InstructionErrorSimple`).
- **`TransactionError`** -- Sealed class for transaction-level errors (`TransactionErrorSimple`, `TransactionErrorInstructionError`, `TransactionErrorDuplicateInstruction`, `TransactionErrorInsufficientFundsForRent`, `TransactionErrorProgramExecutionTemporarilyRestricted`).

### Functions

- **`commitmentComparator(Commitment, Commitment)`** -- Compares two commitments by finality level.
- **`lamports(BigInt)`** -- Validates and creates a `Lamports` value.
- **`isLamports(BigInt)`** / **`assertIsLamports(BigInt)`** -- Lamports range checks.
- **`blockhash(String)`** -- Validates and creates a `Blockhash`.
- **`isBlockhash(String)`** / **`assertIsBlockhash(String)`** -- Blockhash validation.
- **`unixTimestamp(BigInt)`** -- Validates and creates a `UnixTimestamp`.
- **`isUnixTimestamp(BigInt)`** / **`assertIsUnixTimestamp(BigInt)`** -- Timestamp range checks.
- **`stringifiedBigInt(String)`** -- Validates and creates a `StringifiedBigInt`.
- **`stringifiedNumber(String)`** -- Validates and creates a `StringifiedNumber`.
- **`mainnet(String)`** / **`devnet(String)`** / **`testnet(String)`** -- Cluster URL constructors.
- **`getDefaultLamportsEncoder()`** / **`getDefaultLamportsDecoder()`** / **`getDefaultLamportsCodec()`** -- u64 codec for Lamports.
- **`getBlockhashEncoder()`** / **`getBlockhashDecoder()`** / **`getBlockhashCodec()`** -- 32-byte codec for Blockhash.
- **`getBlockhashComparator()`** -- Returns a base58 collation comparator for blockhashes.

### Typedefs

- **`Slot`** -- `BigInt` representing a slot number.
- **`Epoch`** -- `BigInt` representing an epoch number.
- **`SignedLamports`** -- `BigInt` representing a signed lamport amount.
- **`F64UnsafeSeeDocumentation`** -- `double` for floating-point RPC values with precision caveats.
- **`ClusterUrl`** -- `String` union type for all cluster URL types.

### Abstract Final Classes (Constants)

- **`InstructionErrorLabel`** -- String constants for all known instruction error labels.
- **`TransactionErrorLabel`** -- String constants for all known transaction error labels.
