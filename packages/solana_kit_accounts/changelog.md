# Changelog

All notable changes to this package will be documented in this file.

## 0.0.2 (2026-02-21)

### Features

#### Implement accounts package ported from `@solana/accounts`.

**solana_kit_accounts** (45 tests):

- `Account<TData>` and `BaseAccount` with owner, lamports, executable, rentEpoch fields
- `EncodedAccount` typedef for base64-encoded account data
- `MaybeAccount<TData>` sealed class: `ExistingAccount` and `NonExistingAccount` variants
- `assertAccountExists()` and `assertAccountsExist()` for null-safe account unwrapping
- `parseBase64RpcAccount()`, `parseBase58RpcAccount()`, `parseJsonRpcAccount()` parsers
- `decodeAccount()`, `decodeMaybeAccount()` with codec-based data decoding
- `assertAccountDecoded()`, `assertAccountsDecoded()` for decoded type assertions
- `fetchEncodedAccount()`, `fetchEncodedAccounts()` via RPC `getAccountInfo`/`getMultipleAccounts`
- `fetchJsonParsedAccount()`, `fetchJsonParsedAccounts()` for JSON-parsed account data

#### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)
