# solana_kit_options

A Rust-like `Option<T>` type and corresponding codec for encoding and decoding optional values in Solana on-chain data.

This is a Dart port of [`@solana/options`](https://github.com/anza-xyz/kit/tree/main/packages/options) from the Solana TypeScript SDK.

## Installation

```yaml
dependencies:
  solana_kit_options:
```

Since this package is part of the `solana_kit` Dart workspace, it is resolved automatically. For standalone use, point to the repository or use a path dependency.

## Usage

### The Option type

Dart has nullable types (`T?`), but they cannot represent nested optionality. For example, `Option<Option<int>>` cannot be expressed as `int??` because there is no way to distinguish `Some(None)` from `None`. This package provides a sealed class hierarchy that mirrors Rust's `Option<T>`.

```dart
import 'package:solana_kit_options/solana_kit_options.dart';

// Create a Some value.
final present = some(42);         // Some<int>(42)
final alsoPresent = Some(42);     // Same thing using the constructor

// Create a None value.
final absent = none<int>();       // None<int>()
final alsoAbsent = None<int>();   // Same thing using the constructor

// Pattern matching with Dart's sealed class support.
final message = switch (present) {
  Some(:final value) => 'Got $value',
  None() => 'Nothing',
};
// message == 'Got 42'
```

### Checking option variants

```dart
import 'package:solana_kit_options/solana_kit_options.dart';

final opt = some(42);

isSome(opt);      // true
isNone(opt);      // false

isOption(opt);    // true
isOption(42);     // false
isOption(null);   // false
```

### Unwrapping options

Extract the contained value, or get `null` / a fallback:

```dart
import 'package:solana_kit_options/solana_kit_options.dart';

// Unwrap to nullable.
unwrapOption(some(42));         // 42
unwrapOption(none<int>());      // null

// Unwrap with a fallback.
unwrapOptionOr(some(42), () => 0);     // 42
unwrapOptionOr(none<int>(), () => 0);  // 0

// Wrap a nullable value into an Option.
wrapNullable(42);           // Some(42)
wrapNullable<int>(null);    // None<int>()
```

### Recursive unwrapping

Deeply unwrap nested options within complex data structures:

```dart
import 'package:solana_kit_options/solana_kit_options.dart';

// Nested options are fully unwrapped.
unwrapOptionRecursively(some(some('Hello')));      // 'Hello'
unwrapOptionRecursively(some(none<String>()));      // null

// Works with maps and lists too.
final data = {
  'name': 'Alice',
  'age': some(30),
  'nickname': none<String>(),
  'scores': [some(100), none<int>(), some(85)],
};

final unwrapped = unwrapOptionRecursively(data);
// unwrapped == {
//   'name': 'Alice',
//   'age': 30,
//   'nickname': null,
//   'scores': [100, null, 85],
// }

// With a fallback for None values.
unwrapOptionRecursively(some(none<int>()), () => -1); // -1
```

### Encoding and decoding options

The `getOptionCodec` function creates a codec that encodes `Option<T>` values with a configurable prefix byte (default: `u8`, where `0 = None` and `1 = Some`).

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_options/solana_kit_options.dart';

final optionU16 = getOptionCodec(getU16Codec());

// Encode Some(42).
final someBytes = optionU16.encode(some(42));
// someBytes == [0x01, 0x2a, 0x00]
//              ^prefix=1^ ^-u16-^

// Encode None.
final noneBytes = optionU16.encode(none<int>());
// noneBytes == [0x00]
//              ^prefix=0^

// You can also pass raw values or null for convenience.
optionU16.encode(42);    // Same as encoding some(42)
optionU16.encode(null);  // Same as encoding none()

// Decode back to Option<int>.
final decoded = optionU16.decode(Uint8List.fromList([0x01, 0x2a, 0x00]));
// decoded == Some(42)

final decodedNone = optionU16.decode(Uint8List.fromList([0x00]));
// decodedNone == None<int>()
```

### Zeroes none value

Use zeroes to represent `None` instead of omitting the value. This keeps the total encoded size constant for fixed-size items, which is useful in account data layouts where field offsets must be predictable:

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_options/solana_kit_options.dart';

final optionU16 = getOptionCodec(
  getU16Codec(),
  noneValue: ZeroesOptionNoneValue(),
);

// Some(42): prefix + value.
optionU16.encode(some(42));   // [0x01, 0x2a, 0x00]

// None: prefix + zeroed bytes (same total size as Some).
optionU16.encode(none<int>()); // [0x00, 0x00, 0x00]
```

### Constant none value

Use a specific byte sequence to represent `None`:

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_options/solana_kit_options.dart';

final optionU16 = getOptionCodec(
  getU16Codec(),
  noneValue: ConstantOptionNoneValue(Uint8List.fromList([0xff, 0xff])),
);

optionU16.encode(none<int>()); // [0x00, 0xff, 0xff]
```

### No prefix

Omit the boolean prefix entirely. Useful when the presence of data can be inferred from context (e.g., remaining bytes or the none value itself):

```dart
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_options/solana_kit_options.dart';

final optionU16 = getOptionCodec(
  getU16Codec(),
  hasPrefix: false,
  noneValue: ZeroesOptionNoneValue(),
);

// Some(42): just the value, no prefix.
optionU16.encode(some(42));    // [0x2a, 0x00]

// None: zeroed bytes, no prefix.
optionU16.encode(none<int>()); // [0x00, 0x00]
```

### Custom prefix codec

Use a different number codec for the prefix:

```dart
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_options/solana_kit_options.dart';

// Use u32 instead of u8 for the prefix.
final optionU8 = getOptionCodec(
  getU8Codec(),
  prefix: getU32Codec(),
);

optionU8.encode(some(42)); // [0x01, 0x00, 0x00, 0x00, 0x2a]
//                          ^------u32 prefix------^ ^-u8-^
```

### Using separate encoders and decoders

For composition with other codec utilities, use the encoder-only and decoder-only variants:

```dart
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_options/solana_kit_options.dart';

// Encoder only.
final encoder = getOptionEncoder(getU16Encoder());
final bytes = encoder.encode(some(42));

// Decoder only.
final decoder = getOptionDecoder(getU16Decoder());
final option = decoder.decode(bytes);
// option == Some(42)
```

## API Reference

### Option type

| Type / Function | Description |
|-----------------|-------------|
| `Option<T>` | Sealed class: either `Some<T>` or `None<T>` |
| `Some<T>(T value)` | Contains a present value |
| `None<T>()` | Contains no value |
| `some<T>(T value)` | Factory function for `Some<T>` |
| `none<T>()` | Factory function for `None<T>` |
| `isOption(input)` | Returns `true` if the input is an `Option` |
| `isSome(option)` | Returns `true` if the option is `Some` |
| `isNone(option)` | Returns `true` if the option is `None` |

### Unwrap utilities

| Function | Description |
|----------|-------------|
| `unwrapOption<T>(option)` | Returns the contained value or `null` |
| `unwrapOptionOr<T>(option, fallback)` | Returns the contained value or calls `fallback()` |
| `wrapNullable<T>(nullable)` | Converts `T?` into `Option<T>` |
| `unwrapOptionRecursively(input, [fallback])` | Deep-unwraps nested options in maps, lists, and values |

### Option codecs

| Function | Description |
|----------|-------------|
| `getOptionEncoder<T>(item, {prefix, hasPrefix, noneValue})` | Encode `Option<T>` or `T?` values |
| `getOptionDecoder<T>(item, {prefix, hasPrefix, noneValue})` | Decode bytes into `Option<T>` |
| `getOptionCodec<TFrom, TTo>(item, {prefix, hasPrefix, noneValue})` | Combined option codec |

### None value types

| Type | Description |
|------|-------------|
| `OmitOptionNoneValue()` | `None` is omitted from encoding (default) |
| `ZeroesOptionNoneValue()` | `None` is encoded as zeroes (requires fixed-size item) |
| `ConstantOptionNoneValue(bytes)` | `None` is encoded as a specific byte sequence |
