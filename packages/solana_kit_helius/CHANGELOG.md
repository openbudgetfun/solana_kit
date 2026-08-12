# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_helius [0.3.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_helius/v0.3.2) (2026-05-30)

### 🚀 Feature

#### Detached from main group

This package is now released independently rather than as part of the main solana_kit group. The Helius SDK integration is a standalone provider package that does not depend on the core solana_kit release cycle, so an independent release track is more appropriate.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add Helius JsonReader and error context

Introduce internal JsonReader helper and structured error…

Introduce internal `JsonReader` helper and structured error context for Helius type deserialization.

##### JsonReader

Add a `JsonReader` class in `lib/src/internal/json_reader.dart` that wraps a raw `Map<String, Object?>` and provides typed accessor methods (`requireString`, `requireInt`, `optString`, `optEnum`, `requireDecodedList`, etc.). This eliminates manual `! as T` casts scattered across every `fromJson` factory in the Helius type system.

All type files (`auth_types.dart`, `das_types.dart`, `enhanced_types.dart`, `priority_fee_types.dart`, `rpc_v2_types.dart`, `smart_transaction_types.dart`, `staking_types.dart`, `wallet_types.dart`, `webhook_types.dart`, `zk_types.dart`) are migrated to use `JsonReader`, making deserialization more readable and ensuring consistent `FormatException` messages when a required field is absent or null.

##### Structured error context

`JsonRpcClient` and `RestClient` now throw errors via `createSolanaError` with structured context keys (`methodName`, `operation`, `statusCode`, `url`) instead of plain `SolanaError` constructors. This gives downstream consumers machine-readable error metadata for logging and diagnostics.

##### Impact

No public API changes. All `JsonReader` usage is internal to `lib/src/`. Deserialization behavior is functionally equivalent but error messages are now consistent `FormatException` instances rather than raw `TypeError`/`CastError` from Dart's `as` operator.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add Helius shared transport contract tests

_Owner:_ Ifiok Jr. · _Introduced in:_ [`dfcfa4c`](https://github.com/openbudgetfun/solana_kit/commit/dfcfa4c5b770f86ca6f4159a1c128e004e150a93) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

#### Harden Helius WebSocket handling

Harden Helius WebSocket handling with secure-by-default URL validation, better subscription error propagation, and correct unsubscribe method routing.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`a004fbf`](https://github.com/openbudgetfun/solana_kit/commit/a004fbf221bd3f90a9f324ab0d2c544529dbddf5) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Redact API keys in Helius config output

SEC-01: Redact API keys in `HeliusConfig.toString()` output to prevent accidental exposure in logs, error messages, or debug output.

- Added `SensitiveString` wrapper class that redacts its value in `toString()` output
- `HeliusConfig` now wraps the API key in `SensitiveString` internally
- `HeliusConfig.toString()` now shows redacted key (e.g., `****123`) instead of the full key
- `HeliusConfig.apiKey` still returns the raw key for legitimate API calls
- Removed `const` from `HeliusConfig` constructor (breaking change for `const` usage)

_Owner:_ Ifiok Jr. · _Introduced in:_ [`21ae653`](https://github.com/openbudgetfun/solana_kit/commit/21ae6537efe0f3520c1aac32eac4e088fc23aaf1) · _Last updated in:_ [`12316d5`](https://github.com/openbudgetfun/solana_kit/commit/12316d50aadfeefc7563665fbad750e37cba1fd5)

#### Constant-time comparison for sensitive strings

SEC-03: Use constant-time comparison for SensitiveString equality to prevent timing side-channel attacks.

- SensitiveString.operator== now uses constant-time byte comparison
- Prevents attackers from learning how many characters match between two secrets
- Added test verifying no early exit on mismatch

_Owner:_ Ifiok Jr. · _Introduced in:_ [`76f2c14`](https://github.com/openbudgetfun/solana_kit/commit/76f2c1456cc408da94ab54da5f68a92e4f42e965) · _Last updated in:_ [`12316d5`](https://github.com/openbudgetfun/solana_kit/commit/12316d50aadfeefc7563665fbad750e37cba1fd5)

## solana_kit_helius [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_helius/v0.4.0) (2026-06-01)

### 💥 Breaking Change

#### Raise minimum Dart SDK to 3.12

Raise the minimum supported Dart SDK constraint to `^3.12.0` across public Dart packages.

This is a breaking change because consumers must use Dart 3.12 or newer. Flutter consumers must use a Flutter SDK that bundles Dart 3.12 or newer.

```yaml
environment:
  sdk: ^3.12.0
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`32d5d36`](https://github.com/openbudgetfun/solana_kit/commit/32d5d367abb7615fea5ee341f03d17c2bc0d66dd)

### 🐛 Fixed

#### Align Helius v3 defaults

Update the mainnet REST host to match upstream Helius v3.0.0, add Admin project usage, webhook toggle, and `getTransfersByAddress` parity, refresh package metadata, and document the exact upstream commit used for the v3 audit.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`ee30ae0`](https://github.com/openbudgetfun/solana_kit/commit/ee30ae03357be744bc81669041f0319149844af6)

## solana_kit_helius [0.4.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_helius/v0.4.1) (2026-06-03)

### 🐛 Fixed

#### Harden security audit findings

Disable placeholder Helius auth signing, redact Helius API keys from JSON-RPC error context, validate malformed encrypted mobile-wallet messages before slicing, and reject negative mobile-wallet sequence numbers.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #181](https://github.com/openbudgetfun/solana_kit/pull/181)

#### Add Helius transaction parity helpers

Add helpers for sender regions, sendViaSender, and createTxMessage.
Expand sender and broadcast coverage.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #183](https://github.com/openbudgetfun/solana_kit/pull/183)

#### Add Helius auth signing helpers

Implement upstream-compatible Helius auth message signing with Ed25519 signatures.
Also add request factories for secret key bytes and key pairs.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #183](https://github.com/openbudgetfun/solana_kit/pull/183)
