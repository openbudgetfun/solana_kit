---
"solana_kit_codecs_strings": patch
"solana_kit_rpc_spec_types": patch
"solana_kit_fixed_points": patch
"solana_kit_transaction_messages": patch
---

# Speed up base-X codecs, BigInt JSON parsing, and fixed-point parsing

Same results, less work per call. No public API, output byte, or error behavior changed; `upstream:parity` passes against `@solana/kit@8.3.0` and the full workspace suite is green.

The base-X codecs converted through `BigInt`, scaled the alphabet with `String.indexOf` and a fresh one-character string per input character, and built output with repeated `insert(0, …)` calls that reallocate and shift the whole list each time. Encoding a typical base58 address cost roughly 600 µs, so compiling a 20-account transaction spent measurable milliseconds on address encoding alone. The conversion now folds digits into a byte buffer with word-sized carry arithmetic, indexes the alphabet through a cached code-unit lookup, and writes output in order:

```dart
// Before: BigInt division per character plus O(n²) list inserts.
// After: one carry pass per character over a preallocated buffer.
final converted = _convertToBytes(value, alphabet);
bytes
  ..fillRange(offset, offset + converted.leadingZeroes, 0)
  ..setAll(offset + converted.leadingZeroes, converted.bytes);
```

Measured on an interleaved best-of-N benchmark, with the previous implementation running in the same process to cancel machine noise:

| Operation                        | Before   | After   | Improvement |
| -------------------------------- | -------- | ------- | ----------- |
| base58 encode, typical address   | 22.97 µs | 2.88 µs | 8.0x        |
| base58 decode, 32 bytes          | 16.79 µs | 3.24 µs | 5.2x        |
| base58 encode, 64-byte signature | 52.89 µs | 8.44 µs | 6.3x        |

`parseJsonWithBigInts` allocated a one-character string and ran up to two regular expressions per character of the payload, then rebuilt the document character by character. It now scans by code unit, copies literal runs as substrings, and hoists the exponent pattern:

| Operation                 | Before   | After    | Improvement |
| ------------------------- | -------- | -------- | ----------- |
| parse a 28 KB RPC payload | 2.198 ms | 1.089 ms | 2.0x        |

Also removed in the same pass: a redundant full copy in the UTF-8 encoder and the base64 decoder (both `utf8.encode` and `base64.decode` already return `Uint8List`), a double copy of every version-1 instruction payload, and two regular expressions that were compiled per parsed value in the fixed-point codecs.

Behavior is pinned by tests rather than assumed. `base_x_property_test.dart` round-trips random byte strings across every length from 0 to 512 bytes, covers leading-zero-only input, alphabets wider than a byte, and non-power-of-two alphabets, and asserts arbitrary-precision digit strings beyond 64 bits. A degenerate one-character alphabet is now rejected with an `ArgumentError` when the codec is created; previously it produced silent zero output on encode and looped forever on decode.

`bench:all` also gains coverage where the regression was invisible: the address benchmark previously measured only the all-ones System Program address, which is base58's leading-zero fast path and exercises no base conversion at all.
