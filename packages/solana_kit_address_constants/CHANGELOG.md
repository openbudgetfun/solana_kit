# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.9.2](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.2) (2026-09-06)

### Changed

- No package-specific changes were recorded; `solana_kit_address_constants` was updated to 0.9.2 as part of group `main`.

## [0.9.1](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_address_constants` was updated to 0.9.1 as part of group `main`.

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_address_constants` was updated to 0.9.0 as part of group `main`.

## [0.8.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.8.0) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_address_constants` was updated to 0.8.0 as part of group `main`.

## [0.7.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.7.0) (2026-08-18)

### 💥 Breaking Change

#### @solana/kit v7.0.0 upstream sync (foundational breaking changes)

Ports the foundational breaking changes from `@solana/kit` v7.0.0:

- **solana_kit_errors**: new `transactionIntrospection` error domain + codes (`transactionFailedToDecompileInstructionAccountIndexOutOfRange`, `transactionIntrospectionCannotDecodeJsonParsedTransaction`, `transactionIntrospectionUnrecognizedGetTransactionResponse`) and instruction-plans max-instructions codes (`instructionPlansInvalidMaxInstructionsPerTransaction`, `instructionPlansMaxInstructionsPerTransactionExceeded`).
- **solana_kit_codecs_data_structures**: `createDependentStructDecoder` fluent builder for structs whose later fields depend on earlier decoded values.
- **solana_kit_instruction_plans**: configurable `maxInstructionsPerTransaction` (default 16, limit 64) on `TransactionPlannerConfig`, individual `TransactionPlanner` invocations, and `MessagePacker`; invocation-specific planner values take precedence without leaking to later calls.
- **solana_kit_rpc_types**: `isSolanaRpcResponse` runtime guard.
- **solana_kit**: removed the local `getMinimumBalanceForRentExemption` helper (rent exemption is becoming dynamic; use the RPC method instead).
- **solana_kit_subscribable**: `ReactiveStreamStore` v7 rewrite — caller-driven `connect()`/`reset()`/`withSignal()`, starts `idle`, collapses `retrying` into `loading` (stale-while-revalidate), renames `getUnifiedState()` → `getState()`; removed `retry()`, value-only `getState()`, `getError()`. `ReactiveActionStore` now passes a fresh `CancellationToken` to every action, cancels superseded/reset/disposed dispatches, suppresses late outcomes, exposes caller cancellation through `withSignal()`, and preserves stale results and errors while running.
- **solana_kit_transaction_introspection**: new first-class package porting `@solana/transaction-introspection` — RPC transaction decoding, instruction and inner-instruction extraction, loaded-address resolution, and instruction walking helpers; re-exported from the `solana_kit` umbrella.
- **solana_kit_rpc_parsed_types** / **solana_kit_rpc_transformers** / **solana_kit_rpc_api**: Agave 4.1.0 parsed-account types — vote commissions/latency as `int` (not `BigInt`); rent sysvar union (`lamportsPerByte` vs deprecated `burnPercent`/`exemptionThreshold`/ `lamportsPerByteYear`); stake `warmupCooldownRate` optional; config `slashPenalty`/`warmupCooldownRate` deprecated; keep vote commissions and latency as `int` in the numeric-keypath allow-lists.

Migration: `getMinimumBalanceForRentExemption(space)` → `rpc.getMinimumBalanceForRentExemption(space).send()`; `store.retry()` → `store.connect()`; `store.getUnifiedState()` → `store.getState()`; the deprecated `ReactiveStore`/`createReactiveStoreFromStreams` → `createReactiveStreamStore`; reactive actions must migrate from `(args) async => result` to `(signal, args) async => result`.

```dart
// Before
final lamports = getMinimumBalanceForRentExemption(space);
store.retry();
final state = store.getUnifiedState();

// After
final lamports = await rpc.getMinimumBalanceForRentExemption(space).send();
store.connect();
final state = store.getState();
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

## [0.6.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.6.0) (2026-08-12)

### 🐛 Fixed

#### Add Subscriptions program client

Adds a generated Subscriptions program client pinned to `solana-foundation/subscriptions` `ts-client-v0.3.0`, including account, instruction, PDA, type, and error helpers.

Also exposes the canonical Subscriptions program address from `solana_kit_address_constants`.

```dart
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';

Future<void> main() async {
  const user = Address('11111111111111111111111111111112');
  const tokenMint = Address('So11111111111111111111111111111111111111112');

  final (authority, bump) = await findSubscriptionAuthorityPda(
    programAddress: subscriptionsProgramAddress,
    seeds: SubscriptionAuthoritySeeds(user: user, tokenMint: tokenMint),
  );

  print('authority=$authority bump=$bump');
}
```

Build typed instructions for fixed and recurring delegations.

```dart
final instruction = getCreateFixedDelegationInstruction(
  programAddress: subscriptionsProgramAddress,
  delegator: delegator,
  subscriptionAuthority: subscriptionAuthority,
  delegationAccount: delegationAccount,
  delegatee: delegatee,
  systemProgram: systemProgram,
  fixedDelegation: CreateFixedDelegationData(
    nonce: BigInt.from(1),
    amount: BigInt.from(1_000_000),
    expiryTs: BigInt.zero,
    expectedSubscriptionAuthorityInitId: BigInt.zero,
  ),
);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #187](https://github.com/openbudgetfun/solana_kit/pull/187)

### 📖 Documentation

#### Centralize package version documentation

Centralize package version metadata in `versions.json` and render package installation snippets from the shared MDT data source. Published package behavior is unchanged.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #188](https://github.com/openbudgetfun/solana_kit/pull/188)

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)

## [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.5.0) (2026-06-01)

### 💥 Breaking Change

#### New `solana_kit_address_constants` package

Initial release of `solana_kit_address_constants` — well-known address constants for native programs, sysvars, SPL programs, Metaplex programs, and token mints extracted from `solana_kit_addresses`.

```dart
import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';

final address = systemProgramAddress; // native program
final sysvar = clockSysvarAddress;   // sysvar
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`3f596ef`](https://github.com/openbudgetfun/solana_kit/commit/3f596ef95c0d00714db97a4338ac9342f1fabfb7) · _Last updated in:_ [`249e14e`](https://github.com/openbudgetfun/solana_kit/commit/249e14e1d2976cca8b407d1fda3ac57104104ce4)

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

## 0.0.0

Initial release of `solana_kit_address_constants` — well-known address constants for native programs, sysvars, SPL programs, Metaplex programs, and token mints extracted from `solana_kit_addresses`.
