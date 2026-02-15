---
solana_kit_rpc_spec_types: minor
---

Implement RPC spec types package ported from `@solana/rpc-spec-types`.

**solana_kit_rpc_spec_types** (96 tests):

- `RpcRequest<TParams>` class with method name and typed parameters
- `RpcRequestTransformer` and `RpcResponseTransformer` function typedefs
- `RpcErrorResponsePayload` with code, message, and optional data
- `RpcResponseData` sealed class with `RpcResponseResult` and `RpcResponseError` subtypes
- `createRpcMessage` for JSON-RPC 2.0 message creation with auto-incrementing IDs
- `parseJsonWithBigInts` for JSON parsing that preserves large integers as `BigInt`
- `stringifyJsonWithBigInts` for JSON serialization that renders `BigInt` values as bare numbers
