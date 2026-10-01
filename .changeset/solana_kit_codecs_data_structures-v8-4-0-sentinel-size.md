---
"solana_kit_codecs_data_structures": minor
---

# Sentinel size strategy for array, set, and map codecs

Ports the sentinel size strategy from `@solana/codecs-data-structures` v8.4.0 (#2061). `getArrayCodec`, `getSetCodec`, and `getMapCodec` accept a new `SentinelArraySize` that ends the collection when the bytes at the next item position match a constant sentinel:

```dart
final codec = getArrayCodec(
  getU8Codec(),
  size: SentinelArraySize(Uint8List.fromList([0])),
);
codec.encode([42, 1, 2]); // 2a 01 02 00
```

- The sentinel is compared at item boundaries only, so its bytes may occur inside an item without terminating the collection. No valid item may begin with the sentinel's bytes.
- `SentinelCountStrategy.required` (default) writes the sentinel after the last item and demands it when decoding; `optional` writes it but tolerates its absence; `omitted` never writes it and consumes it only if present.
- Constructing a codec with an empty sentinel throws `codecsSentinelMustNotBeEmpty`; a required sentinel missing at the end of the byte array throws `codecsSentinelMissingAtEndOfBytes`. Both codes use their upstream numbers.

This mirrors Codama's `sentinelCountNode`, so sentinel-counted IDL types can now be generated.
