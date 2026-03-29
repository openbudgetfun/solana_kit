---
title: Codecs
description: Build deterministic binary layouts with Solana Kit codecs for numbers, strings, structs, tuples, unions, and options.
---

Codecs are the foundation for instruction data, account layouts, sysvar schemas, and many protocol-level payloads.

The codec layer is split into focused packages so you can keep dependencies small while still composing rich layouts.

## Core concepts

### `Encoder<T>`

Turns a value into bytes.

### `Decoder<T>`

Turns bytes into a value.

### `Codec<TFrom, TTo>`

Combines both directions.

## Package map

- `solana_kit_codecs_core` — base abstractions and composition helpers
- `solana_kit_codecs_numbers` — little-endian integers and floats
- `solana_kit_codecs_strings` — base16/base58/base64/utf8/baseX encoders
- `solana_kit_codecs_data_structures` — structs, tuples, arrays, maps, unions, nullable values, and more
- `solana_kit_options` — Rust-style `Option<T>` modeling and codec support

## Example: build a simple struct codec

```dart
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

final transferLayout = getStructCodec({
  'discriminator': getU8Codec(),
  'amount': getU64Codec(),
});

final bytes = transferLayout.encode({
  'discriminator': 2,
  'amount': BigInt.from(1_000_000),
});

final decoded = transferLayout.decode(bytes);
print(decoded['amount']);
```

## Example: choose among variants

<!-- {=typedUnionHelpersSection} -->

### Typed Union Helpers

Prefer typed union helpers when a codec has a fixed, small number of variants.
They improve IDE type inference and reduce downstream casting.

```dart
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

final codec = getUnion2Codec(
  getU8Codec(),
  getU32Codec(),
  (bytes, offset) => bytes.length - offset > 1 ? 1 : 0,
);

final encoded = codec.encode(const Union2Variant1<int, int>(1000));
final decoded = codec.decode(encoded);
```

<!-- {/typedUnionHelpersSection} -->

## When to use codecs

Use codecs when you need:

- deterministic byte layouts
- testable encode/decode logic
- reuse across program clients and account decoders
- confidence that a Dart representation matches an upstream wire format

Avoid ad hoc `Uint8List` slicing once a layout becomes non-trivial. A codec pays for itself quickly.

## Read next

- [Create Instructions](../getting-started/create-instructions)
- [Accounts](accounts)
- [Build a Program Client](../guides/build-program-client)
