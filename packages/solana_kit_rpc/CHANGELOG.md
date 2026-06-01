# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.5.0) (2026-06-01)

### 🧪 Testing

#### Improve test coverage to 95%+ across all packages

Added 500+ tests covering equality/hashCode/toString, codec edge cases, error paths, and constructor variants. Removed dead code in fast_stable_stringify. Fixed concurrent modification bug in subscribable.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #166](https://github.com/openbudgetfun/solana_kit/pull/166)

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-30)

### 🚀 Feature

#### Add typed value methods to RPC methods

Add typed value convenience methods to SolanaRpcMethods…

Add typed value convenience methods to `SolanaRpcMethods` extension

Five new methods join the existing raw-request helpers on `Rpc`:

- `getAccountInfoValue(address, config)` — returns `PendingRpcRequest<SolanaRpcResponse<Map<String, Object?>?>>`, parsing the JSON-RPC response envelope into a typed `SolanaRpcResponse` wrapper so callers access `.value` and `.context.slot` directly instead of manually navigating the raw map.
- `getBalanceValue(address, config)` — returns `PendingRpcRequest<SolanaRpcResponse<Lamports>>`, converting the integer balance into a `Lamports` value type.
- `getLatestBlockhashValue(config)` — returns `PendingRpcRequest<SolanaRpcResponse<LatestBlockhashValue>>`, parsing the blockhash and last-valid-block-height into a structured model.
- `getMultipleAccounts(addresses, config)` — raw multi-account fetch returning `PendingRpcRequest<Map<String, Object?>>`.
- `getMultipleAccountsValue(addresses, config)` — typed multi-account fetch returning `PendingRpcRequest<SolanaRpcResponse<List<Map<String, Object?>?>>>`.

Each `*Value` method uses an internal `_mapPendingRpcRequest` adapter that wraps the underlying raw request plan and applies a response parser, keeping the transport and plan plumbing intact. The existing raw methods (`getAccountInfo`, `getBalance`, `getLatestBlockhash`, etc.) remain unchanged, so this is purely additive.

Additionally, the `createSolanaJsonRpcIntegerOverflowError` helper now calls `createSolanaError(...)` instead of the `SolanaError(...)` constructor, and uses `SolanaErrorContextKeys.methodName` and `SolanaErrorContextKeys.path` for standardised context keys. This aligns error construction with the rest of the `solana_kit_errors` surface.

The README code examples have been updated to demonstrate the preferred typed-call pattern (`rpc.getLatestBlockhashValue().send()`) and a new "Preferred Dart path" callout section guides users toward typed helpers before falling back to raw `rpc.request(...)`.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)
