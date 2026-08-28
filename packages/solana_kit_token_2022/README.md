# solana_kit_token_2022

[![pub package](https://img.shields.io/pub/v/solana_kit_token_2022.svg)](https://pub.dev/packages/solana_kit_token_2022) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_token_2022) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_token_2022)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_token_2022)

Token-2022 extension-aware instruction builders, account decoders, codecs, and helpers for the Solana Kit Dart SDK. ATA APIs from `solana_kit_associated_token_account` are re-exported for convenience.

<!-- {=packageInstallSection:"solana_kit_token_2022"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_token_2022": ^0.7.1
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

## Usage

Compute the on-chain byte size for a mint with extensions before creating the account:

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_token_2022/solana_kit_token_2022.dart';

void main() {
  final size = getMintSize([
    TransferFeeConfig(
      transferFeeConfigAuthority: Address(
        'TkQKURgZR8bWbYq7bH6KcXQ3Pnt3D3qWbh4StE5jQ2Sf',
      ),
      withdrawWithheldAuthority: Address(
        '9xqYQKFSR3m3kqgT5sYRH7gH3j7Ab8F2PWasmY3dGkDm',
      ),
      withheldAmount: BigInt.zero,
      olderTransferFee: TransferFee(
        epoch: BigInt.from(0),
        maximumFee: BigInt.from(50000),
        transferFeeBasisPoints: 100,
      ),
      newerTransferFee: TransferFee(
        epoch: BigInt.from(0),
        maximumFee: BigInt.from(50000),
        transferFeeBasisPoints: 100,
      ),
    ),
  ]);
  print(size);

  final tokenSize = getTokenSize([
    TransferFeeAmount(withheldAmount: BigInt.from(50000)),
  ]);
  print(tokenSize);
}
```

Get the pre-initialize instructions that some extensions require before the mint itself:

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_token_2022/solana_kit_token_2022.dart';

void main() {
  const mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
  const payer = Address('11111111111111111111111111111111');
  const authority = Address(
    '5z3Y2Y6sxR28F9FJ6YqnbLBoz2tQqNqKVBwShck8KJ5W',
  );

  final preIx = getPreInitializeInstructionsForMintExtensions(
    mint: mint,
    extensions: [
      TransferFeeConfig(
        transferFeeConfigAuthority: authority,
        withdrawWithheldAuthority: authority,
        withheldAmount: BigInt.zero,
        olderTransferFee: TransferFee(
          epoch: BigInt.from(0),
          maximumFee: BigInt.from(50000),
          transferFeeBasisPoints: 100,
        ),
        newerTransferFee: TransferFee(
          epoch: BigInt.from(0),
          maximumFee: BigInt.from(50000),
          transferFeeBasisPoints: 100,
        ),
      ),
    ],
  );
  print(preIx.length);
  print(payer);
}
```

Use the generated instruction builders directly. The `programAddress` parameter targets Token-2022 instead of classic Token:

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_token_2022/solana_kit_token_2022.dart';

void main() {
  const mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
  const token = Address('11111111111111111111111111111112');
  const mintAuthority = Address(
    '5z3Y2Y6sxR28F9FJ6YqnbLBoz2tQqNqKVBwShck8KJ5W',
  );

  final ix = getMintToInstruction(
    programAddress: token2022ProgramAddress,
    mint: mint,
    token: token,
    mintAuthority: mintAuthority,
    amount: BigInt.from(1000000000),
  );
  print(ix.programAddress);
}
```

## Key APIs

- `getMintSize`, `getTokenSize` for account sizing with `Extension` instances
- `getPreInitializeInstructionsForMintExtensions` for pre-mint setup
- `getMintToInstruction`, `getTransferInstruction`, and other generated builders (pass `token2022ProgramAddress`)
- `token2022ProgramAddress` and `token2022ProgramAddressObject` constants

## Re-exports

The full `solana_kit_associated_token_account` API surface is re-exported so callers can access ATA PDA helpers and instruction builders without adding a separate dependency.

## Upstream reference

Generated layer mirrors [solana-program/token-2022](https://github.com/solana-program/token-2022) at `js@v0.16.0`.
