# solana_kit_rpc_types

[![pub package](https://img.shields.io/pub/v/solana_kit_rpc_types.svg)](https://pub.dev/packages/solana_kit_rpc_types) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_rpc_types/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_types) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_rpc_types)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_rpc_types)

Shared types used across the Solana Kit RPC stack. Defines commitment levels, lamports, blockhashes, transaction errors, token amounts, account info variants, and the `SolanaRpcResponse<T>` wrapper. Both `solana_kit_rpc_api` and `solana_kit_rpc` depend on this package for their parameter and response shapes.

<!-- {=packageInstallSection:"solana_kit_rpc_types"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_rpc_types": ^0.8.0
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_rpc_types"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_rpc_types
- API reference: https://pub.dev/documentation/solana_kit_rpc_types/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_types
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_rpc_types

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Commitment levels

`Commitment` is an enum with three finality levels. `commitmentComparator` orders them by finality.

```dart
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  const c1 = Commitment.processed;
  const c2 = Commitment.confirmed;
  const c3 = Commitment.finalized;

  print(commitmentComparator(c1, c3)); // -1
  print(commitmentComparator(c3, c3)); // 0
  print(c2);

  final list = [Commitment.finalized, Commitment.processed, Commitment.confirmed];
  list.sort(commitmentComparator);
  print(list); // [processed, confirmed, finalized]
}
```

### Lamports

`Lamports` wraps `BigInt` for values denominated in the smallest unit of SOL (1 SOL = 10^9 lamports).

```dart
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  final oneSol = Lamports(BigInt.from(1000000000)); // 1 SOL

  final validated = lamports(BigInt.from(500000)); // validates range
  print(isLamports(BigInt.from(100))); // true
  print(isLamports(BigInt.from(-1))); // false

  // u64 little-endian codec.
  final encoder = getDefaultLamportsEncoder();
  final decoder = getDefaultLamportsDecoder();
  print(oneSol.value);
  print(validated.value);
  print(encoder.encode(oneSol).length);
  print(decoder.fixedSize);
}
```

### Blockhash

`Blockhash` wraps a validated base58-encoded string (32 bytes).

```dart
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  const bh = Blockhash('4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY');
  final validated = blockhash('4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY');
  print(isBlockhash('too-short')); // false
  print(bh.value);
  print(validated.value);
}
```

### Transaction and instruction errors

Sealed class hierarchies represent Solana runtime errors.

```dart
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  const simple = TransactionErrorSimple('BlockhashNotFound');
  const instrError = TransactionErrorInstructionError(
    0,
    InstructionErrorCustom(42),
  );
  print(simple.label); // 'BlockhashNotFound'
  print(instrError.instructionIndex); // 0
  print(instrError.instructionError.label); // 'Custom'
}
```

### Token amounts and account info

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  final tokenAmount = TokenAmount(
    amount: StringifiedBigInt('1000000'),
    decimals: 6,
    uiAmountString: StringifiedNumber('1'),
  );
  print(tokenAmount.amount); // '1000000'

  final accountInfo = AccountInfoBase(
    executable: false,
    lamports: Lamports(BigInt.from(1000000)),
    owner: Address('11111111111111111111111111111111'),
    space: BigInt.from(165),
  );
  print(accountInfo.lamports); // Lamports(1000000)
}
```

### Cluster URLs, slots, and timestamps

```dart
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  // Branded cluster URL types for compile-time safety.
  final mainnetUrl = mainnet('https://api.mainnet-beta.solana.com');
  print(mainnetUrl);

  // Slot and Epoch are BigInt aliases.
  Slot currentSlot = BigInt.from(250000000);
  Epoch currentEpoch = BigInt.from(580);

  // UnixTimestamp wraps BigInt.
  final ts = UnixTimestamp(BigInt.from(1700000000));
  final validated = unixTimestamp(BigInt.from(1700000000));

  print(currentSlot);
  print(currentEpoch);
  print(ts.value);
  print(validated.value);
}
```

## Key APIs

- `Commitment` enum: `processed`, `confirmed`, `finalized`.
- `Lamports(BigInt)` / `Blockhash(String)` / `UnixTimestamp(BigInt)`: validated extension types.
- `MicroLamports(BigInt)` / `StringifiedBigInt(String)` / `StringifiedNumber(String)`: string-encoded numeric types.
- `MainnetUrl` / `DevnetUrl` / `TestnetUrl`: branded URL types via `mainnet()`, `devnet()`, `testnet()`.
- `TokenAmount`: amount, decimals, uiAmountString.
- `AccountInfoBase` and encoding variants (`AccountInfoWithBase64EncodedData`, etc.).
- `TransactionError` / `InstructionError`: sealed error hierarchies.
- `SolanaRpcResponse<T>`: context + value wrapper for RPC responses.
- `Slot` / `Epoch` / `SignedLamports`: BigInt type aliases.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_rpc_types"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_rpc_types/solana_kit_rpc_types.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_rpc_types`.

- Import path: `package:solana_kit_rpc_types/solana_kit_rpc_types.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
