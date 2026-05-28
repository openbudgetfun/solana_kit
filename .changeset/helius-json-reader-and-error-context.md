---
"solana_kit_helius": patch
---

# Introduce internal JsonReader helper and structured error…

Introduce internal `JsonReader` helper and structured error context for Helius type deserialization.

## JsonReader

Add a `JsonReader` class in `lib/src/internal/json_reader.dart` that wraps a raw `Map<String, Object?>` and provides typed accessor methods (`requireString`, `requireInt`, `optString`, `optEnum`, `requireDecodedList`, etc.). This eliminates manual `! as T` casts scattered across every `fromJson` factory in the Helius type system.

All type files (`auth_types.dart`, `das_types.dart`, `enhanced_types.dart`, `priority_fee_types.dart`, `rpc_v2_types.dart`, `smart_transaction_types.dart`, `staking_types.dart`, `wallet_types.dart`, `webhook_types.dart`, `zk_types.dart`) are migrated to use `JsonReader`, making deserialization more readable and ensuring consistent `FormatException` messages when a required field is absent or null.

## Structured error context

`JsonRpcClient` and `RestClient` now throw errors via `createSolanaError` with structured context keys (`methodName`, `operation`, `statusCode`, `url`) instead of plain `SolanaError` constructors. This gives downstream consumers machine-readable error metadata for logging and diagnostics.

## Impact

No public API changes. All `JsonReader` usage is internal to `lib/src/`. Deserialization behavior is functionally equivalent but error messages are now consistent `FormatException` instances rather than raw `TypeError`/`CastError` from Dart's `as` operator.
