# solana_kit_codecs_data_structures

[![pub package](https://img.shields.io/pub/v/solana_kit_codecs_data_structures.svg)](https://pub.dev/packages/solana_kit_codecs_data_structures) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_codecs_data_structures/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_codecs_data_structures) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_codecs_data_structures)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_codecs_data_structures)

Composite data-structure codecs for Solana binary data in Dart. Provides structs, arrays, tuples, unions, maps, sets, nullable values, booleans, and other higher-level binary layouts. A port of [`@solana/codecs-data-structures`](https://github.com/anza-xyz/kit/tree/main/packages/codecs-data-structures) from the Solana TypeScript SDK.

<!-- {=packageInstallSection:"solana_kit_codecs_data_structures"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_codecs_data_structures": ^0.9.1
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_codecs_data_structures"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_codecs_data_structures
- API reference: https://pub.dev/documentation/solana_kit_codecs_data_structures/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_codecs_data_structures
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_codecs_data_structures

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

<!-- {=typedUnionHelpersSection} -->

### Typed Union Helpers

Prefer typed union helpers when a codec has a fixed, small number of variants. They improve IDE type inference, make exhaustive matching easier, and reduce unstructured casting in downstream code.

```dart
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  final codec = getUnion2Codec(
    getU8Codec(),
    getU32Codec(),
    (bytes, offset) => bytes.length - offset > 1 ? 1 : 0,
  );

  final encoded = codec.encode(const Union2Variant1<int, int>(1000));
  final decoded = codec.decode(encoded);

  print(encoded);
  print(decoded);
}
```

Use these helpers when your wire format has “one of a few known cases” and you want the Dart type system to preserve that fact.

<!-- {/typedUnionHelpersSection} -->

## Struct codecs

`getStructCodec` encodes a list of named fields in order. Decoding returns a `Map<String, dynamic>` keyed by field name.

```dart
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

void main() {
  final accountCodec = getStructCodec([
    ('discriminator', fixCodecSize(getBase58Codec(), 32)),
    ('lamports', getU64Codec()),
    ('owner', fixCodecSize(getBase58Codec(), 32)),
  ]);

  final encoded = accountCodec.encode({
    'discriminator': '11111111111111111111111111111111',
    'lamports': BigInt.from(1000000000),
    'owner': 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
  });

  final decoded = accountCodec.decode(encoded);
  print(decoded['lamports']); // BigInt.from(1000000000)
}
```

## Array and tuple codecs

`getArrayCodec` handles fixed-size and variable-length (prefixed) arrays. `getTupleCodec` encodes a fixed sequence of heterogeneous values without field names.

Prefixed array decoders reject missing, fractional, negative, and excessive item counts. The default maximum is one million items; pass `maxItems` when a wire format needs a smaller application limit.

```dart
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  // Fixed-size array of exactly 3 u8 values
  final fixedCodec = getArrayCodec(getU8Codec(), size: const FixedArraySize(3));
  fixedCodec.encode([10, 20, 30]); // [10, 20, 30]

  // Variable-length array with a u16 length prefix
  final prefixedCodec = getArrayCodec(
    getU8Codec(),
    size: PrefixedArraySize(getU16Codec()),
  );
  prefixedCodec.encode([1, 2, 3]); // u16 length prefix + byte data

  // Tuple codec
  final pairCodec = getTupleCodec([getU8Codec(), getU32Codec()]);
  final encoded = pairCodec.encode([42, 1000]);
  final decoded = pairCodec.decode(encoded);
  print(decoded); // [42, 1000]
}
```

## Union codecs

`getDiscriminatedUnionCodec` handles Rust-style enums with a discriminant byte. `getLiteralUnionCodec` handles simple enums with no data.

```dart
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  final instructionCodec = getDiscriminatedUnionCodec([
    ('initialize', getStructCodec([
      ('authority', getU32Codec()),
    ])),
    ('transfer', getStructCodec([
      ('amount', getU64Codec()),
    ])),
    ('close', getUnitCodec()),
  ]);

  final encoded = instructionCodec.encode({
    '__kind': 'transfer',
    'amount': BigInt.from(500),
  });

  final decoded = instructionCodec.decode(encoded);
  print(decoded['__kind']); // 'transfer'
}
```

## Nullable, boolean, map, set

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  // Nullable codec: 0x00 for null, 0x01 prefix + inner bytes for a value
  final nullableU64 = getNullableCodec<BigInt>(getU64Codec());
  nullableU64.encode(BigInt.from(42));
  nullableU64.encode(null);
  final result = nullableU64.decode(Uint8List.fromList([0x01, ...List.filled(8, 0)]));
  print(result); // BigInt.from(42)

  // Boolean codec
  final boolCodec = getBooleanCodec();
  boolCodec.encode(true);  // [1]
  boolCodec.encode(false);  // [0]

  // Map and set codecs
  final mapCodec = getMapCodec(getU8Codec(), getU32Codec());
  final mapEncoded = mapCodec.encode({1: 100, 2: 200});
  print(mapCodec.decode(mapEncoded)); // {1: 100, 2: 200}

  final setCodec = getSetCodec(getU8Codec());
  final setEncoded = setCodec.encode({1, 2, 3});
  print(setCodec.decode(setEncoded)); // {1, 2, 3}
}
```

## Key APIs

| Function                                       | Purpose                               |
| ---------------------------------------------- | ------------------------------------- |
| `getStructCodec`                               | Named fields in a fixed order         |
| `getArrayCodec`                                | Fixed or variable-length lists        |
| `getTupleCodec`                                | Heterogeneous value sequences         |
| `getMapCodec`, `getSetCodec`                   | Key-value and set data structures     |
| `getBooleanCodec`                              | Single-byte boolean                   |
| `getNullableCodec`                             | Nullable values with a presence flag  |
| `getDiscriminatedUnionCodec`                   | Rust-style enums with a discriminant  |
| `getLiteralUnionCodec`                         | Simple enums without payloads         |
| `getUnion2Codec` .. `getUnion6Codec`           | Typed union helpers                   |
| `getBytesCodec`                                | Raw byte arrays                       |
| `getConstantCodec`                             | Fixed byte sequence                   |
| `getUnitCodec`                                 | Void / no-data marker                 |
| `getHiddenPrefixCodec`, `getHiddenSuffixCodec` | Transparent prefix/suffix bytes       |
| `getBitArrayCodec`                             | Bit-level fields within integer bytes |

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_codecs_data_structures"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_codecs_data_structures`.

- Import path: `package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
