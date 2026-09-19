---
"solana_kit_codecs_numbers": patch
"solana_kit_transaction_messages": patch
"solana_kit_transactions": patch
---

# Reject truncated numeric reads with `SolanaError` instead of `RangeError`

A decoder reading a fixed-width field out of malformed wire data could raise a raw `RangeError` or `IndexError` out of the SDK instead of the documented `SolanaError`, so a caller catching `SolanaError` saw an escaped exception rather than a rejection it could handle. A truncated account, transaction, or RPC payload reaching the decoders was enough to trigger it; no signature or cluster access was required.

The guard that upstream `@solana/kit` applies in its number decoder factory was missing from three ports of it. `numberDecoderFactory` and `floatDecoderFactory` read through a `ByteData` view without first checking that the requested width was available, and the six `BigInt` decoders (`u64`, `i64`, `u128`, `i128`, `u256`, `i256`) indexed bytes directly with the same gap. All eight now call `assertByteArrayIsNotEmptyForCodec` and `assertByteArrayHasEnoughBytesForCodec` before reading, raising `codecsCannotDecodeEmptyByteArray` or `codecsInvalidByteLength` as upstream does. A new `bigIntDecoderFactory` carries the guard for the multi-word widths.

Two further escape sites in `solana_kit_transaction_messages` are fixed. The version 1 instruction payload slice computed `pos + numInstructionDataBytes` and sliced without confirming the buffer held that many bytes; it now asserts the length the way upstream's `fixDecoderSize` wrapper does. The transaction version decoder read `bytes[offset]` unguarded — upstream tolerates this because JavaScript yields `undefined`, which then silently takes the legacy branch and misreports a truncated buffer as an unversioned message, so this port rejects the empty buffer rather than reproducing that fallback.

Encoders are unchanged and still raise `RangeError` when a destination buffer is too small. Upstream writes into a scratch buffer and then `bytes.set`s it, which throws in JavaScript too, so that behavior is deliberate parity rather than a defect.

Callers that caught `RangeError` around a decode should catch `SolanaError`. Callers that already caught `SolanaError` now see malformed input rejected where it previously surfaced as a crash.
