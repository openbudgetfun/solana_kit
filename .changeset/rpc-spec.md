---
solana_kit_rpc_spec: minor
---

Implement RPC spec package ported from `@solana/rpc-spec`.

**solana_kit_rpc_spec** (23 tests):

- `JsonRpcApi` with configurable request/response transformers creating `RpcPlan` objects
- `RpcPlan<T>` describing how to execute an RPC request with lazy execution
- `RpcTransport` typedef for pluggable transport layer
- `Rpc` client that wraps API + transport, returning `PendingRpcRequest` objects
- `PendingRpcRequest<T>` with `send()` method for deferred execution
- `isJsonRpcPayload` type guard for JSON-RPC 2.0 payload validation
- `RpcApi` abstract class with `JsonRpcApiAdapter` and `MapRpcApi` implementations
