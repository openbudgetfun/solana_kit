# solana_kit_stake

[![pub package](https://img.shields.io/pub/v/solana_kit_stake.svg)](https://pub.dev/packages/solana_kit_stake)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_stake)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_stake)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_stake)

Stake Program instruction builders, account codecs, and instruction-plan helpers for the Solana Kit Dart SDK.

## Usage

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_stake/solana_kit_stake.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';

void main() {
  const stake = Address('11111111111111111111111111111111');
  const vote = Address('Vote111111111111111111111111111111111111111');
  const authority = Address('11111111111111111111111111111112');

  final instruction = getDelegateStakeInstruction(
    programAddress: solanaStakeInterfaceProgramAddress,
    stake: stake,
    vote: vote,
    clockSysvar: sysvarClockAddress,
    stakeHistorySysvar: sysvarStakeHistoryAddress,
    stakeConfigAccount: stakeConfigAddress,
    stakeAuthority: authority,
  );

  final parsed = parseDelegateStakeInstruction(instruction);
  print(parsed.discriminator);
}
```

## Key APIs

- Generated instruction builders for all Stake Program instructions.
- `StakeAccount` and `StakeStateV2` codecs for account decoding.
- `getCreateStakeAccountInstructionPlan` and `getDelegateStakeInstructionPlan` ergonomic helpers.
- Program address constant: `solanaStakeInterfaceProgramAddress`.
