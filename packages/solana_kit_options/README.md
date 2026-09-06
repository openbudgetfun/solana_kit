# solana_kit_options

[![pub package](https://img.shields.io/pub/v/solana_kit_options.svg)](https://pub.dev/packages/solana_kit_options) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_options/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_options) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_options)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_options)

A Rust-like `Option<T>` type and its codec for encoding optional values in Solana on-chain data.

Use this package when a data structure has a field that may be absent, and you need that absence to survive serialization. The `Option` type makes the two cases explicit, and `getOptionCodec` writes the presence flag and value to the wire.

<!-- {=packageInstallSection:"solana_kit_options"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_options": ^0.9.2
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_options"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_options
- API reference: https://pub.dev/documentation/solana_kit_options/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_options
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_options

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Constructing options

`some(value)` and `none<T>()` build the two variants. Pattern matching is the idiomatic way to read them back.

```dart
import 'package:solana_kit_options/solana_kit_options.dart';

void main() {
  final maybeFeePayer = some('FEE_PAYER_ADDRESS');
  final noMemo = none<String>();

  final feePayerText = switch (maybeFeePayer) {
    Some<String>(:final value) => 'fee payer: $value',
    None<String>() => 'no fee payer set',
  };

  final memoText = switch (noMemo) {
    Some<String>(:final value) => 'memo: $value',
    None<String>() => 'memo not provided',
  };

  print(feePayerText);
  print(memoText);
}
```

### Unwrapping

`unwrapOption` returns the value or throws, and `unwrapOptionOr` returns a fallback for `None`.

```dart
import 'package:solana_kit_options/solana_kit_options.dart';

void main() {
  final value = some(42);
  final empty = none<int>();

  print(unwrapOption(value)); // 42
  print(unwrapOptionOr(empty, () => -1)); // -1
}
```

### Encoding and decoding

`getOptionCodec` writes a one-byte presence flag followed by the value codec's bytes. `getOptionEncoder` and `getOptionDecoder` expose the two halves.

Decoding accepts only presence flags `0` and `1`, including custom numeric prefixes. A `None` value with configured padding must include all of that padding; constant byte markers must match exactly. With a presence flag, `ZeroesOptionNoneValue` ignores the padding's contents to support COption layouts with stale payload bytes.

```dart
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_options/solana_kit_options.dart';

void main() {
  final codec = getOptionCodec(getU8Codec());

  final encoded = codec.encode(some(7));
  print(encoded); // [1, 7]

  final decoded = codec.decode(encoded);
  print(decoded); // Some(7)

  final noneBytes = codec.encode(none<int>());
  print(noneBytes); // [0]
}
```

## Key APIs

- `Option<T>` sealed type with `Some<T>` and `None<T>` variants.
- `some(value)`, `none<T>()`, `isSome`, `isNone`.
- `unwrapOption`, `unwrapOptionOr`, `unwrapOptionOrElse`.
- `getOptionCodec`, `getOptionEncoder`, `getOptionDecoder`.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_options"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_options/solana_kit_options.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_options`.

- Import path: `package:solana_kit_options/solana_kit_options.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
