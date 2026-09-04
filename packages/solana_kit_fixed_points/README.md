# solana_kit_fixed_points

[![pub package](https://img.shields.io/pub/v/solana_kit_fixed_points.svg)](https://pub.dev/packages/solana_kit_fixed_points) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_fixed_points/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_fixed_points) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_fixed_points)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_fixed_points)

Fixed-point number types and arithmetic for Solana programs in Dart. Provides binary (power-of-2) and decimal fixed-point representations with full codec support. A port of [`@solana/fixed-points`](https://github.com/anza-xyz/kit/tree/main/packages/fixed-points) from the Solana TypeScript SDK.

<!-- {=packageInstallSection:"solana_kit_fixed_points"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_fixed_points": ^0.9.1
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_fixed_points"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_fixed_points
- API reference: https://pub.dev/documentation/solana_kit_fixed_points/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_fixed_points
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_fixed_points

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Binary fixed-point numbers

Binary fixed-point types store values as integers scaled by a power of 2. Use them when you need deterministic arithmetic at known bit widths, like Solana token amounts that represent fractional lamports or ticks.

Construct a `BinaryFixedPoint` by specifying the raw scaled integer, fractional bit count, and total bit width:

```dart
import 'package:solana_kit_fixed_points/solana_kit_fixed_points.dart';

void main() {
  // 1.0 stored as raw = 2^32, with 32 fractional bits in a 64-bit word
  final value = BinaryFixedPoint(
    raw: BigInt.from(1) << 32,
    fractionalBits: 32,
    totalBits: 64,
  );
  print(value.toDecimalString()); // '1'

  // Arithmetic with + and -
  final a = BinaryFixedPoint(raw: BigInt.from(3) << 32, fractionalBits: 32, totalBits: 64);
  final b = BinaryFixedPoint(raw: BigInt.from(2) << 32, fractionalBits: 32, totalBits: 64);
  print((a + b).toDecimalString()); // '5'

  // Comparisons use named functions, not operators
  print(gtBinaryFixedPoint(a, b)); // true
}
```

`rawBinaryFixedPoint` returns a factory function that constructs values with a fixed shape. `BinaryFixedPoint.parse` reads a decimal string and converts it to the binary representation:

```dart
import 'package:solana_kit_fixed_points/solana_kit_fixed_points.dart';

void main() {
  final make = rawBinaryFixedPoint(FixedPointSignedness.unsigned, 64, 32);
  final a = make(BigInt.from(3) << 32);
  print(a.toDecimalString()); // '3'

  final parsed = BinaryFixedPoint.parse('1.5', fractionalBits: 32, totalBits: 64);
  print(parsed.toDecimalString()); // '1.5'
}
```

## Decimal fixed-point numbers

Decimal fixed-point types use a power-of-10 scale. Useful when the on-wire format stores fractional amounts as integers (for example, token decimals).

```dart
import 'package:solana_kit_fixed_points/solana_kit_fixed_points.dart';

void main() {
  // 1.5 SOL stored as 1_500_000_000 lamports (9 decimal places)
  final price = DecimalFixedPoint(raw: BigInt.from(1500000000), decimals: 9, totalBits: 64);
  print(price.toDecimalString()); // '1.5'

  final quantity = DecimalFixedPoint(raw: BigInt.from(2000000000), decimals: 9, totalBits: 64);
  print((price + quantity).toDecimalString()); // '3.5'

  // Parse from a decimal string
  final solAmount = DecimalFixedPoint.parse('0.075', decimals: 9, totalBits: 64);
  print(solAmount.raw); // BigInt.from(75000000)
}
```

## Input validation

Use the parsing and `rawBinaryFixedPoint` / `rawDecimalFixedPoint` factories to validate values when constructing them. The direct constructors store the supplied fields; `assertIsBinaryFixedPoint` and `assertIsDecimalFixedPoint` validate their scale, bit width, signedness, and raw range. Their `isBinaryFixedPoint` and `isDecimalFixedPoint` counterparts return `false` for invalid values.

Parsing requires at least one decimal digit. Inputs such as `.`, `-`, and `-.` throw `FormatException`; `.5` and `1.` remain valid.

## Fixed-point codecs

`getBinaryFixedPointCodec` encodes and decodes binary fixed-point values. `getDecimalFixedPointCodec` does the same for decimal fixed-point values. Both take the signedness, total bit width, and fractional bit/decimal count. Encoders reject raw values outside that signed or unsigned range with `RangeError` before modifying the destination buffer, including values created with a direct constructor:

```dart
import 'package:solana_kit_fixed_points/solana_kit_fixed_points.dart';

void main() {
  final binCodec = getBinaryFixedPointCodec(FixedPointSignedness.unsigned, 64, 32);
  final binValue = BinaryFixedPoint(raw: BigInt.from(1) << 32, fractionalBits: 32, totalBits: 64);
  final binEncoded = binCodec.encode(binValue);
  print(binCodec.decode(binEncoded).toDecimalString()); // '1'

  final decCodec = getDecimalFixedPointCodec(FixedPointSignedness.unsigned, 64, 9);
  final decValue = DecimalFixedPoint(raw: BigInt.from(1500000000), decimals: 9, totalBits: 64);
  final decEncoded = decCodec.encode(decValue);
  print(decCodec.decode(decEncoded).toDecimalString()); // '1.5'
}
```

## Formatting

`binaryFixedPointToString` and `decimalFixedPointToString` produce human-readable strings. `formatBinaryFixedPoint` and `formatDecimalFixedPoint` pass the scientific-notation representation to a custom formatter:

```dart
import 'package:solana_kit_fixed_points/solana_kit_fixed_points.dart';

void main() {
  final value = BinaryFixedPoint(raw: BigInt.from(1) << 32, fractionalBits: 32, totalBits: 64);
  print(binaryFixedPointToString(value)); // '1'

  final formatted = formatBinaryFixedPoint((sci) => '$sci SOL', value);
  print(formatted); // '4294967296E-32 SOL'
}
```

## Key APIs

| Symbol                                                  | Description                                       |
| ------------------------------------------------------- | ------------------------------------------------- |
| `BinaryFixedPoint`                                      | Power-of-2 fixed-point number                     |
| `DecimalFixedPoint`                                     | Power-of-10 fixed-point number                    |
| `BinaryFixedPoint.parse`                                | Parse a decimal string into a binary fixed-point  |
| `DecimalFixedPoint.parse`                               | Parse a decimal string into a decimal fixed-point |
| `rawBinaryFixedPoint`                                   | Factory function for fixed-shape binary values    |
| `rawDecimalFixedPoint`                                  | Factory function for fixed-shape decimal values   |
| `getBinaryFixedPointCodec`                              | Codec for binary fixed-point wire format          |
| `getDecimalFixedPointCodec`                             | Codec for decimal fixed-point wire format         |
| `binaryFixedPointToString`                              | Format a binary fixed-point as a string           |
| `decimalFixedPointToString`                             | Format a decimal fixed-point as a string          |
| `formatBinaryFixedPoint`                                | Format via a custom scientific-notation handler   |
| `formatDecimalFixedPoint`                               | Format via a custom scientific-notation handler   |
| `gtBinaryFixedPoint`, `ltBinaryFixedPoint`, etc.        | Comparison functions                              |
| `addBinaryFixedPoint`, `subtractBinaryFixedPoint`, etc. | Arithmetic functions                              |
