# solana_kit_token

[![pub package](https://img.shields.io/pub/v/solana_kit_token.svg)](https://pub.dev/packages/solana_kit_token) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_token) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_token)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_token)

SPL Token instruction builders, account decoders, codecs, and ergonomic helpers for the Solana Kit Dart SDK. ATA APIs from `solana_kit_associated_token_account` are re-exported for convenience.

<!-- {=packageInstallSection:"solana_kit_token"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_token": ^0.8.1
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

## Usage

Transfer tokens between accounts using the generated instruction builder:

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_token/solana_kit_token.dart';

void main() {
  const source = Address('_token_source_address_placeholder_');
  const destination = Address('token_dest_address_placeholder___');
  const authority = Address('authority_address_placeholder_');

  final ix = getTransferInstruction(
    programAddress: tokenProgramAddress,
    source: source,
    destination: destination,
    authority: authority,
    amount: BigInt.from(1000),
  );
  print(ix.programAddress);
}
```

Create a token account for a recipient using the re-exported ATA helper:

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_token/solana_kit_token.dart';

void main() {
  const payer = Address('payer_address_placeholder____');
  const owner = Address('owner_address_placeholder_____');
  const mint = Address('So11111111111111111111111111111111111111112');

  final ix = getCreateAssociatedTokenAccountInstruction(
    programAddress: associatedTokenProgramAddress,
    payer: payer,
    ata: Address('ata_address_placeholder________'),
    owner: owner,
    mint: mint,
    systemProgram: Address('11111111111111111111111111111111'),
    tokenProgram: tokenProgramAddress,
  );
  print(ix.programAddress);
}
```

Parse a transfer instruction back from its instruction data:

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_token/solana_kit_token.dart';

void main() {
  const source = Address('_token_source_address_placeholder_');
  const destination = Address('token_dest_address_placeholder___');
  const authority = Address('authority_address_placeholder_');

  final ix = getTransferInstruction(
    programAddress: tokenProgramAddress,
    source: source,
    destination: destination,
    authority: authority,
    amount: BigInt.from(1000),
  );

  final parsed = parseTransferInstruction(ix);
  print(parsed.amount);
}
```

## Key APIs

- `getTransferInstruction`, `getMintToInstruction`, `getApproveInstruction`, and other generated builders
- `getCreateAssociatedTokenAccountInstruction` (re-exported from ATA package)
- `parseTransferInstruction`, `parseMintToInstruction`, and other generated parsers
- `tokenProgramAddress` constant
- `getCreateMintInstructionPlan`, `getMintToAtaInstructionPlan`, `getTransferToAtaInstructionPlan` (ergonomic helpers)

## Re-exports

The full `solana_kit_associated_token_account` API surface is re-exported so callers can access ATA PDA helpers and instruction builders without adding a separate dependency.

## Upstream reference

Generated layer mirrors [solana-program/token](https://github.com/solana-program/token) at `js@v0.16.0`.
