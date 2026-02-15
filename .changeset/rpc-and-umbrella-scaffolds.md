---
solana_kit_rpc_types: minor
solana_kit_rpc_spec_types: minor
solana_kit_rpc_spec: minor
solana_kit_rpc_api: minor
solana_kit_rpc_parsed_types: minor
solana_kit_rpc_transformers: minor
solana_kit_rpc_transport_http: minor
solana_kit_rpc: minor
solana_kit_rpc_subscriptions_api: minor
solana_kit_rpc_subscriptions_channel_websocket: minor
solana_kit_rpc_subscriptions: minor
solana_kit_accounts: minor
solana_kit_programs: minor
solana_kit_program_client_core: minor
solana_kit_sysvars: minor
solana_kit_transaction_confirmation: minor
solana_kit: minor
---

Initial scaffold for 17 higher-level packages including the full RPC stack,
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
