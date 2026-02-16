# solana_kit_sysvars

System variable (sysvar) account access for the Solana Kit Dart SDK -- provides typed access to Solana runtime sysvar accounts like Clock, Rent, EpochSchedule, and more.

This is the Dart port of [`@solana/sysvars`](https://github.com/anza-xyz/kit/tree/main/packages/sysvars) from the Solana TypeScript SDK.

## Installation

Add `solana_kit_sysvars` to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_sysvars:
```

Or, if you are using the umbrella package:

```yaml
dependencies:
  solana_kit:
```

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
