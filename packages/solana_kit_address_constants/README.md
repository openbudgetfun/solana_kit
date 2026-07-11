# solana_kit_address_constants

[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_address_constants)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_address_constants)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_address_constants)

Well-known Solana address constants for programs, sysvars, SPL programs,
Metaplex programs, and token mints for the
[Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart SDK.

Provides centralized `Address` constants so that any package can reference
well-known on-chain addresses without importing the full domain package
or hardcoding strings.

## Installation

<!-- {=packageInstallSection:"solana_kit_address_constants"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_address_constants": ^0.5.0
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

## Usage

```dart
import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';

// Native program addresses
final system = systemProgramAddress;
final stake = stakeProgramAddress;
final computeBudget = computeBudgetProgramAddress;

// Sysvar addresses
final rent = sysvarRentAddress;
final clock = sysvarClockAddress;

// SPL program addresses
final token = tokenProgramAddress;
final ata = associatedTokenProgramAddress;

// Metaplex program addresses
final metadata = tokenMetadataProgramAddress;

// Well-known token mint addresses
final wrappedSol = wrappedSolMintAddress;
final usdc = usdcMintAddress;
```

## Key APIs

| Constant                        | Description                                   |
| ------------------------------- | --------------------------------------------- |
| `systemProgramAddress`          | System program address                        |
| `stakeProgramAddress`           | Stake program address                         |
| `voteProgramAddress`            | Vote program address                          |
| `computeBudgetProgramAddress`   | Compute Budget program address                |
| `sysvarOwnerAddress`            | Owner address for all sysvar accounts         |
| `sysvarClockAddress`            | Clock sysvar address                          |
| `sysvarRentAddress`             | Rent sysvar address                           |
| `tokenProgramAddress`           | SPL Token program address                     |
| `token2022ProgramAddress`       | Token-2022 (Token Extensions) program address |
| `associatedTokenProgramAddress` | SPL Associated Token Account program address  |
| `tokenMetadataProgramAddress`   | Metaplex Token Metadata program address       |
| `wrappedSolMintAddress`         | Wrapped SOL mint address                      |
| `usdcMintAddress`               | USDC mint address                             |
| `usdtMintAddress`               | USDT mint address                             |
