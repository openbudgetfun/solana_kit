# solana_kit_token_2022

[![pub package](https://img.shields.io/pub/v/solana_kit_token_2022.svg)](https://pub.dev/packages/solana_kit_token_2022)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_token_2022)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_token_2022)

SPL Token 2022 client for the [Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart SDK.

Provides a generated low-level client from the upstream Codama IDL plus
focused handwritten helpers for extension-aware token workflows. Associated
Token Account (ATA) APIs are shared from
[`solana_kit_associated_token_account`](https://pub.dev/packages/solana_kit_associated_token_account)
and re-exported for convenience.

## Installation

<!-- {=packageInstallSection:"solana_kit_token_2022"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_token_2022": ^0.5.1
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

## Usage

### Compute mint size with extensions

```dart
import 'package:solana_kit_token_2022/solana_kit_token_2022.dart';

// Calculate on-chain account size for a mint with extensions
final size = getMintSize([
  ExtensionType.transferFeeConfig,
  ExtensionType.defaultAccountState,
]);
```

### Get pre-initialize instructions for extensions

```dart
// Some extensions require initialization before the mint itself
final preIx = getInitializeInstructionsForExtensions(
  extensions: [ExtensionType.transferFeeConfig],
  mint: mintAddress,
  payer: payer,
);
```

### Compute token account size

```dart
final size = getTokenSize([ExtensionType.transferFeeAmount]);
```

### Use generated builders directly

```dart
final ix = getMintToInstruction(
  programAddress: token2022ProgramAddress,
  mint: mintAddress,
  destination: tokenAccount,
  authority: mintAuthority,
  amount: BigInt.from(1000000000),
);
```

## Generated layer

The generated code under `src/generated/` is produced from the upstream
Codama IDL at `solana-program/token-2022`. It includes:

- **Instruction builders** — typed functions for all Token 2022 instructions
- **Account decoders** — parse on-chain account data into typed structs
- **Codecs** — binary encoders/decoders for all token types
- **Error definitions** — typed error codes and messages
- **PDA helpers** — derive associated token account addresses
- **Program address** — `token2022ProgramAddress` constant

## Handwritten helpers

| Helper                                   | Description                                                  |
| ---------------------------------------- | ------------------------------------------------------------ |
| `getMintSize(List<ExtensionType>)`       | Compute on-chain byte size for a mint with given extensions. |
| `getTokenSize(List<ExtensionType>)`      | Compute on-chain byte size for a token account.              |
| `getInitializeInstructionsForExtensions` | Get pre-initialize instructions for mint extensions.         |

## Re-exports

This package re-exports the full
[`solana_kit_associated_token_account`](https://pub.dev/packages/solana_kit_associated_token_account)
API surface so callers can access ATA PDA helpers and instruction builders
without adding a separate dependency.

## Upstream reference

Generated layer mirrors
[solana-program/token-2022](https://github.com/solana-program/token-2022).
