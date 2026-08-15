---
"solana_kit_surfpool": minor
"codama-renderers-dart": patch
"solana_kit": patch
"solana_kit_errors": patch
"solana_kit_integration_tests": minor
"solana_kit_mpl_bubblegum": patch
"solana_kit_system": patch
---

# Kit-plugin style Surfpool client + SDK-based integration tests

## `solana_kit_surfpool` (minor)

Add `createSurfpoolClient()` / `connectSurfpoolClient()` returning a
`SurfpoolClient` wired up like the `@solana/surfpool/kit` plugin for
TypeScript:

- `rpc` / `rpcSubscriptions` — Solana Kit RPC and subscriptions clients
  pointed at the Surfnet.
- `payer` — the Surfnet's pre-funded `KeyPairSigner` (embedded mode) or a
  caller-provided funded signer (attach mode).
- `cheatcodes` — a typed `SurfnetCheatcodes` RPC covering every `surfnet_*`
  cheatcode with the prefix stripped (`timeTravel`, `pauseClock`, `setAccount`,
  `writeProgram`, …).
- `rpcUrl` / `wsUrl` — the Surfnet's HTTP and WebSocket URLs.
- `airdrop` / `getMinimumBalance` — funding and rent-exemption helpers.
- `stop()` — idempotent teardown that stops the Surfnet when this client
  started it.

`createSurfpoolClient` stops the Surfnet if wiring fails, so no orphaned
process or ports are left behind. The new API is fully unit-tested with 100%
patch coverage.

## `codama-renderers-dart` (patch)

Fix `visitSizePrefixType` so BigInt-width size prefixes (u64/u128/i64/i128)
generate `transformEncoder`/`transformDecoder` wrappers instead of
substituting u32. The system program's bincode String length is u64, so the
u32 substitution broke on-chain encoding of seed fields.

## `solana_kit_system` (patch)

Regenerate the system program client with the size-prefix renderer fix;
`createAccountWithSeed`, `allocateWithSeed`, `assignWithSeed`, and
`transferSolWithSeed` now encode their u64 String-length prefixes correctly.

## `solana_kit_errors` (patch)

Fix `getSolanaErrorFromTransactionError` to handle `account_index` values
returned as `BigInt` by some RPC nodes (e.g. SurfPool), matching the earlier
instruction-error-index fix.

## `solana_kit` (patch)

Convert `test/integration/rpc_basic_test.dart` to start its own Surfpool via
the SDK instead of requiring an externally launched validator.

## `solana_kit_mpl_bubblegum` (patch)

Convert the compressed-NFT integration test to start its own Surfpool via the
SDK; add `solana_kit_surfpool` as a dev dependency.

## `solana_kit_integration_tests` (minor)

Integration tests now start their own Surfpool per test file via the SDK
(auto-allocated ports, parallel-safe) instead of requiring an externally
launched instance. Adds the gap-coverage tests: loader full deploy, system
seed-based instructions, config store (committed `config-v3.0.0.so` artifact),
subscriptions on-chain lifecycle, ALT extend/deactivate/close, error paths,
token/2022 transfer+burn+setAuthority+closeAccount, stake authorize, and ATA
idempotency.
