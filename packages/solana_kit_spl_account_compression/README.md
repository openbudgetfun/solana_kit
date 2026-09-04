# solana_kit_spl_account_compression

[![pub package](https://img.shields.io/pub/v/solana_kit_spl_account_compression.svg)](https://pub.dev/packages/solana_kit_spl_account_compression) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_spl_account_compression/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_spl_account_compression) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_spl_account_compression)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_spl_account_compression)

Concurrent Merkle tree account sizing, valid depth/buffer lookups, program addresses, and generated instruction builders for the SPL Account Compression program.

<!-- {=packageInstallSection:"solana_kit_spl_account_compression"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_spl_account_compression": ^0.4.1
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

## Usage

Calculate the on-chain account size for a tree with a given depth and buffer size:

```dart
import 'package:solana_kit_spl_account_compression/solana_kit_spl_account_compression.dart';

void main() {
  final size = getConcurrentMerkleTreeAccountSize(
    maxDepth: 14,
    maxBufferSize: 64,
  );
  print(size); // 31800 (no canopy by default)

  final sizeWithCanopy = getConcurrentMerkleTreeAccountSize(
    maxDepth: 14,
    maxBufferSize: 64,
    canopyDepth: 10,
  );
  print(sizeWithCanopy);
}
```

Check whether a depth/buffer pair is valid and list all valid pairs:

```dart
import 'package:solana_kit_spl_account_compression/solana_kit_spl_account_compression.dart';

void main() {
  final isValid = isValidDepthSizePair(maxDepth: 14, maxBufferSize: 64);
  print(isValid); // true

  print(validDepthSizePairs);
}
```

Reference the program and noop addresses:

```dart
import 'package:solana_kit_spl_account_compression/solana_kit_spl_account_compression.dart';

void main() {
  print(splAccountCompressionProgramAddress);
  // cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi

  print(noopProgramAddress);
  // noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK
}
```

## Relationship with solana_kit_mpl_bubblegum

This package is a low-level dependency of `solana_kit_mpl_bubblegum`, which provides higher-level CNFT helpers (createTree, mintV1, etc.). Use this package directly for tree sizing and instruction building, or use `solana_kit_mpl_bubblegum` for the full compressed NFT workflow.

## License

MIT
