---
"solana_kit_rpc_types": minor
---

# Add LatestBlockhashValue and Sol type

Add LatestBlockhashValue model and full Sol fixed-point…


Add `LatestBlockhashValue` model and full `Sol` fixed-point type

**`LatestBlockhashValue`** (`lib/src/latest_blockhash_value.dart`):

A new `@immutable` value class that wraps the two fields returned by `getLatestBlockhash` — a `Blockhash` and a `BigInt lastValidBlockHeight`. This gives downstream callers a typed model instead of navigating a raw `Map` for the latest-blockhash response. The class implements structural equality (`==` / `hashCode`) and a descriptive `toString`.

**`Sol` extension type and helpers** (`lib/src/sol.dart`):

A complete fixed-point SOL representation backed by an exact Lamports `BigInt`:

- `Sol` is an `extension type` implementing both `Lamports` and `Object`, so it interops seamlessly with existing `Lamports`-accepting APIs.
- `sol(String, {RoundingMode})` parses a decimal SOL string (up to 9 fractional digits) into `Sol`. A `RoundingMode` enum (`strict`, `down`, `up`, `halfUp`) controls behaviour when the input has excess precision.
- `solToLamports` / `lamportsToSol` provide lossless round-trip conversions.
- `Sol.toDecimalString()` formats the value back to a human-readable decimal string without trailing zeros.
- `getSolEncoder()`, `getSolDecoder()`, and `getSolCodec()` produce binary codecs that read/write the underlying 64-bit little-endian Lamports count, matching the on-chain wire format.

Both types are exported from the package barrel (`solana_kit_rpc_types.dart`). The `LatestBlockhashValue` export enables `solana_kit_rpc` to use it in its new typed `getLatestBlockhashValue` method. The `Sol` type adds a long-requested ergonomic layer for displaying and parsing SOL amounts without manual BigInt arithmetic.
