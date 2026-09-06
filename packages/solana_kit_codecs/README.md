# solana_kit_codecs

[![pub package](https://img.shields.io/pub/v/solana_kit_codecs.svg)](https://pub.dev/packages/solana_kit_codecs) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_codecs/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_codecs) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_codecs)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_codecs)

The codec umbrella for the Solana Kit SDK. One import gives you the core codec interfaces plus the number, string, data-structure, fixed-point, and option codecs used to serialize Solana on-chain data.

Import this package when you need to encode or decode binary data and do not want to track which codec sub-package each function lives in.

<!-- {=packageInstallSection:"solana_kit_codecs"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_codecs": ^0.9.2
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_codecs"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_codecs
- API reference: https://pub.dev/documentation/solana_kit_codecs/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_codecs
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_codecs

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

```dart
import 'package:solana_kit_codecs/solana_kit_codecs.dart';

void main() {
  // Encode a u64 as 8 little-endian bytes.
  final u64Codec = getU64Codec();
  final bytes = u64Codec.encode(BigInt.from(1000000));
  print('Encoded: ${bytes.length} bytes'); // 8

  // Decode it back.
  final value = u64Codec.decode(bytes);
  print('Decoded: $value'); // 1000000

  // Encode a UTF-8 string with a u16 length prefix.
  final stringCodec = getUtf8Codec();
  final text = stringCodec.encode('Hello, Solana!');
  print('String bytes: ${text.length}');
}
```

## Re-exported packages

| Package                             | Contents                                                           |
| ----------------------------------- | ------------------------------------------------------------------ |
| `solana_kit_codecs_core`            | `Encoder`, `Decoder`, `Codec` interfaces and composition helpers   |
| `solana_kit_codecs_numbers`         | Integer and float codecs (u8-u128, i8-i128, f32, f64)              |
| `solana_kit_codecs_strings`         | String codecs (utf8, base58, base64, base16)                       |
| `solana_kit_codecs_data_structures` | Struct, array, tuple, map, set, enum, boolean, and nullable codecs |
| `solana_kit_fixed_points`           | Fixed-point arithmetic and codecs                                  |
| `solana_kit_options`                | Rust-like `Option<T>` type and codec                               |

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_codecs"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_codecs/solana_kit_codecs.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_codecs`.

- Import path: `package:solana_kit_codecs/solana_kit_codecs.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
