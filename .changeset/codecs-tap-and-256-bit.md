---
"solana_kit_codecs_core": minor
"solana_kit_codecs_numbers": minor
---

# Add 256-bit number codecs and tap codec helpers

Ports the two additive codec surfaces from upstream `@solana/kit` v8.3.0.

`solana_kit_codecs_numbers` gains 256-bit integer codecs: `getU256Codec`, `getU256Encoder`, and `getU256Decoder` for unsigned values in `[0, 2^256 - 1]`, plus `getI256Codec`, `getI256Encoder`, and `getI256Decoder` for signed values in `[-(2^255), 2^255 - 1]`. Both serialize as 32 bytes, honour the `endian` option, and always decode to `BigInt`, matching the existing 64-bit and 128-bit codecs.

`solana_kit_codecs_core` gains tap helpers that observe values or bytes without modifying them. Because any callback may throw, they double as validation guards that need no identity `transformEncoder`:

```dart
final guarded = tapDecoderBytes(getU8Decoder(), (bytes, offset) {
  if (bytes[offset] > 1) throw StateError('Expected a 0 or a 1');
});

final spanned = tapEncoderBytes(getU8Encoder(), (bytes, pre, post) {
  print('wrote ${post - pre} bytes at $pre');
});
```

`tapEncoder`, `tapDecoder`, and `tapCodec` observe values; `tapEncoderBytes`, `tapDecoderBytes`, and `tapCodecBytes` observe bytes and offsets. Each wrapper preserves the size characteristics of the codec it wraps, so `FixedSizeEncoder` stays fixed-size and `VariableSizeEncoder` keeps its `maxSize`.

Note that Dart's `Codec` is not an `Encoder` or a `Decoder`, so the value-level wrappers are typed against the encoder or decoder they observe; use `tapCodec` and `tapCodecBytes` to wrap a codec.
