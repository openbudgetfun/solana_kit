# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-28)

### 🚀 Feature

#### Replace string encoding fields with AccountEncoding, TransactionEncoding, and WireTransactionEncoding enums across RPC API and subscriptions API packages.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b)

#### Add `LatestBlockhashValue` model and full `Sol` fixed-point type

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

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910)

#### Introduce internal `JsonReader` helper that replaces unsafe `.cast<T>()` list

casts and bare `as` casts in all `fromJson` factories with explicit typed
accessors. Parse errors now surface at construction time via a descriptive
`FormatException` that includes the field name, rather than deferring until
element access. All ten type files (`das_types`, `enhanced_types`, `zk_types`,
`wallet_types`, `webhook_types`, `rpc_v2_types`, `auth_types`, `staking_types`,
`priority_fee_types`, `smart_transaction_types`) have been migrated. The public
API is unchanged.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b)

#### Replace dynamic with Object? across lib source files; remaining dynamic usage is only in test matcher API signatures required by the test package.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fe249a4`](https://github.com/openbudgetfun/solana_kit/commit/fe249a46e06edf2f4cc924b30c4c463e8ea9a910) · _Last updated in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b)

#### Add == / hashCode / toString to value types across rpc_types, rpc_api, rpc_parsed_types, rpc_spec_types, instructions, transaction_messages, and transaction_confirmation.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b)

#### Add a higher-level Solana account client plus typed RPC response wrappers for common account, balance, blockhash, and multi-account request flows.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`aa54336`](https://github.com/openbudgetfun/solana_kit/commit/aa54336c1e9a6c4ae5df1adafc1822cfccf342fa) · _Last updated in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b)

#### Add SOL conversion helpers alongside lamports helpers, keep lamports codecs exported consistently, and cover conversion and formatting behavior with dedicated tests.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b)
