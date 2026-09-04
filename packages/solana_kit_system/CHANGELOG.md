# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_system [0.3.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_system/v0.3.2) (2026-05-30)

### 🚀 Feature

#### Port System Program from upstream Codama IDL

##### codama-renderers-dart

- Fix instruction builder `programAddress` param collision when an instruction's data also has a `programAddress` field (e.g., System `Assign`, `CreateAccount`). The instruction-level program address is now named `instructionProgramAddress` when a collision exists.
- Fix BigInt-width size prefix types (u64/u128) in `sizePrefixTypeNode` by substituting u32 encoder/decoder, which satisfies the Dart `Encoder<num>` constraint.

##### solana_kit_system

- Replace the handwritten `CreateAccount` helper with a fully generated client from `solana-program/system` Codama IDL (`js@v0.12.0`, commit `95897f3`).
- Includes all 13 System Program instructions, Nonce account type, NonceVersion/NonceState enums, 9 error codes, and program address constant.

##### solana_kit_token

- Update `getCreateMintInstructionPlan` to use the renamed `instructionProgramAddress` parameter from the regenerated system instruction.

##### solana_kit

- Re-export `solana_kit_system` with `systemProgramAddress` hidden to avoid conflict with `solana_kit_transaction_messages`.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`1eaf898`](https://github.com/openbudgetfun/solana_kit/commit/1eaf898cd0598744731152e8841dc632fc2e69f9) · _Last updated in:_ [`5bccc42`](https://github.com/openbudgetfun/solana_kit/commit/5bccc42120e7bc038fc507719727500364a43bd9)

#### Detached from main group

This package is now released independently rather than as part of the main solana_kit group. The System Program client is a standalone program package that does not depend on the core solana_kit release cycle, so an independent release track is more appropriate.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add generated-code test coverage for token

Add comprehensive generated-code test coverage for…

Add comprehensive generated-code test coverage for solana_kit_token (instructions, accounts, types, PDAs) and solana_kit_system (codec round-trips, parse round-trip, program constants).

_Owner:_ Ifiok Jr. · _Introduced in:_ [`d930a56`](https://github.com/openbudgetfun/solana_kit/commit/d930a56035d5e4a34121be2a4d9ffcd30c0ad592) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

## solana_kit_system [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_system/v0.4.0) (2026-06-01)

### 💥 Breaking Change

#### Raise minimum Dart SDK to 3.12

Raise the minimum supported Dart SDK constraint to `^3.12.0` across public Dart packages.

This is a breaking change because consumers must use Dart 3.12 or newer. Flutter consumers must use a Flutter SDK that bundles Dart 3.12 or newer.

```yaml
environment:
  sdk: ^3.12.0
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`32d5d36`](https://github.com/openbudgetfun/solana_kit/commit/32d5d367abb7615fea5ee341f03d17c2bc0d66dd)

### 🐛 Fixed

#### Add well-known program, sysvar, SPL, Metaplex, and token mint address constants

Add centralized address constants to `solana_kit_addresses` so that any package can reference well-known on-chain addresses without importing the full domain package or hardcoding strings.

New exports:

- `program_addresses.dart` — All Agave/Solana native program addresses (system, ALT, BPF loaders, compute budget, config, stake, vote, etc.)
- `sysvar_addresses.dart` — All sysvar addresses (clock, rent, recentBlockhashes, fees, rewards, etc.) plus the sysvar owner address
- `spl_addresses.dart` — SPL program addresses (Token, Token-2022, ATA, Memo, Memo Legacy)
- `metaplex_addresses.dart` — Metaplex program addresses (Token Metadata, Bubblegum, Auth Rules, Core, SPL Account Compression, Noop)
- `well_known_addresses.dart` — Well-known token mint addresses (Wrapped SOL, USDC, USDT)

Also re-exports from `solana_kit_address` (Address type, codecs, comparator, PublicKey) and `solana_kit_address_constants` (well-known address constants).

_Owner:_ Ifiok Jr. · _Introduced in:_ [`3f596ef`](https://github.com/openbudgetfun/solana_kit/commit/3f596ef95c0d00714db97a4338ac9342f1fabfb7) · _Last updated in:_ [`4643648`](https://github.com/openbudgetfun/solana_kit/commit/46436481a28eab1c803175bee56e98e89fe8fac6)

## solana_kit_system [0.4.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_system/v0.4.1) (2026-06-03)

### 🚀 Feature

#### Update upstream program references

Update generated Solana program packages to the latest checked upstream refs:

```text
solana_kit_system: solana-program/system js@v0.12.2
solana_kit_stake: solana-program/stake js@v0.6.1
solana_kit_memo: solana-program/memo js@v0.11.1
```

`solana_kit_system` adds the `CreateAccountAllowPrefund` instruction helpers. `solana_kit_stake` includes the authority seed `u64` size-prefix fix and updated stake delegation layout.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #182](https://github.com/openbudgetfun/solana_kit/pull/182)

## solana_kit_system [0.4.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_system/v0.4.2) (2026-08-12)

### 📖 Documentation

#### Centralize package version documentation

Centralize package version metadata in `versions.json` and render package installation snippets from the shared MDT data source. Published package behavior is unchanged.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #188](https://github.com/openbudgetfun/solana_kit/pull/188)

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)

### 🔖 None

#### Format workflow lint follow-up files

Apply formatting-only changes discovered while adding the GitHub Actions workflow lint gate.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #185](https://github.com/openbudgetfun/solana_kit/pull/185)

## solana_kit_system [0.6.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_system/v0.6.0) (2026-08-18)

### 💥 Breaking Change

#### Regenerated program packages from upstream v7 IDLs

Regenerated all 8 generated program packages from their latest upstream Codama IDLs:

- solana_kit_system: js@v0.12.2 → v0.13.0
- solana_kit_token: js@v0.14.0 → v0.15.0
- solana_kit_token_2022: js@v0.12.0 → v0.14.1
- solana_kit_address_lookup_table: js@v0.12.1 → v0.13.0
- solana_kit_memo: js@v0.11.2 → v0.12.0
- solana_kit_compute_budget: js@v0.16.0 → v0.17.0
- solana_kit_stake: js@v0.7.2 → v0.8.0; applied the upstream Stake Codama preprocessing before rendering so generated defined-type imports resolve to Dart files
- solana_kit_loader: loader-v3 js@v0.4.0 → v0.5.0; migrated planning helpers to the generated v0.5 API and retained the handwritten Loader v3 account codecs and Loader v4 client surface

Generated using `node scripts/generate_program_packages.mjs` — a new generator script that runs the Codama renderer against upstream IDLs.

```dart
// Generated clients now match newer upstream IDLs, e.g. the system program:
final instruction = getCreateAccountInstruction(
  payer: payer.address,
  newAccount: newAccount.address,
  lamports: lamports,
  space: space,
  owner: owner,
);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #204](https://github.com/openbudgetfun/solana_kit/pull/204)

### 🐛 Fixed

#### Kit-plugin style Surfpool client + SDK-based integration tests

##### `solana_kit_surfpool` (minor)

Add `createSurfpoolClient()` / `connectSurfpoolClient()` returning a `SurfpoolClient` wired up like the `@solana/surfpool/kit` plugin for TypeScript:

- `rpc` / `rpcSubscriptions` — Solana Kit RPC and subscriptions clients pointed at the Surfnet.
- `payer` — the Surfnet's pre-funded `KeyPairSigner` (embedded mode) or a caller-provided funded signer (attach mode).
- `cheatcodes` — a typed `SurfnetCheatcodes` RPC covering every `surfnet_*` cheatcode with the prefix stripped (`timeTravel`, `pauseClock`, `setAccount`, `writeProgram`, …).
- `rpcUrl` / `wsUrl` — the Surfnet's HTTP and WebSocket URLs.
- `airdrop` / `getMinimumBalance` — funding and rent-exemption helpers.
- `stop()` — idempotent teardown that stops the Surfnet when this client started it.

`createSurfpoolClient` stops the Surfnet if wiring fails, so no orphaned process or ports are left behind. The new API is fully unit-tested with 100% patch coverage.

##### `codama-renderers-dart` (patch)

Fix `visitSizePrefixType` so BigInt-width size prefixes (u64/u128/i64/i128) generate `transformEncoder`/`transformDecoder` wrappers instead of substituting u32. The system program's bincode String length is u64, so the u32 substitution broke on-chain encoding of seed fields.

##### `solana_kit_system` (patch)

Regenerate the system program client with the size-prefix renderer fix; `createAccountWithSeed`, `allocateWithSeed`, `assignWithSeed`, and `transferSolWithSeed` now encode their u64 String-length prefixes correctly.

##### `solana_kit_errors` (patch)

Fix `getSolanaErrorFromTransactionError` to handle `account_index` values returned as `BigInt` by some RPC nodes (e.g. SurfPool), matching the earlier instruction-error-index fix.

##### `solana_kit` (patch)

Convert `test/integration/rpc_basic_test.dart` to start its own Surfpool via the SDK instead of requiring an externally launched validator.

##### `solana_kit_mpl_bubblegum` (patch)

Convert the compressed-NFT integration test to start its own Surfpool via the SDK; add `solana_kit_surfpool` as a dev dependency.

##### `solana_kit_integration_tests` (minor)

Integration tests now start their own Surfpool per test file via the SDK (auto-allocated ports, parallel-safe) instead of requiring an externally launched instance. Adds the gap-coverage tests: loader full deploy, system seed-based instructions, config store (committed `config-v3.0.0.so` artifact), subscriptions on-chain lifecycle, ALT extend/deactivate/close, error paths, token/2022 transfer+burn+setAuthority+closeAccount, stake authorize, and ATA idempotency.

```dart
// Before: manual Surfnet wiring
final surfnet = await Surfnet.start();
final rpc = createSolanaRpc(surfnet.rpcUrl);

// After: kit-plugin style client
final client = await createSurfpoolClient();
final rpc = client.rpc;
final payer = client.payer;
await client.cheatcodes.timeTravel(...);
await client.stop();
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #208](https://github.com/openbudgetfun/solana_kit/pull/208)

## solana_kit_system [0.6.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_system/v0.6.1) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_system` was updated to 0.6.1.

## solana_kit_system [0.7.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_system/v0.7.0) (2026-08-30)

### 🐛 Fixed

#### Refresh upstream reference pins for solana-program/* and mpl-bubblegum

- Tracks the latest upstream references in `config/reference-repos.json`: `solana-program/system` `js@v0.14.0` (was `js@v0.13.0`), `solana-program/token` `js@v0.16.0` (was `js@v0.15.0`), `solana-program/token-2022` `js@v0.16.0` (was `js@v0.14.1`), `solana-program/address-lookup-table` `js@v0.14.0` (was `js@v0.13.0`), `solana-program/memo` `js@v0.13.0` (was `js@v0.12.0`), `solana-program/compute-budget` `js@v0.18.0` (was `js@v0.17.0`), `solana-program/stake` `js@v0.9.0` (was `js@v0.8.0`), `solana-program/loader-v3` `js@v0.6.0` (was `js@v0.5.0`), `solana-program/loader-v4` commit `4f62fb2e` (was commit `1d6335be`), and `mpl-bubblegum` commit `6a6a77e3` (was commit `68e4bc20`).
- All of the `js` releases are `@solana/kit` ^7 → ^8 dependency bumps with no instructions, accounts, types, or wire-format changes; the IDL additions are Codama display metadata, which the Dart renderer does not render. Regenerating every affected client from the old and new pins produced byte-identical Dart output, so the generated clients are unchanged. The `mpl-bubblegum` new commit only re-exports the JS `mintV2` helpers and the `loader-v4` new commit only bumps its JS client to `@solana/kit` v8; both IDLs are unchanged. The `token-2022` pin supersedes the stale PR #222 (`js@v0.15.0`).
- `solana-program/stake` restructured its IDL to the Codama v1.8.0 format (program metadata block, `lockupParams` argument links renamed from `lockupArgs`, IDL program node renamed from `solanaStakeInterface` to `stake`). `scripts/generate_program_packages.mjs` now maps both argument link names and keeps the `solanaStakeInterface` renderer-facing program name, so the generated APIs (flattened `setLockup`/`setLockupChecked`/`authorizeWithSeed` argument fields, `SolanaStakeInterface` identifiers) stay stable. No generated Dart code changed.
- Package READMEs now cite the refreshed upstream versions they mirror.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #226](https://github.com/openbudgetfun/solana_kit/pull/226) · _Related issues:_ [#222](https://github.com/openbudgetfun/solana_kit/issues/222), [#225](https://github.com/openbudgetfun/solana_kit/issues/225)

### 📖 Documentation

#### Unslop package docs and code comments

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)

## solana_kit_system [0.7.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_system/v0.7.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_system` was updated to 0.7.1.
