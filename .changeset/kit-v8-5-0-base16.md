---
"solana_kit_codecs_strings": patch
---

# Accept odd-length strings in the base16 encoder

Ports the fix from `@solana/codecs-strings` v8.5.0 (#2117): `getBase16Encoder` no longer drops the last digit of odd-length strings. A trailing lone hex digit is encoded as the low nibble of a final byte — `'abc'` now encodes to `[0xab, 0x0c]` instead of throwing, matching the size `getSizeFromValue` reports. The single-character case is unchanged.
