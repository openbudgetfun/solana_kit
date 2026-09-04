# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_integration_tests [0.0.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_integration_tests/v0.0.1) (2026-08-18)

### 🚀 Feature

#### On-chain integration tests for program clients + sendTransaction encoding fix

##### `solana_kit_transaction_confirmation` (patch)

Fix `sendAndConfirmTransaction` so the `sendTransaction` RPC call declares `encoding: base64`. The helper encodes the transaction as base64 via `getBase64EncodedWireTransaction` but previously left the `encoding` field unset, so real RPC nodes (including SurfPool) defaulted to base58 and rejected the payload with `invalid base58 encoding`. This path had only been exercised against a mocked transport, so the bug was latent.

##### `solana_kit_errors` (patch)

Fix `getSolanaErrorFromTransactionError` to handle instruction-error indices returned as `BigInt` (as SurfPool does). The instruction index was cast `as num`, which threw `_BigIntImpl is not a subtype of num` and masked the real on-chain instruction error. It now converts `BigInt` indices to `int`.

##### `solana_kit_address_constants` / `solana_kit_spl_account_compression` (patch)

Fix the SPL Account Compression, Noop, and MPL Bubblegum program addresses to the live mainnet IDs:

- `splAccountCompressionProgramAddress`: `cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi` -> `cmtDvXumGCrqC1Age74AVPhSRVXJMd8PJS91L8KbNCK`
- `noopProgramAddress`: `noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK` -> `noopb9bkMVfRPU8AsbpTUg8AQkHtKwMYZiFUjNRtMmV`
- `mplBubblegumProgramAddress`: `BGUMAp9Gph7G9Jn2tU58R5L2qPG1Mj9HP7G3G7VYV2Ma` -> `BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY`
- `stakeConfigAddress`: `StakeConfig1111111111111111111111111111` (truncated, invalid length) -> `StakeConfig11111111111111111111111111111111`

The previous values point to accounts that do not exist on mainnet. An audit of every constant in the package against mainnet confirmed all other addresses are correct (native/runtime programs and sysvars are canonical per `solana-sdk-ids`; some native programs and lazily-created sysvars legitimately have no materialized account). SurfPool integration tests for MPL Bubblegum confirmed the corrected IDs resolve to deployed programs.

##### `solana_kit_integration_tests` (new, internal)

A non-published workspace package that runs every generated program client end-to-end against a local SurfPool Surfnet. It ships a shared `IntegrationTestEnv` harness (connects-or-starts SurfPool, funds a payer, builds/signs/sends/confirms transactions, deploys programs) and on-chain suites that assert the real on-chain outcome of each instruction:

- Builtin programs: Memo, System (transfer), Compute Budget, Token (createMint -> mintTo), Token-2022, Associated Token Account, Address Lookup Table, Stake (initialize), and BPF Loader (initializeBuffer).
- Subscriptions: the compiled program (`.so`) is committed under `config/programs/` and deployed on-chain; `initSubscriptionAuthority` runs and its PDA is verified on-chain.
- MPL Bubblegum: Bubblegum + SPL Account Compression + Noop are deployed on-chain (verified executable + owned by the BPF loader) and the full compressed-NFT lifecycle runs end-to-end: `createTree` (with the merkle-tree account sized per the account-compression layout formulas, 31800 bytes for (maxDepth=14, maxBufferSize=64, canopyDepth=0)) -> `mintV1` -> `transfer` (leaf owner signs) -> `burn` (new owner signs). The tree state (root, proof, index) is parsed from the on-chain ConcurrentMerkleTree account and the data/creator hashes are recomputed client-side to drive transfer and burn.

The compiled `.so` artifacts are committed (not rebuilt per run) and pinned to `config/reference-repos.json`; see `config/programs/README.md` for how they are built and when they must be regenerated. Artifact names follow `<package-name-minus-solana_kit>-<program-version>.so` (e.g. `subscriptions-v0.5.0.so`, `mpl_bubblegum-v0.12.0.so`, `spl_account_compression-v0.3.3.so`, `noop-v0.2.0.so`). All four are compiled from the pinned source with `cargo build-sbf` (agave 4.2.0 / platform-tools v1.54) via `scripts/build_program_artifacts.mjs` (devenv task `build:program-artifacts`), which also applies the ahash 0.7.6 `stdsimd` patch needed by the solana-program 1.18.x programs and verifies the baked-in program IDs.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #205](https://github.com/openbudgetfun/solana_kit/pull/205)

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

## solana_kit_integration_tests [0.0.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_integration_tests/v0.0.2) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_integration_tests` was updated to 0.0.2.

## solana_kit_integration_tests [0.1.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_integration_tests/v0.1.0) (2026-08-30)

### 🐛 Fixed

#### Harden Pyth and SNS validation

Require the Pyth price-update account signer declared by the receiver IDL, validate Pyth account headers and bounded integer inputs, normalize malformed update data to typed decode errors, and cover the signer requirement through the Surfpool transaction flow. Also enforce SNS record lengths, EVM address sizes, and TLD-trimmed domain-key inputs.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)

### 📖 Documentation

#### Unslop package docs and code comments

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)

## solana_kit_integration_tests [0.1.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_integration_tests/v0.1.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_integration_tests` was updated to 0.1.1.
