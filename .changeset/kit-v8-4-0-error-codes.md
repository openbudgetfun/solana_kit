---
"solana_kit_errors": minor
---

# Track `@solana/kit` `v8.4.0`: add sentinel and message packer error codes

The reference pin moves from `anza-xyz/kit` `v8.3.0` to `v8.4.0`, and the `@solana/kit` compatibility claim in `versions.json` and the root readme advances accordingly.

Three new error codes are ported from upstream `@solana/errors`:

- `codecsSentinelMissingAtEndOfBytes(8078028)` — thrown when a collection codec using a sentinel size strategy reaches the end of the byte array without encountering the sentinel.
- `codecsSentinelMustNotEmpty(8078029)` — thrown when constructing a codec with an empty sentinel.
- `instructionPlansMessageRejectedByPacker(7618012)` — thrown by a custom message packer to reject a transaction message for a reason other than the standard capacity limits.

These codes reserve their upstream numbers in the Dart `SolanaErrorCode` enum so that error codes remain interoperable across implementations. The features that throw them (the sentinel size strategy for collection codecs and the custom message packer helpers) are ported separately.

The shortU16 decoder and realloc packer fixes in this release are not applicable: the Dart shortU16 decoder already guards against truncated buffers, over-long continuation chains, and out-of-range values, and the Dart realloc packer already handles exact-multiple `totalSize` correctly.
