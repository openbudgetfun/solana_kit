---
"solana_kit_rpc": minor
---

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
