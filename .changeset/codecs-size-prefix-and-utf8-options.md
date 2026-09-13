---
"solana_kit_codecs_data_structures": minor
"solana_kit_codecs_strings": minor
---

# Add the upstream size-prefix and UTF-8 codec options

Ports the last two surfaces from upstream `@solana/kit` v8.3.0. Both are additive: no existing behavior changes.

`requireSizePrefix` is a named parameter on `getArrayDecoder`, `getArrayCodec`, `getSetDecoder`, `getSetCodec`, `getMapDecoder`, and `getMapCodec`. Upstream defaults it to `false`, where an exhausted byte array decodes as an empty collection so a collection can be appended to an existing layout. This port defaults it to `true` and throws, because a silently empty collection hides truncated input. Pass `requireSizePrefix: false` to opt in:

```dart
final lenient = getArrayCodec(getU8Codec(), requireSizePrefix: false);
lenient.decode(Uint8List(0)); // []
getArrayCodec(getU8Codec()).decode(Uint8List(0)); // throws
```

`Utf8CodecConfig` is accepted by `getUtf8Encoder`, `getUtf8Decoder`, and `getUtf8Codec`, and carries upstream's three options:

- `fatal` rejects malformed input instead of replacing it. Upstream defaults to `false`, decoding bad bytes as `U+FFFD`; this port defaults to `true` and raises a `FormatException` from decoding and, for lone surrogates, from encoding.
- `ignoreBOM` preserves a leading byte order mark. Both default to `false`, which strips it, matching Dart's `Utf8Decoder`.
- `removeNullCharacters` strips `U+0000` from decoded strings. Upstream defaults to `true`; this port defaults to `false` so the decoded value reflects the bytes exactly.

The two divergent defaults exist so that malformed or null-padded account and instruction data cannot decode silently. To take upstream's behavior explicitly:

```dart
final codec = getUtf8Codec(
  const Utf8CodecConfig(fatal: false, removeNullCharacters: true),
);
```
