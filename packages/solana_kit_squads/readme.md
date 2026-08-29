# solana_kit_squads

[![pub package](https://img.shields.io/pub/v/solana_kit_squads.svg)](https://pub.dev/packages/solana_kit_squads) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_squads/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_squads) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_squads)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_squads)

Squads V4 multisig program client for the Solana Kit Dart SDK: instruction builders, account codecs, error helpers, and PDA derivations for the [Squads V4](https://github.com/Squads-Protocol/v4) program (`SQDS4ep65T869zMMBKyuUq6aD6EgTu8psMjkvj52pCf`).

## What you get

- **Instruction builders** for all 36 program instructions: multisig creation and member management, config and vault transactions, batches, proposals, spending limits, and transaction buffers
- **Account codecs** for multisig, vault transactions, config transactions, proposals, spending limits, and program config
- **PDA derivations** matching the upstream `@sqds/multisig` TypeScript SDK byte-for-byte: multisig, vault, transaction, proposal, batch, batch transaction, spending limit, ephemeral signer, and program config
- **Error helpers** for all 45 program errors
- **Program parsing** via `parseSquadsMultisigInstruction`

<!-- {=packageInstallSection:"solana_kit_squads"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_squads": ^
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

:::

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_squads": ^
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

## Documentation

- Package page: https://pub.dev/packages/solana_kit_squads
- API reference: https://pub.dev/documentation/solana_kit_squads/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_squads
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_squads

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

<!-- {=docsSquadsSection} -->

### Derive the multisig and vault PDAs

Squads V4 PDA derivations match the upstream TypeScript SDK byte-for-byte, including vault indices and little-endian transaction indices.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_squads/solana_kit_squads.dart';

Future<void> main() async {
  final (multisig, bump) = await findMultisigPda(
    createKey: Address('CreateKey11111111111111111111111111111111111'),
  );
  final (vault, vaultBump) = await findVaultPda(multisig: multisig, index: 0);

  print(multisig);
  print(vault);
}
```

Instruction builders cover multisig creation, config transactions, vault transactions, batches, proposals, and spending limits.

<!-- {/docsSquadsSection} -->

## Key APIs

- `findMultisigPda`, `findVaultPda`, `findTransactionPda`, `findProposalPda`, `findBatchTransactionPda`, `findSpendingLimitPda`, `findEphemeralSignerPda`, `findProgramConfigPda`
- `getMultisigCreateInstruction`, `getVaultTransactionCreateInstruction`, `getProposalCreateInstruction`, and the rest of the generated builders
- `parseSquadsMultisigInstruction`, `identifySquadsMultisigInstruction`
- `getSquadsMultisigErrorMessage`, `SquadsMultisigError`

## Reference

Generated with `codama-renderers-dart` from the Squads-Protocol / v4 Anchor IDL (`sdk/multisig/idl/squads_multisig_program.json`). PDA derivations and seed constants mirror the upstream TypeScript SDK and the Rust `squads-client` reference exactly, including little-endian `u64` transaction indices and single-byte vault indices.
