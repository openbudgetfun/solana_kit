# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_surfpool [0.1.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_surfpool/v0.1.0) (2026-08-12)

### 💥 Breaking Change

#### Add Surfpool SDK package

Adds a new pure-Dart, CLI-backed Surfpool SDK package for starting local Surfnets and using Surfpool cheatcodes from Dart tests. The package intentionally avoids native napi or Flutter Rust Bridge bindings while exposing typed helpers for funding accounts, mutating token state, time travel, and program deployment.

```dart
final surfnet = await Surfnet.start();
try {
  final payer = surfnet.payer;
  await surfnet.fundSol(payer, 1_000_000_000);
} finally {
  await surfnet.stop();
}
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #194](https://github.com/openbudgetfun/solana_kit/pull/194)

## solana_kit_surfpool [0.2.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_surfpool/v0.2.0) (2026-08-18)

### 💥 Breaking Change

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

### 🚀 Feature

#### Isolate each Surfnet's runtime state in its own working directory

`Surfnet.startWithConfig` (and therefore `Surfnet.start`, `createSurfpoolClient`, and the integration-test environment) now runs the `surfpool start` process in a dedicated per-instance temporary working directory instead of the caller's current directory.

The `surfpool` CLI writes its runtime state — log files, validator keypairs, ledger, and other `.surfpool/` files — next to its working directory. When several Surfnets started concurrently (e.g. parallel test files under `test:all`, which runs all packages in one process with up to 12-way concurrency), those instances raced on the shared `.surfpool` directory: one instance's startup cleanup could delete another's freshly-created directory, making `surfpool start` exit with `Failed to create log file
.surfpool/logs/...: unable to create parent directory .surfpool/logs` before the readiness check.

Each instance now gets its own working directory, so concurrent Surfnets can never clobber each other's state. The temporary directory is removed when the instance is stopped (including when startup fails). Artifact discovery for `deployProgram` is unaffected: it still resolves `target/deploy/` from the caller-provided (or current) directory, independent of the process working directory.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #211](https://github.com/openbudgetfun/solana_kit/pull/211)

### 🐛 Fixed

#### Harden credentials, keys, transports, and untrusted RPC decoding

Align Helius signup and project provisioning with the v3 bearer-JWT API, generate valid Ed25519 authentication keypairs, validate payment inputs, and redact WebSocket credentials.

Dispose or clear SDK-owned key material deterministically, create key files exclusively with safe POSIX permissions, and preserve caller ownership of Surfpool signers.

Reject malformed RPC transaction and inner-instruction data instead of silently dropping it, expand private WebSocket literal filtering, and update JavaScript dependency overrides to releases without the audited advisories. Make the standalone Codama renderer workspace declare its own build tools and explicitly allow only esbuild's required install script.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #213](https://github.com/openbudgetfun/solana_kit/pull/213) · _Related issues:_ [#159](https://github.com/openbudgetfun/solana_kit/issues/159), [#163](https://github.com/openbudgetfun/solana_kit/issues/163), [#186](https://github.com/openbudgetfun/solana_kit/issues/186), [#198](https://github.com/openbudgetfun/solana_kit/issues/198), [#203](https://github.com/openbudgetfun/solana_kit/issues/203), [#204](https://github.com/openbudgetfun/solana_kit/issues/204), [#205](https://github.com/openbudgetfun/solana_kit/issues/205), [#206](https://github.com/openbudgetfun/solana_kit/issues/206), [#207](https://github.com/openbudgetfun/solana_kit/issues/207), [#208](https://github.com/openbudgetfun/solana_kit/issues/208), [#210](https://github.com/openbudgetfun/solana_kit/issues/210), [#211](https://github.com/openbudgetfun/solana_kit/issues/211), [#34](https://github.com/openbudgetfun/solana_kit/issues/34), [#37](https://github.com/openbudgetfun/solana_kit/issues/37)

## solana_kit_surfpool [0.2.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_surfpool/v0.2.1) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_surfpool` was updated to 0.2.1.

## solana_kit_surfpool [0.3.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_surfpool/v0.3.0) (2026-08-30)

### 📖 Documentation

#### Unslop package docs and code comments

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)

## 0.0.0

- Initial unpublished package version.
