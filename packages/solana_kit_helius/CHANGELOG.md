# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_helius [0.3.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_helius/v0.3.2) (2026-05-28)

### 🚀 Feature

#### Detached from main group

This package is now released independently rather than as part of the main solana_kit group. The Helius SDK integration is a standalone provider package that does not depend on the core solana_kit release cycle, so an independent release track is more appropriate.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`3c175c3`](https://github.com/openbudgetfun/solana_kit/commit/3c175c3a852f04df89145f1edc5c458abaab253d)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910)

#### Introduce internal `JsonReader` helper and structured error context for Helius type deserialization.

##### JsonReader

Add a `JsonReader` class in `lib/src/internal/json_reader.dart` that wraps a raw `Map<String, Object?>` and provides typed accessor methods (`requireString`, `requireInt`, `optString`, `optEnum`, `requireDecodedList`, etc.). This eliminates manual `! as T` casts scattered across every `fromJson` factory in the Helius type system.

All type files (`auth_types.dart`, `das_types.dart`, `enhanced_types.dart`, `priority_fee_types.dart`, `rpc_v2_types.dart`, `smart_transaction_types.dart`, `staking_types.dart`, `wallet_types.dart`, `webhook_types.dart`, `zk_types.dart`) are migrated to use `JsonReader`, making deserialization more readable and ensuring consistent `FormatException` messages when a required field is absent or null.

##### Structured error context

`JsonRpcClient` and `RestClient` now throw errors via `createSolanaError` with structured context keys (`methodName`, `operation`, `statusCode`, `url`) instead of plain `SolanaError` constructors. This gives downstream consumers machine-readable error metadata for logging and diagnostics.

##### Impact

No public API changes. All `JsonReader` usage is internal to `lib/src/`. Deserialization behavior is functionally equivalent but error messages are now consistent `FormatException` instances rather than raw `TypeError`/`CastError` from Dart's `as` operator.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b)

#### Add Helius shared transport contract tests, concurrent websocket session boundary tests, and documentation for the preferred endpoint/session-oriented testing strategy.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`dfcfa4c`](https://github.com/openbudgetfun/solana_kit/commit/dfcfa4c5b770f86ca6f4159a1c128e004e150a93) · _Last updated in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b)

#### Harden Helius WebSocket handling with secure-by-default URL validation, better subscription error propagation, and correct unsubscribe method routing.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`a004fbf`](https://github.com/openbudgetfun/solana_kit/commit/a004fbf221bd3f90a9f324ab0d2c544529dbddf5) · _Last updated in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b)

#### SEC-01: Redact API keys in `HeliusConfig.toString()` output to prevent accidental exposure in logs, error messages, or debug output.

- Added `SensitiveString` wrapper class that redacts its value in `toString()` output
- `HeliusConfig` now wraps the API key in `SensitiveString` internally
- `HeliusConfig.toString()` now shows redacted key (e.g., `****123`) instead of the full key
- `HeliusConfig.apiKey` still returns the raw key for legitimate API calls
- Removed `const` from `HeliusConfig` constructor (breaking change for `const` usage)

_Owner:_ Ifiok Jr. · _Introduced in:_ [`21ae653`](https://github.com/openbudgetfun/solana_kit/commit/21ae6537efe0f3520c1aac32eac4e088fc23aaf1)

#### SEC-03: Use constant-time comparison for SensitiveString equality to prevent timing side-channel attacks.

- SensitiveString.operator== now uses constant-time byte comparison
- Prevents attackers from learning how many characters match between two secrets
- Added test verifying no early exit on mismatch

_Owner:_ Ifiok Jr. · _Introduced in:_ [`76f2c14`](https://github.com/openbudgetfun/solana_kit/commit/76f2c1456cc408da94ab54da5f68a92e4f42e965)
