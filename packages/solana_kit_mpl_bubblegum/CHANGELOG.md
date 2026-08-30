# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_mpl_bubblegum [0.2.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mpl_bubblegum/v0.2.0) (2026-05-30)

### 💥 Breaking Change

#### Add Metaplex Bubblegum (compressed NFT) package

New package providing mpl-bubblegum compressed NFT utilities for the Solana Kit Dart SDK:

- **Keccak-256 hashing** (`bubblegumHash`, `hashLeafV1`, `hashLeafV2`) matching on-chain program logic
- **Merkle tree** construction and proof verification (`MerkleTree`, `computeEmptyNode`)
- **PDA derivation** (`findTreeAuthorityPda`, `findLeafAssetIdPda`, `findBubblegumSignerPda`)
- **Leaf schema V2 flags** (`LeafSchemaV2Flags`) for parsing compressed NFT leaf data
- **Transfer eligibility** (`canTransfer`) for checking frozen/non-transferable status
- **Program addresses** (`mplBubblegumProgramAddress`, `tokenMetadataProgramAddress`)

> **Note:** Codama-generated instruction builders and account decoders are not yet available and will be added in a future release once the IDL-to-Dart pipeline supports these programs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🚀 Feature

#### Add composite helpers, DAS client, and V2 support

- Add getMintV2InstructionPlan() for V2 minting
- Add getMintToCollectionV1InstructionPlan() for collection minting
- Add getCreateTreeV2InstructionPlan() for V2 tree creation
- Add HeliusDasClient for DAS API integration
- Add MetadataArgsV2 encoder
- Add README documentation

_Owner:_ Ifiok Jr. · _Introduced in:_ [`ff2ad0e`](https://github.com/openbudgetfun/solana_kit/commit/ff2ad0e5d055a5aee984b3d0bf6c381b8c580e58) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add on-chain integration tests and compressed NFT example

Add integration tests for compressed NFT operations and a Dart CLI example.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`99a29b3`](https://github.com/openbudgetfun/solana_kit/commit/99a29b34f41a35e5e3a20601da2f04e62da42ca7) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Fix barrel export ambiguity

Fix ambiguous_export, directives_ordering, and eol_at_end_of_file lint issues in the barrel file.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`d5765af`](https://github.com/openbudgetfun/solana_kit/commit/d5765af199ad10b93ff613abe46a942b70205ba1)

#### Refactor to idiomatic Dart patterns

- Add `concatBytes()` and `concatAll()` utilities for efficient byte array concatenation
- Replace `Uint8List.fromList([...a, ...b])` with `concatBytes(a, b)` in merkle tree and hash functions
- Add `@immutable` annotation to internal `_MerkleNode` class
- Use `const` constructor for immutable classes
- Add `zeroBytes32()`, `bytes32FromHex()`, `bytes32ToHex()` utilities for 32-byte arrays

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9dc6bc6`](https://github.com/openbudgetfun/solana_kit/commit/9dc6bc6bf16d1e883c2ebb1e806c1a710468dfd3) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

## solana_kit_mpl_bubblegum [0.3.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mpl_bubblegum/v0.3.0) (2026-06-01)

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

### 🧪 Testing

#### Optimize compressed NFT integration test polling

Replaced a fixed local airdrop delay with short balance polling so integration tests complete faster while preserving the same assertion.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`ead9932`](https://github.com/openbudgetfun/solana_kit/commit/ead9932533e0ebd1dabf7e8fde813b1d6d372208)

## solana_kit_mpl_bubblegum [0.3.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mpl_bubblegum/v0.3.1) (2026-08-12)

### 📖 Documentation

#### Centralize package version documentation

Centralize package version metadata in `versions.json` and render package installation snippets from the shared MDT data source. Published package behavior is unchanged.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #188](https://github.com/openbudgetfun/solana_kit/pull/188)

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)

## solana_kit_mpl_bubblegum [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mpl_bubblegum/v0.4.0) (2026-08-18)

### 💥 Breaking Change

#### Sync MPL Bubblegum errors and instruction discriminators

Added the upstream Bubblegum collection seller-fee errors from commit `68e4bc20`, exported generated error helpers from the generated barrel, corrected the canonical Bubblegum program address, and encoded generated instructions with Anchor 8-byte discriminators instead of ordinal indices.

```dart
// Before: instructions encoded with an ordinal index discriminator
final data = Uint8List.fromList([0x00, ...args]);

// After: generated encoders emit the Anchor 8-byte discriminator
final data = getTransferInstructionDataEncoder().encode(
  TransferInstructionData(leafOwner: owner, ...),
);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #204](https://github.com/openbudgetfun/solana_kit/pull/204)

### 🐛 Fixed

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

## solana_kit_mpl_bubblegum [0.4.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mpl_bubblegum/v0.4.1) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_mpl_bubblegum` was updated to 0.4.1.

## solana_kit_mpl_bubblegum [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mpl_bubblegum/v0.5.0) (2026-08-30)

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
