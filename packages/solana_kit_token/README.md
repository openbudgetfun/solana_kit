# solana_kit_token

[![pub package](https://img.shields.io/pub/v/solana_kit_token.svg)](https://pub.dev/packages/solana_kit_token)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_token)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_token)

SPL Token client for the [Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart SDK.

Provides a generated low-level client from the upstream Codama IDL plus
handwritten ergonomic helpers for common token workflows. Associated Token
Account (ATA) APIs are shared from
[`solana_kit_associated_token_account`](https://pub.dev/packages/solana_kit_associated_token_account)
and re-exported for convenience.

## Installation

```yaml
dependencies:
  solana_kit_token: ^0.4.0
```

## Usage

### Create a mint

```dart
import 'package:solana_kit_token/solana_kit_token.dart';

final result = await getCreateMintInstructionPlan(
  mintAuthority: mintAuthority,
  decimals: 9,
  rpc: rpc,
  signer: mintSigner,
);
```

### Mint to an ATA

```dart
final result = await getMintToAtaInstructionPlan(
  mint: mintAddress,
  destination: recipientAta,
  authority: mintAuthority,
  amount: BigInt.from(1000000000),
  rpc: rpc,
);
```

### Transfer to an ATA

```dart
final result = await getTransferToAtaInstructionPlan(
  source: senderAta,
  destination: recipientAta,
  authority: ownerSigner,
  amount: BigInt.from(500000000),
  rpc: rpc,
);
```

### Use generated builders directly

```dart
final ix = getTransferInstruction(
  programAddress: tokenProgramAddress,
  source: sourceAccount,
  destination: destAccount,
  owner: ownerAddress,
  amount: BigInt.from(1000),
);
```

## Generated layer

The generated code under `src/generated/` is produced from the upstream
Codama IDL at `solana-program/token`. It includes:

- **Instruction builders** — typed functions for all SPL Token instructions
- **Account decoders** — parse on-chain account data into typed structs
- **Codecs** — binary encoders/decoders for all token types
- **Error definitions** — typed error codes and messages
- **PDA helpers** — derive associated token account addresses
- **Program address** — `tokenProgramAddress` constant

## Ergonomic helpers

Higher-level functions compose generated instructions into common workflows:

| Helper                            | Description                                      |
| --------------------------------- | ------------------------------------------------ |
| `getCreateMintInstructionPlan`    | Create a new token mint with a payer and signer. |
| `getMintToAtaInstructionPlan`     | Mint tokens to an ATA, creating it if needed.    |
| `getTransferToAtaInstructionPlan` | Transfer tokens to a recipient's ATA.            |

Each helper handles ATA derivation, account existence checks, and
instruction composition automatically.

## Re-exports

This package re-exports the full
[`solana_kit_associated_token_account`](https://pub.dev/packages/solana_kit_associated_token_account)
API surface so callers can access ATA PDA helpers and instruction builders
without adding a separate dependency.

## Upstream reference

Generated layer mirrors
[solana-program/token](https://github.com/solana-program/token).
