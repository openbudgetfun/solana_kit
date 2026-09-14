---
"solana_kit_errors": major
"solana_kit_codecs_strings": minor
---

# Align error code numbers with upstream and report malformed UTF-8 as a code

`SolanaErrorCode` numbers now match upstream `@solana/kit` exactly. Two port-only codes were occupying numbers upstream uses for its UTF-8 codes, which made any cross-SDK comparison of those numbers wrong.

The UTF-8 codec also stops raising a bare `FormatException` and reports through the error codes upstream defines:

- `codecsInvalidUtf8Bytes` (`8078026`) for a malformed byte sequence, carrying the `offset` where decoding failed.
- `codecsInvalidUtf8String` (`8078027`) for a lone surrogate, carrying its `index`. This is thrown when encoding with `fatal: true` and, with `fatal: false`, both directions keep replacing the offending unit with `U+FFFD`.

Two port-only codes moved or went away:

- `codecsInvalidBoolean` moved from `8078027` to `8078999`. The number had to change because `8078027` is upstream's `CODECS__INVALID_UTF8_STRING`. This port validates that booleans are encoded as `0` or `1` and upstream does not, so the code has no upstream counterpart and now sits at the end of the codec block, where upstream cannot collide with it. If you match on `SolanaErrorCode.codecsInvalidBoolean.value`, update the number; matching on the enum member is unaffected.
- `codecsStringContainsNullCharacters` was removed. Nothing in the workspace threw it, and upstream has no equivalent. Use `Utf8CodecConfig.removeNullCharacters` to control null handling instead.

```dart
try {
  getUtf8Decoder().decode(bytes);
} on SolanaError catch (error) {
  if (error.code == SolanaErrorCode.codecsInvalidUtf8Bytes) {
    print('bad bytes at ${error.context['offset']}');
  }
}
```

`upstream:error-codes`, which also runs as part of `docs:check`, compares this enum against `.repos/kit/packages/errors/src/codes.ts` and fails on a number mismatch or an occupied number, so this cannot drift again without CI saying so.
