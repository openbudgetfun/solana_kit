# solana_kit_codecs

Umbrella package that re-exports all Solana Kit codec sub-packages through a single import.

This is a Dart port of [`@solana/codecs`](https://github.com/anza-xyz/kit/tree/main/packages/codecs) from the Solana TypeScript SDK.

## Installation

```yaml
dependencies:
  solana_kit_codecs:
```

Since this package is part of the `solana_kit` Dart workspace, it is resolved automatically. For standalone use, point to the repository or use a path dependency.

## Usage

Instead of importing each codec sub-package individually, import `solana_kit_codecs` to get everything at once:

```dart
import 'package:solana_kit_codecs/solana_kit_codecs.dart';
```

This single import gives you access to all codec functionality from:

- **solana_kit_codecs_core** -- Core interfaces (`Encoder`, `Decoder`, `Codec`) and composition utilities (`combineCodec`, `transformCodec`, `fixCodecSize`, `addCodecSizePrefix`, `addCodecSentinel`, `offsetCodec`, `padLeftCodec`, `padRightCodec`, `reverseCodec`, etc.)
- **solana_kit_codecs_numbers** -- Numeric codecs for integers and floats (`getU8Codec`, `getU16Codec`, `getU32Codec`, `getU64Codec`, `getU128Codec`, `getI8Codec`, ..., `getF32Codec`, `getF64Codec`, `getShortU16Codec`)
- **solana_kit_codecs_strings** -- String codecs (`getUtf8Codec`, `getBase58Codec`, `getBase16Codec`, `getBase64Codec`, `getBase10Codec`, `getBaseXCodec`, `getBaseXResliceCodec`)
- **solana_kit_codecs_data_structures** -- Composite data structure codecs (`getStructCodec`, `getArrayCodec`, `getTupleCodec`, `getBooleanCodec`, `getNullableCodec`, `getMapCodec`, `getSetCodec`, `getDiscriminatedUnionCodec`, `getLiteralUnionCodec`, `getBitArrayCodec`, `getBytesCodec`, `getConstantCodec`, `getUnitCodec`, `getHiddenPrefixCodec`, `getHiddenSuffixCodec`)
- **solana_kit_options** -- Rust-like `Option<T>` type and codec (`some`, `none`, `getOptionCodec`, `unwrapOption`, `unwrapOptionRecursively`)

### Example: encoding a Solana account layout

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs/solana_kit_codecs.dart';

// Define an account data layout (similar to a Borsh schema).
final accountCodec = getStructCodec([
  ('isInitialized', getBooleanCodec()),
  ('authority', fixCodecSize(getBase58Codec(), 32)),
  ('balance', getU64Codec()),
  ('label', addCodecSizePrefix(getUtf8Codec(), getU32Codec())),
  ('tags', getArrayCodec(
    addCodecSizePrefix(getUtf8Codec(), getU32Codec()),
    size: PrefixedArraySize(getU16Codec()),
  )),
]);

// Encode account data.
final encoded = accountCodec.encode({
  'isInitialized': true,
  'authority': '11111111111111111111111111111111',
  'balance': BigInt.from(1000000000),
  'label': 'My Account',
  'tags': ['defi', 'staking'],
});

// Decode account data.
final decoded = accountCodec.decode(encoded);
// decoded['isInitialized'] == true
// decoded['balance'] == BigInt.from(1000000000)
// decoded['label'] == 'My Account'
// decoded['tags'] == ['defi', 'staking']
```

### Example: encoding a Rust-like enum

```dart
import 'package:solana_kit_codecs/solana_kit_codecs.dart';

// Define an instruction enum.
final instructionCodec = getDiscriminatedUnionCodec([
  ('initialize', getStructCodec([
    ('authority', fixCodecSize(getBase58Codec(), 32)),
    ('amount', getU64Codec()),
  ])),
  ('transfer', getStructCodec([
    ('amount', getU64Codec()),
  ])),
  ('close', getUnitCodec()),
]);

// Encode a 'transfer' instruction.
final bytes = instructionCodec.encode({
  '__kind': 'transfer',
  'amount': BigInt.from(500),
});

// Decode.
final decoded = instructionCodec.decode(bytes);
// decoded['__kind'] == 'transfer'
// decoded['amount'] == BigInt.from(500)
```

### Example: working with Option types

```dart
import 'package:solana_kit_codecs/solana_kit_codecs.dart';

// Encode an optional u64 field.
final optionalBalance = getOptionCodec(getU64Codec());

optionalBalance.encode(some(BigInt.from(42)));  // [0x01, ...8 bytes...]
optionalBalance.encode(none<BigInt>());          // [0x00]

// Decode and pattern match.
final result = optionalBalance.decode(bytes);
switch (result) {
  case Some(:final value):
    print('Balance: $value');
  case None():
    print('No balance set');
}
```

## Re-exported packages

| Package                                                                      | Description                                     |
| ---------------------------------------------------------------------------- | ----------------------------------------------- |
| [`solana_kit_codecs_core`](../solana_kit_codecs_core/)                       | Core interfaces and composition utilities       |
| [`solana_kit_codecs_numbers`](../solana_kit_codecs_numbers/)                 | Integer and float codecs                        |
| [`solana_kit_codecs_strings`](../solana_kit_codecs_strings/)                 | String and base encoding codecs                 |
| [`solana_kit_codecs_data_structures`](../solana_kit_codecs_data_structures/) | Struct, array, enum, and other composite codecs |
| [`solana_kit_options`](../solana_kit_options/)                               | Rust-like `Option<T>` type and codec            |
