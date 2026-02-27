# Changelog

All notable changes to this package will be documented in this file.

## 0.2.0 (2026-02-27)

### Breaking Changes

#### Initial Release

The initial release of all libraries.

### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Add runnable examples for specialized and mobile-focused packages, including websocket subscriptions, sysvars, and transaction confirmation flows.
- Document fix: resolve fatal analyzer infos across workspace.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

## 0.1.0 (2026-02-21)

### Notes

- First 0.1.0 release of this package.

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

#### Implement transaction confirmation package ported from `@solana/transaction-confirmation`.

**solana_kit_transaction_confirmation** (60 tests):

- `createRecentSignatureConfirmationPromiseFactory` with dual-pronged subscription + one-shot query
- `createBlockHeightExceedencePromiseFactory` monitoring slot notifications for block height tracking
- `createNonceInvalidationPromiseFactory` detecting durable nonce advancement
- `getTimeoutPromise` with commitment-based timeouts (30s processed, 60s confirmed/finalized)
- `raceStrategies` core strategy racing with safe future handling
- `waitForRecentTransactionConfirmation` high-level blockhash-based confirmation
- `waitForDurableNonceTransactionConfirmation` high-level nonce-based confirmation
- `waitForRecentTransactionConfirmationUntilTimeout` (deprecated) timeout-based fallback
- Dependency injection pattern for RPC functions to keep dependencies minimal
