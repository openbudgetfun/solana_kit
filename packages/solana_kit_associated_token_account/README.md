# solana_kit_associated_token_account

[![pub package](https://img.shields.io/pub/v/solana_kit_associated_token_account.svg)](https://pub.dev/packages/solana_kit_associated_token_account)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_associated_token_account)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_associated_token_account)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_associated_token_account)

Handwritten Associated Token Account (ATA) client for the Solana Kit Dart SDK.

This package exposes the canonical ATA program address, PDA derivation helpers,
and typed instruction builders shared by `solana_kit_token` and
`solana_kit_token_2022`.

## Usage

```dart
import 'package:solana_kit_associated_token_account/solana_kit_associated_token_account.dart';

Future<void> main() async {
  const owner = Address('11111111111111111111111111111111');
  const mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
  const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  final ata = getAssociatedTokenAddressSync(
    owner: owner,
    tokenProgram: tokenProgram,
    mint: mint,
  );

  print(ata.value);
}
```
