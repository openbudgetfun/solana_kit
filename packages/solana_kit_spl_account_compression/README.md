# solana_kit_spl_account_compression

[![pub package](https://img.shields.io/pub/v/solana_kit_spl_account_compression.svg)](https://pub.dev/packages/solana_kit_spl_account_compression)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_spl_account_compression/latest/)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_spl_account_compression)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_spl_account_compression)

SPL Account Compression Program instruction builders and helpers for the Solana Kit Dart SDK.

This package provides a low-level interface for interacting with the [SPL Account Compression](https://github.com/solana-labs/solana-program-library/tree/master/account-compression) program, which manages concurrent Merkle trees used by compressed NFTs.

## Features

- **Concurrent Merkle tree account size calculation** for creating tree accounts
- **Program addresses** for SPL Account Compression and Noop programs
- **Generated instruction builders** for all SPL Account Compression instructions
- **Valid depth/size pairs** as defined by the on-chain program

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_spl_account_compression: ^0.1.0
```

## Usage

### Calculating Tree Account Size

```dart
import 'package:solana_kit_spl_account_compression/solana_kit_spl_account_compression.dart';

void main() {
  // Calculate the account size for a tree with depth 14 and buffer size 64
  final size = getConcurrentMerkleTreeAccountSize(
    maxDepth: 14,
    maxBufferSize: 64,
  );
  print(size); // 25896 bytes

  // With a custom canopy depth
  final sizeWithCanopy = getConcurrentMerkleTreeAccountSize(
    maxDepth: 14,
    maxBufferSize: 64,
    canopyDepth: 10,
  );
  print(sizeWithCanopy);
}
```

### Valid Depth/Size Pairs

```dart
// Check if a depth/size pair is valid
final isValid = isValidDepthSizePair(
  maxDepth: 14,
  maxBufferSize: 64,
);
print(isValid); // true

// List all valid pairs
print(validDepthSizePairs);
```

### Program Addresses

```dart
// SPL Account Compression program
print(splAccountCompressionProgramAddress);
// 'cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi'

// Noop program (log wrapper)
print(noopProgramAddress);
// 'noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK'

// Address objects for instruction builders
print(splAccountCompressionProgramAddressObject);
print(noopProgramAddressObject);
```

### Creating a Tree Account

```dart
import 'package:solana_kit_spl_account_compression/solana_kit_spl_account_compression.dart';

// 1. Calculate the required space
final space = getConcurrentMerkleTreeAccountSize(
  maxDepth: 14,
  maxBufferSize: 64,
);

// 2. Create the account (using solana_kit or similar)
// final createAccountIx = SystemProgram.createAccount(
//   fromAddress: payer,
//   newAccountAddress: merkleTree,
//   lamports: await rpc.getMinimumBalanceForRentExemption(space),
//   space: space,
//   programAddress: splAccountCompressionProgramAddressObject,
// );

// 3. Initialize the tree using solana_kit_mpl_bubblegum
// final initTreeIx = getCreateTreeInstructionPlan(
//   CreateTreeInput(
//     merkleTree: merkleTree,
//     payer: payer,
//     treeCreator: payer,
//     maxDepth: 14,
//     maxBufferSize: 64,
//   ),
// );
```

## Relationship with solana_kit_mpl_bubblegum

This package is a low-level dependency of [`solana_kit_mpl_bubblegum`](https://pub.dev/packages/solana_kit_mpl_bubblegum), which provides higher-level CNFT helpers (createTree, mintV1, etc.). You can use this package independently for low-level tree operations, or use `solana_kit_mpl_bubblegum` for the full compressed NFT workflow.

## License

MIT
