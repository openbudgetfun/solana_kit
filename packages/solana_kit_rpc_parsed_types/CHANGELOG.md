# Changelog

All notable changes to this package will be documented in this file.

## 0.0.2 (2026-02-21)

### Features

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

#### Implement RPC parsed types package ported from `@solana/rpc-parsed-types`.

**solana_kit_rpc_parsed_types** (32 tests):

- Typed representations of JSON-parsed account data from the Solana RPC
- Address lookup table, BPF upgradeable loader, config, nonce, stake, sysvar, token, and vote account types
- Sealed class hierarchies for discriminated unions enabling exhaustive pattern matching
- `RpcParsedType<TType, TInfo>` and `RpcParsedInfo<TInfo>` base classes
- All 10 sysvar account types: clock, epochRewards, epochSchedule, fees, lastRestartSlot, recentBlockhashes, rent, slotHashes, slotHistory, stakeHistory
- Token program accounts: account, mint, multisig with `TokenAccountState` enum
