# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## codama-renderers-dart [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/codama-renderers-dart/v0.4.0) (2026-05-30)

### 💥 Breaking Change

#### New package available

Codama renderer for generating Dart code targeting the solana_kit SDK. Enables automatic generation of type-safe Dart client code from Codama IDL definitions.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add Codama IDL acceptance fixtures

Add comprehensive Codama IDL acceptance fixtures for SPL…

Add comprehensive Codama IDL acceptance fixtures for SPL Token, Token-2022, and System programs.

Three new Codama JSON IDL fixtures are added under `test/fixtures/`:

- **`spl_token.json`** + `spl_token.meta.json` — Full SPL Token program IDL (shank origin, 34 extensions, ATA program, associated types, errors)
- **`token_2022.json`** + `token_2022.meta.json` — Full Token-2022 program IDL (js@v0.9.0, 35 extensions including confidential transfers, metadata pointer, token groups, pausable config, scaled UI amounts)
- **`system.json`** + `system.meta.json` — Full System Program IDL (js@v0.12.0, 13 instructions, Nonce account types, 9 error codes)

Each fixture includes a `.meta.json` provenance file recording the source repository, git commit, tag, file path, and SHA-256 hash for traceability.

These fixtures expand the renderer's acceptance test surface from a single SPL Token fixture to three real-world Solana programs covering diverse IDL features: nested enum variants with size-prefixed structs, zeroable option types, map types with prefixed counts, multiple additional programs, PDA definitions with seed derivation, and error code catalogs. The expanded coverage catches rendering edge cases that simpler IDLs do not exercise.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Make Codama renderer production-ready

Make codama-renderers-dart production-ready for real…

Make codama-renderers-dart production-ready for real Solana program IDLs.

- Pin upstream SPL Token Codama JSON as acceptance fixture with provenance metadata
- Fix nullable codec type inference by emitting explicit type parameters
- Fix double-`??` on nullable optional instruction parameters
- Fix local variable shadowing in instruction builders and PDA helpers
- Add SPL Token acceptance test with dart analyze gate (28→0 errors)
- Add JS-vs-Dart structural parity tests for the SPL Token fixture
- Expose surfpool in devenv shell for validator-backed testing

_Owner:_ Ifiok Jr. · _Introduced in:_ [`c02af42`](https://github.com/openbudgetfun/solana_kit/commit/c02af42fc361fe016f54cfdfe0ad9b6ce2d1c13e) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add per-package codecov flags

Add Codecov patch coverage and package-level coverage…

Add Codecov patch coverage and package-level coverage flags for Dart and renderer packages.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`30e1d19`](https://github.com/openbudgetfun/solana_kit/commit/30e1d192192800481fbdc6afa57dc1a1fd255986) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

## codama-renderers-dart [0.4.1](https://github.com/openbudgetfun/solana_kit/releases/tag/codama-renderers-dart/v0.4.1) (2026-06-01)

### 🚀 Feature

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

## codama-renderers-dart [0.4.3](https://github.com/openbudgetfun/solana_kit/releases/tag/codama-renderers-dart/v0.4.3) (2026-08-12)

### 🐛 Fixed

#### Harden cryptographic input handling

Harden keypair file writes, validate malformed mobile wallet cryptographic inputs, and update vulnerable renderer test dependencies.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #181](https://github.com/openbudgetfun/solana_kit/pull/181)

#### Subscriptions: regenerate from ts-client-v0.4.0-rc.2

Regenerates the Subscriptions generated code from upstream IDL `ts-client-v0.4.0-rc.2` (was `ts-client-v0.3.0`). Adds 3 new instructions:

- `revokeSubscriptionAuthority`
- `revokeAbandonedDelegation`
- `revokeAbandonedSubscription`

Adds 4 new errors: `transferHookTooManyAccounts`, `invalidSelfProgram`, `planEndTsCannotExtend`, `recurringDelegationStartOnLandingRequiresExpiry`.

Updates existing instructions with new required/optional accounts (`payer`, `receiver`, `subscriptionAuthority`, `eventAuthority`, `selfProgram`) and PDA-based `eventAuthority` defaults.

Also fixes three latent renderer bugs in `codama-renderers-dart`: empty struct constructors, PDA seed import merging, and BigInt import attribution.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #195](https://github.com/openbudgetfun/solana_kit/pull/195)

### Changed

#### Advance past the aborted npm release

Publish the replacement renderer release as `0.4.3` because `0.4.2` was published to npm before the previous multi-package release was aborted. The `0.4.2` npm version is immutable; no additional renderer behavior changes are introduced by this recovery changeset.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`e3148f0`](https://github.com/openbudgetfun/solana_kit/commit/e3148f01352fb39d6982317c4725b2eb36af714d)

## codama-renderers-dart [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/codama-renderers-dart/v0.5.0) (2026-08-18)

### 💥 Breaking Change

#### Generate program-level instruction identification and parsing helpers

Generate typed program instruction identifiers and parsers from instruction discriminators, and expose the generated helpers in the Compute Budget program client.

```dart
// Before: hand-rolled discriminator matching
if (data[0] == 0x02) {
  // setComputeUnitLimit
}

// After: generated identification and parsing helpers
final instruction = identifyComputeBudgetInstruction(data);
final parsed = parseComputeBudgetInstruction(data);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #204](https://github.com/openbudgetfun/solana_kit/pull/204)

#### Render matching collection size-prefix codecs

Generate collection size prefixes with direction-specific number codecs: encoder manifests now use the matching number encoder and decoder manifests use the matching decoder. This fixes generated arrays, maps, and sets that use wide `BigInt` prefixes such as `u64`.

Reject unresolved logical import keys instead of rendering invalid Dart URIs, support self-referential and digit-containing defined types, and prefix data-enum variants with their parent type to avoid ambiguous exports.

```dart
// Before: wide size prefixes were substituted with u32
final encoder = getArrayEncoder(getU8Encoder(), getU32Encoder());

// After: direction-specific number codecs
final encoder = getArrayEncoder(getU8Encoder(), getU64Encoder());
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #204](https://github.com/openbudgetfun/solana_kit/pull/204)

### 🐛 Fixed

#### Harden credentials, keys, transports, and untrusted RPC decoding

Align Helius signup and project provisioning with the v3 bearer-JWT API, generate valid Ed25519 authentication keypairs, validate payment inputs, and redact WebSocket credentials.

Dispose or clear SDK-owned key material deterministically, create key files exclusively with safe POSIX permissions, and preserve caller ownership of Surfpool signers.

Reject malformed RPC transaction and inner-instruction data instead of silently dropping it, expand private WebSocket literal filtering, and update JavaScript dependency overrides to releases without the audited advisories. Make the standalone Codama renderer workspace declare its own build tools and explicitly allow only esbuild's required install script.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #213](https://github.com/openbudgetfun/solana_kit/pull/213) · _Related issues:_ [#159](https://github.com/openbudgetfun/solana_kit/issues/159), [#163](https://github.com/openbudgetfun/solana_kit/issues/163), [#186](https://github.com/openbudgetfun/solana_kit/issues/186), [#198](https://github.com/openbudgetfun/solana_kit/issues/198), [#203](https://github.com/openbudgetfun/solana_kit/issues/203), [#204](https://github.com/openbudgetfun/solana_kit/issues/204), [#205](https://github.com/openbudgetfun/solana_kit/issues/205), [#206](https://github.com/openbudgetfun/solana_kit/issues/206), [#207](https://github.com/openbudgetfun/solana_kit/issues/207), [#208](https://github.com/openbudgetfun/solana_kit/issues/208), [#210](https://github.com/openbudgetfun/solana_kit/issues/210), [#211](https://github.com/openbudgetfun/solana_kit/issues/211), [#34](https://github.com/openbudgetfun/solana_kit/issues/34), [#37](https://github.com/openbudgetfun/solana_kit/issues/37)

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

## codama-renderers-dart [0.5.1](https://github.com/openbudgetfun/solana_kit/releases/tag/codama-renderers-dart/v0.5.1) (2026-08-19)

### 🐛 Fixed

#### Fix Wide Scalar Enum Codecs

Generate type-correct Dart codecs for scalar enums with `u64` discriminators. The encoder now converts enum indices to `BigInt`, while the decoder validates the decoded discriminator before converting it to a Dart enum index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #219](https://github.com/openbudgetfun/solana_kit/pull/219)

#### Support Current Codama and Serialized Pina IDLs

Align the Dart renderer with Codama 1.10, normalize omitted serialized child collections from Pina IDLs, and publish valid module entry points for Node, browser, and React Native consumers.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #214](https://github.com/openbudgetfun/solana_kit/pull/214)

#### Reject over-capacity generated values

Adds an opt-in non-truncating mode to fixed-size encoders and codecs. Codama fixed-size types now use that mode so generated string, byte, and collection encoders pad values within capacity but reject oversized encoded values.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #216](https://github.com/openbudgetfun/solana_kit/pull/216)

#### Enforce Dart discriminator and optional-account invariants

Hide omitted defaults from generated builder inputs, force their declared wire values during encoding, validate account and instruction discriminators during decoding, require exact instruction input consumption, reject truncated account data while preserving legitimate trailing account capacity unless a size discriminator requires an exact length, and preserve optional account positions with readonly program-address placeholders.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #215](https://github.com/openbudgetfun/solana_kit/pull/215)

## codama-renderers-dart [0.5.2](https://github.com/openbudgetfun/solana_kit/releases/tag/codama-renderers-dart/v0.5.2) (2026-08-30)

### 🚀 Feature

#### Typed tuple codecs and explicit integer factories

Add typed `getTuple2Encoder`/`getTuple2Decoder` helpers to `solana_kit_codecs_data_structures`, exposing two-element tuples as Dart records. Give the integer codec factories in `solana_kit_codecs_numbers` explicit generic specializations while preserving their existing `FixedSizeEncoder<num>` public return types. `codama-renderers-dart` now emits `getTuple2*` for arity-2 tuple nodes, escapes Dart reserved-word identifiers, keeps generated `instructionData` locals collision-free, and gives generated byte/list fields recursive value equality and hashing.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)

### 📖 Documentation

#### Unslop package docs and code comments

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)

## codama-renderers-dart [0.5.3](https://github.com/openbudgetfun/solana_kit/releases/tag/codama-renderers-dart/v0.5.3) (2026-08-30)

### 🐛 Fixed

#### Fix publish validation for ecosystem packages

Declare the `meta` and `solana_kit_accounts` dependencies that the generated Squads and mpl-token-metadata clients import, so `dart pub publish` validation passes, and normalize `readme.md` to `README.md` across the ecosystem packages to satisfy the pub README requirement.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`a53391f`](https://github.com/openbudgetfun/solana_kit/commit/a53391f69a4668422096a31bcac46397770a5d33)

## codama-renderers-dart [0.5.4](https://github.com/openbudgetfun/solana_kit/releases/tag/codama-renderers-dart/v0.5.4) (2026-09-06)

### 🐛 Fixed

#### Harden renderer input boundaries

Prevent path traversal and generated Dart code injection from IDL names, documentation, and string values. Pass formatter directories without shell evaluation and preserve existing output when rendering or import resolution fails.

Validate numeric IDL metadata, preserve codec prefix endianness and offset strategies, encode wide PDA constants as BigInt, and reject malformed byte seeds. Allow generated instruction builders to select non-signer roles for accounts declared with `isSigner: "either"`, with collision-free parameter names.

Reject duplicate and barrel-reserved generated paths instead of silently replacing nodes that share output names.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Track @solana/kit v8.2.0

The workspace now tracks upstream `@solana/kit` v8.2.0 and the parity harness passes against it.

- New `getAgGenesisCert` RPC method returning the Alpenglow genesis certificate (or `null`), with allowed numeric keypaths that keep `blockId`, `bitmap`, and `signature` byte arrays as numbers while upcasting `slot` to `BigInt`.
- `isSolanaRequest` recognizes `getAgGenesisCert` and the previously missed `getTransactionsForAddress`.
- New `createTransactionPlanExecutorWithConcurrentLeaves` mirroring upstream: every leaf starts concurrently (including across sequential plans), a failed leaf does not cancel siblings, non-divisible sequential plans are supported, and the executor builds results from the shared callback contract — context stored on the mutable map is preserved on failures.

Reference pins refreshed to the latest upstream tags (compute-budget v0.18.1, memo v0.13.1, token v0.16.1, token-2022 v0.16.1, stake v0.9.1, address-lookup-table v0.14.1, system v0.14.1, loader-v3 v0.6.1 — all packaging-only upstream changes), and the Codama renderer dependencies moved to codama 1.10.2 / renderers-core 1.4.0.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #239](https://github.com/openbudgetfun/solana_kit/pull/239)
