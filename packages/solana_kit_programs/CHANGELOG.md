# Changelog

All notable changes to this package will be documented in this file.

## 0.1.0 (2026-02-21)

### Notes

- First 0.1.0 release of this package.

## 0.0.2 (2026-02-21)

### Features

#### Implement instructions and programs packages ported from `@solana/instructions` and `@solana/programs`.

**solana_kit_instructions** (56 tests):

- `AccountRole` enhanced enum with bitflag values (readonly, writable, readonlySigner, writableSigner)
- 7 role manipulation functions: upgrade/downgrade signer/writable, merge, query
- `AccountMeta` and `AccountLookupMeta` immutable classes with const constructors
- `Instruction` class with optional accounts and data fields
- 6 instruction validation functions: isInstructionForProgram, isInstructionWithAccounts, isInstructionWithData (with assert variants)

**solana_kit_programs** (5 tests):

- `isProgramError` function to identify custom program errors from transaction failures
- Matches error code, instruction index, and program address against transaction message
- `TransactionMessageInput` and `InstructionInput` minimal types for error checking

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
