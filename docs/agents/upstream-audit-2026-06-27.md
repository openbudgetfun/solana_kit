# Upstream audit — 2026-06-27

## Scope

Full upstream parity audit across all packages in the workspace compared with
their upstream TypeScript equivalents.

## Core `@solana/kit` drift: 6.9.0 → 6.10.0

Updated `versions.json` to track `@solana/kit` `6.10.0`.

### Packages changed

| Dart package | Upstream area | Changes |
|---|---|---|
| `solana_kit_errors` | `@solana/errors` 6.10 | Added 6 new error codes, 2 new error domains, updated `unwrapSimulationError` |
| `solana_kit_subscribable` | `@solana/subscribable` 6.10 | Added `ReactiveActionStore`, `ReactiveStreamStore` with retry/unified state |
| `solana_kit_rpc_spec` | `@solana/rpc-spec` 6.10 | Added `PendingRpcRequest.reactiveStore()` |
| `solana_kit_rpc_api` | `@solana/rpc-api` 6.10 | Added `clientId` to `ClusterNode`, deprecated UDP TPU fields |
| `solana_kit_transaction_messages` | `@solana/kit` 6.10 | Added resource-limit estimation helpers |

## Program package drift

### Real generated API changes

| Package | Old pin | New pin | Changes |
|---|---|---|---|
| `solana_kit_token_2022` | `js@v0.9.0` | `js@v0.12.0` | 9 new instructions, 10 changed instructions, 2 new extension types |
| `solana_kit_subscriptions` | `ts-client-v0.3.0` | `ts-client-v0.4.0-rc.2` | 3 new instructions, 4 new errors, changed account lists on 11 instructions |

### Reference pin bumps (no Dart API changes)

| Package | Old pin | New pin |
|---|---|---|
| `solana_kit_token` | `js@v0.13.0` | `js@v0.14.0` |
| `solana_kit_address_lookup_table` | `js@v0.11.0` | `js@v0.12.1` |
| `solana_kit_memo` | `js@v0.11.1` | `js@v0.11.2` |
| `solana_kit_compute_budget` | `js@v0.15.0` | `js@v0.16.0` |
| `solana_kit_stake` | `js@v0.6.1` | `js@v0.7.2` |
| `solana_kit_loader` (v3) | `js@v0.3.0` | `js@v0.4.0` |

### Already current

- `solana_kit_system` — `js@v0.12.2` ✅
- `solana_kit_associated_token_account` — `program@v8.0.0` ✅
- `solana_kit_config` — `solana-config-program-client@v1.1.0` ✅

## Renderer fixes

Three latent bugs in `codama-renderers-dart` were fixed during regeneration:
1. Empty struct constructors (`const Foo({})` → `const Foo()`)
2. PDA seed import merging (missing `solana_kit_codecs_numbers` import)
3. BigInt incorrectly attributed to `dart:typed_data` (is in `dart:core`)