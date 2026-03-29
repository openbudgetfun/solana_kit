# solana_kit_sysvars

[![pub package](https://img.shields.io/pub/v/solana_kit_sysvars.svg)](https://pub.dev/packages/solana_kit_sysvars)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_sysvars/latest/)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

System variable (sysvar) account access for the Solana Kit Dart SDK -- provides typed access to Solana runtime sysvar accounts like Clock, Rent, EpochSchedule, and more.

This is the Dart port of [`@solana/sysvars`](https://github.com/anza-xyz/kit/tree/main/packages/sysvars) from the Solana TypeScript SDK.

<!-- {=packageInstallSection:"solana_kit_sysvars"} -->

## Installation

Install the package directly:

```bash
dart pub add solana_kit_sysvars
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_sysvars"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_sysvars
- API reference: https://pub.dev/documentation/solana_kit_sysvars/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_sysvars
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_sysvars

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

<!-- {=docsSysvarSection} -->

## Work with sysvar codecs and addresses

Use `solana_kit_sysvars` when you need typed access to built-in cluster state
accounts such as `Clock`, `Rent`, or `EpochSchedule`.

```dart
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';

void main() {
  final clock = SysvarClock(
    slot: BigInt.from(100),
    epochStartTimestamp: BigInt.from(50),
    epoch: BigInt.from(2),
    leaderScheduleEpoch: BigInt.from(2),
    unixTimestamp: BigInt.from(1_700_000_000),
  );

  final encoded = getSysvarClockCodec().encode(clock);
  final decoded = getSysvarClockCodec().decode(encoded);

  print(sysvarClockAddress.value);
  print(decoded.slot);
}
```

These helpers keep sysvar access strongly typed and let you test sysvar layouts
without depending on live RPC responses.

<!-- {/docsSysvarSection} -->

## Usage

### Sysvar addresses

All Solana sysvar account addresses are available as `const Address` values.

```dart
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';

void main() {
  print(sysvarClockAddress);
  // Address('SysvarC1ock11111111111111111111111111111111')

  print(sysvarRentAddress);
  // Address('SysvarRent111111111111111111111111111111111')

  print(sysvarEpochScheduleAddress);
  // Address('SysvarEpochSchedu1e111111111111111111111111')

  print(sysvarSlotHashesAddress);
  // Address('SysvarS1otHashes111111111111111111111111111')

  print(sysvarSlotHistoryAddress);
  // Address('SysvarS1otHistory11111111111111111111111111')

  print(sysvarStakeHistoryAddress);
  // Address('SysvarStakeHistory1111111111111111111111111')

  print(sysvarRecentBlockhashesAddress);
  // Address('SysvarRecentB1ockHashes11111111111111111111')

  print(sysvarInstructionsAddress);
  // Address('Sysvar1nstructions1111111111111111111111111')

  print(sysvarEpochRewardsAddress);
  // Address('SysvarEpochRewards1111111111111111111111111')

  print(sysvarLastRestartSlotAddress);
  // Address('SysvarLastRestartS1ot1111111111111111111111')
}
```

### Fetching the Clock sysvar

The `Clock` sysvar contains data about the current slot, epoch, and Unix timestamp. It is updated every slot.

```dart
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';

Future<void> main() async {
  final rpc = createSolanaRpc('https://api.devnet.solana.com');

  final clock = await fetchSysvarClock(rpc);
  print('Current slot: ${clock.slot}');
  print('Current epoch: ${clock.epoch}');
  print('Unix timestamp: ${clock.unixTimestamp}');
  print('Epoch start timestamp: ${clock.epochStartTimestamp}');
  print('Leader schedule epoch: ${clock.leaderScheduleEpoch}');
}
```

The `SysvarClock` class contains:

```dart
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';

void main() {
  // Construct a SysvarClock value directly (e.g. for testing).
  final clock = SysvarClock(
    slot: BigInt.from(100),
    epochStartTimestamp: BigInt.from(1700000000),
    epoch: BigInt.from(5),
    leaderScheduleEpoch: BigInt.from(6),
    unixTimestamp: BigInt.from(1700001000),
  );

  print(clock.slot); // 100
  print(clock.epoch); // 5
}
```

### Fetching the Rent sysvar

The `Rent` sysvar contains rent configuration for the cluster.

```dart
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';

Future<void> main() async {
  final rpc = createSolanaRpc('https://api.devnet.solana.com');

  final rent = await fetchSysvarRent(rpc);
  print('Lamports per byte-year: ${rent.lamportsPerByteYear}');
  print('Exemption threshold: ${rent.exemptionThreshold} years');
  print('Burn percent: ${rent.burnPercent}%');
}
```

### Fetching the EpochSchedule sysvar

The `EpochSchedule` sysvar includes the number of slots per epoch, leader schedule timing, and warmup information.

```dart
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';

Future<void> main() async {
  final rpc = createSolanaRpc('https://api.devnet.solana.com');

  final schedule = await fetchSysvarEpochSchedule(rpc);
  print('Slots per epoch: ${schedule.slotsPerEpoch}');
  print('Leader schedule slot offset: ${schedule.leaderScheduleSlotOffset}');
  print('Warmup: ${schedule.warmup}');
  print('First normal epoch: ${schedule.firstNormalEpoch}');
  print('First normal slot: ${schedule.firstNormalSlot}');
}
```

### Fetching encoded sysvar accounts

For sysvars that do not yet have a dedicated fetch function, or when you need the raw encoded bytes, use `fetchEncodedSysvarAccount`.

```dart
import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';

Future<void> main() async {
  final rpc = createSolanaRpc('https://api.devnet.solana.com');

  // Fetch the raw encoded data for any sysvar.
  final maybeAccount = await fetchEncodedSysvarAccount(
    rpc,
    sysvarSlotHashesAddress,
  );

  switch (maybeAccount) {
    case ExistingAccount<Uint8List>(:final account):
      print('SlotHashes data: ${account.data.length} bytes');
    case NonExistingAccount():
      print('Sysvar account not found');
  }
}
```

### Using sysvar codecs

Each sysvar type has encoder, decoder, and codec factory functions for binary serialization.

```dart
import 'dart:typed_data';

import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';

void main() {
  // Encode a Clock sysvar value to bytes.
  final encoder = getSysvarClockEncoder();
  final clock = SysvarClock(
    slot: BigInt.from(42),
    epochStartTimestamp: BigInt.from(1700000000),
    epoch: BigInt.from(5),
    leaderScheduleEpoch: BigInt.from(6),
    unixTimestamp: BigInt.from(1700001000),
  );
  final bytes = encoder.encode(clock);
  print(bytes.length); // 40 (sysvarClockSize)

  // Decode bytes back to a SysvarClock.
  final decoder = getSysvarClockDecoder();
  final (decoded, _) = decoder.read(bytes, 0);
  print(decoded.slot); // 42

  // Use the combined codec.
  final codec = getSysvarClockCodec();
  final roundTripped = codec.decode(codec.encode(clock));
  print(roundTripped == clock); // true
}
```

## API Reference

### Sysvar addresses

| Constant                         | Address                                       |
| -------------------------------- | --------------------------------------------- |
| `sysvarClockAddress`             | `SysvarC1ock11111111111111111111111111111111` |
| `sysvarRentAddress`              | `SysvarRent111111111111111111111111111111111` |
| `sysvarEpochScheduleAddress`     | `SysvarEpochSchedu1e111111111111111111111111` |
| `sysvarEpochRewardsAddress`      | `SysvarEpochRewards1111111111111111111111111` |
| `sysvarInstructionsAddress`      | `Sysvar1nstructions1111111111111111111111111` |
| `sysvarLastRestartSlotAddress`   | `SysvarLastRestartS1ot1111111111111111111111` |
| `sysvarRecentBlockhashesAddress` | `SysvarRecentB1ockHashes11111111111111111111` |
| `sysvarSlotHashesAddress`        | `SysvarS1otHashes111111111111111111111111111` |
| `sysvarSlotHistoryAddress`       | `SysvarS1otHistory11111111111111111111111111` |
| `sysvarStakeHistoryAddress`      | `SysvarStakeHistory1111111111111111111111111` |

### Sysvar types

| Class                 | Fields                                                                                       |
| --------------------- | -------------------------------------------------------------------------------------------- |
| `SysvarClock`         | `slot`, `epochStartTimestamp`, `epoch`, `leaderScheduleEpoch`, `unixTimestamp`               |
| `SysvarRent`          | `lamportsPerByteYear`, `exemptionThreshold`, `burnPercent`                                   |
| `SysvarEpochSchedule` | `slotsPerEpoch`, `leaderScheduleSlotOffset`, `warmup`, `firstNormalEpoch`, `firstNormalSlot` |

### Fetch functions

| Function                                             | Description                                                                          |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `fetchSysvarClock(rpc, {config?})`                   | Fetches and decodes the Clock sysvar. Returns `Future<SysvarClock>`.                 |
| `fetchSysvarRent(rpc, {config?})`                    | Fetches and decodes the Rent sysvar. Returns `Future<SysvarRent>`.                   |
| `fetchSysvarEpochSchedule(rpc, {config?})`           | Fetches and decodes the EpochSchedule sysvar. Returns `Future<SysvarEpochSchedule>`. |
| `fetchEncodedSysvarAccount(rpc, address, {config?})` | Fetches any sysvar as a `MaybeEncodedAccount`.                                       |

### Codec functions

| Sysvar        | Encoder                           | Decoder                           | Codec                           |
| ------------- | --------------------------------- | --------------------------------- | ------------------------------- |
| Clock         | `getSysvarClockEncoder()`         | `getSysvarClockDecoder()`         | `getSysvarClockCodec()`         |
| Rent          | `getSysvarRentEncoder()`          | `getSysvarRentDecoder()`          | `getSysvarRentCodec()`          |
| EpochSchedule | `getSysvarEpochScheduleEncoder()` | `getSysvarEpochScheduleDecoder()` | `getSysvarEpochScheduleCodec()` |

### Size constants

| Constant                  | Value | Description                                     |
| ------------------------- | ----- | ----------------------------------------------- |
| `sysvarClockSize`         | `40`  | Size of the Clock sysvar data in bytes.         |
| `sysvarRentSize`          | `17`  | Size of the Rent sysvar data in bytes.          |
| `sysvarEpochScheduleSize` | `33`  | Size of the EpochSchedule sysvar data in bytes. |

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_sysvars"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_sysvars/solana_kit_sysvars.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_sysvars`.

- Import path: `package:solana_kit_sysvars/solana_kit_sysvars.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
