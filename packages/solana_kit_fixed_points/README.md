# solana_kit_fixed_points

[![pub package](https://img.shields.io/pub/v/solana_kit_fixed_points.svg)](https://pub.dev/packages/solana_kit_fixed_points)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_fixed_points)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_fixed_points)

Fixed-point number helpers for the [Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart SDK.

Ports the [`@solana/kit` fixed-points](https://github.com/anza-xyz/kit/tree/main/packages/fixed-points) API to Dart, providing binary and decimal fixed-point arithmetic, conversions, comparisons, formatting, codecs, parsing, rounding, and raw range utilities.

## Installation

```yaml
dependencies:
  solana_kit_fixed_points: ^0.4.0
```

## Usage

### Binary fixed-point arithmetic

```dart
import 'package:solana_kit_fixed_points/solana_kit_fixed_points.dart';

// Create a binary fixed-point value
final a = BinaryFixedPoint.fromBigInt(BigInt.from(1500), precision: 8);
final b = BinaryFixedPoint.fromBigInt(BigInt.from(500), precision: 8);

// Arithmetic
final sum = a + b;
final product = a * b;
final quotient = a ~/ b;

// Comparisons
print(a > b);  // true
print(a == b); // false

// Conversions
final asDecimal = a.toDecimal();
final asBigInt = a.toBigInt();
```

### Decimal fixed-point arithmetic

```dart
final price = DecimalFixedPoint.fromString('1.23456789', decimals: 9);
final quantity = DecimalFixedPoint.fromString('100.0', decimals: 9);

final total = price * quantity;
print(total.toString()); // '123.456789000'
```

### Formatting

```dart
final value = DecimalFixedPoint.fromString('1234.5678', decimals: 4);

// Format with fixed decimal places
print(value.toStringAsFixed(2)); // '1234.57'

// Format with significant digits
print(value.toStringAsPrecision(6)); // '1234.57'
```

### Codecs

```dart
// Binary codec for on-chain encoding
final codec = getBinaryFixedPointCodec(precision: 8);
final bytes = codec.encode(fixedPointValue);
final decoded = codec.decode(bytes);
```

## Features

- **Binary fixed-point** — `BinaryFixedPoint` with configurable precision (power-of-2 scaling)
- **Decimal fixed-point** — `DecimalFixedPoint` with configurable decimal places (power-of-10 scaling)
- **Arithmetic** — `+`, `-`, `*`, `~/`, `%` operators for both types
- **Comparisons** — `==`, `<`, `>`, `<=`, `>=` with structural equality
- **Conversions** — convert between binary and decimal representations
- **Formatting** — `toStringAsFixed`, `toStringAsPrecision`, custom formatters
- **Codecs** — binary encoders/decoders for on-chain serialization
- **Parsing** — parse from strings, `BigInt`, `int`, and `double`
- **Rounding** — configurable rounding modes (`halfUp`, `down`, `up`)
- **Ranges** — min/max values for a given precision or decimal count

## Upstream reference

Port of [@solana/kit fixed-points](https://github.com/anza-xyz/kit/tree/main/packages/fixed-points).
