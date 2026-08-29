# solana_kit_squads

[![pub package](https://img.shields.io/pub/v/solana_kit_squads.svg)](https://pub.dev/packages/solana_kit_squads) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_squads/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_squads) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_squads)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_squads)

Squads V4 multisig program client for the Solana Kit Dart SDK: instruction builders, account codecs, error helpers, and PDA derivations for the [Squads V4](https://github.com/Squads-Protocol/v4) program (`SQDS4ep65T869zMMBKyuUq6aD6EgTu8psMjkvj52pCf`).

## What you get

- **Instruction builders** for all 36 program instructions: multisig creation and member management, config and vault transactions, batches, proposals, spending limits, and transaction buffers
- **Account codecs** for multisig, vault transactions, config transactions, proposals, spending limits, and program config
- **PDA derivations** matching the upstream `@sqds/multisig` TypeScript SDK byte-for-byte: multisig, vault, transaction, proposal, batch, batch transaction, spending limit, ephemeral signer, and program config
- **Error helpers** for all 45 program errors
- **Program parsing** via `parseSquadsMultisigInstruction`

## Usage

### Derive the multisig and vault PDAs

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_squads/solana_kit_squads.dart';

Future<void> main() async {
  const createKeyAddress = Address(
    '9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM',
  );

  final (multisig, bump) = await findMultisigPda(createKey: createKeyAddress);
  final (vault, vaultBump) = await findVaultPda(multisig: multisig, index: 0);
  print('multisig $multisig (bump $bump), vault $vault (bump $vaultBump)');
}
```

### Create a multisig

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_squads/solana_kit_squads.dart';

Future<void> main() async {
  const createKeyAddress = Address(
    '9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM',
  );
  const creatorAddress = Address(
    '4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7ua4s6guT976W',
  );
  const systemProgram = Address('11111111111111111111111111111111');

  final (multisigPda, _) = await findMultisigPda(createKey: createKeyAddress);
  final (programConfigPda, _) = await findProgramConfigPda();
  // The fee treasury is vault #255 of the new multisig.
  final (treasuryPda, _) = await findVaultPda(
    multisig: multisigPda,
    index: 255,
  );

  final instruction = getMultisigCreateV2Instruction(
    programAddress: squadsMultisigProgramAddressObject,
    programConfig: programConfigPda,
    treasury: treasuryPda,
    multisig: multisigPda,
    createKey: createKeyAddress,
    creator: creatorAddress,
    systemProgram: systemProgram,
    configAuthority: creatorAddress,
    threshold: 1,
    members: [
      Member(
        key: creatorAddress,
        permissions: const Permissions(mask: 7), // initiate + vote + execute
      ),
    ],
    timeLock: 0,
    rentCollector: null,
    memo: null,
  );
  print('instruction with ${instruction.accounts!.length} accounts');
}
```

## Key APIs

- `findMultisigPda`, `findVaultPda`, `findTransactionPda`, `findProposalPda`, `findBatchTransactionPda`, `findSpendingLimitPda`, `findEphemeralSignerPda`, `findProgramConfigPda`
- `getMultisigCreateInstruction`, `getVaultTransactionCreateInstruction`, `getProposalCreateInstruction`, and the rest of the generated builders
- `parseSquadsMultisigInstruction`, `identifySquadsMultisigInstruction`
- `getSquadsMultisigErrorMessage`, `SquadsMultisigError`

## Reference

Generated with `codama-renderers-dart` from the Squads-Protocol / v4 Anchor IDL (`sdk/multisig/idl/squads_multisig_program.json`). PDA derivations and seed constants mirror the upstream TypeScript SDK and the Rust `squads-client` reference exactly, including little-endian `u64` transaction indices and single-byte vault indices.
