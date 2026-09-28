# Upstream audit — @solana/kit v8.3.0 → v8.4.0

`@solana/kit` v8.4.0 was released on 2026-09-28. This note maps every change in that release to its Dart counterpart, including the items that are deliberately not ported, so the compatibility claim can be audited.

Status: the workspace tracks `v8.4.0`; `upstream:parity` passes against `@solana/kit@8.4.0`.

## Ported

| Upstream change                                                                            | Dart counterpart                                                                 |
| ------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------- |
| `SOLANA_ERROR__CODECS__SENTINEL_MISSING_AT_END_OF_BYTES` (8078028) (`@solana/errors`)      | `SolanaErrorCode.codecsSentinelMissingAtEndOfBytes` in `solana_kit_errors`       |
| `SOLANA_ERROR__CODECS__SENTINEL_MUST_NOT_BE_EMPTY` (8078029) (`@solana/errors`)            | `SolanaErrorCode.codecsSentinelMustNotBeEmpty` in `solana_kit_errors`            |
| `SOLANA_ERROR__INSTRUCTION_PLANS__MESSAGE_REJECTED_BY_PACKER` (7618012) (`@solana/errors`) | `SolanaErrorCode.instructionPlansMessageRejectedByPacker` in `solana_kit_errors` |

## Not ported yet

| Upstream change                                                                                                                                                                                  | Why deferred                                                                                                                                                                                                                                                                                                                                                                                                |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Sentinel size strategy for `array`, `set`, and `map` codecs (#2061)                                                                                                                              | A new `SentinelCountStrategy` type (`required` / `optional` / `omitted`) and `ArrayLikeCodecSentinelSize` object that replaces the fixed-size approach for collection sizing. Requires changes to the encoder/decoder write/read loops in all three collection codecs plus two new error paths. This is a self-contained feature that should be ported with its own tests and careful boundary-case review. |
| Message packer helpers (#2073): `resolveMaxInstructionsPerTransaction`, `assertMaxInstructionsPerTransaction`, `assertMessageCanAccommodateSize`, `isMessagePackerErrorThatRequiresNewCandidate` | New helpers in `@solana/instruction-plans` that extract the instruction-count and byte-size limit checks from the built-in packers into standalone functions, plus a new error code that lets a custom packer refuse a message. Requires changes to the transaction planner error handling. Self-contained feature; should be ported with its own tests.                                                    |

## Not applicable in Dart

| Upstream change                                                                                       | Why there is nothing to port                                                                                                                                                                                                                                                                                                                                               |
| ----------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `getShortU16Decoder()` malformed-input fix (#2067) (`@solana/codecs-numbers`)                         | The Dart decoder already guards against truncated buffers (`codecsInvalidByteLength` when the byte array ends prematurely), continuation chains longer than three bytes (`codecsNumberOutOfRange` when the shift exceeds 14), and out-of-range decoded values (`assertNumberIsBetweenForCodec` after each byte). These guards predate the upstream fix and are equivalent. |
| `getReallocMessagePackerInstructionPlan` 0-byte instruction fix (#2071) (`@solana/instruction-plans`) | The Dart realloc packer already handles `totalSize` values that are exact multiples of the 10,240-byte limit: the condition `lastInstructionSize != 0` falls through to `_reallocLimit`, producing a full-size final instruction. No 0-byte instruction is generated.                                                                                                      |

## Reference pin

`config/reference-repos.json` advanced `kit` from tag `v8.3.0` (`checkedCommit 7dfaf8827c21`) to tag `v8.4.0` (`checkedCommit 0a296c6ba8cd`). `versions.json` `@solana/kit` moved from `8.3.0` to `8.4.0`.
