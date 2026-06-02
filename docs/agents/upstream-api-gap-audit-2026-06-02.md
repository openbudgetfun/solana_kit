# Upstream API gap audit — 2026-06-02

Scope: all packages in this workspace compared with configured upstream references under `.repos/`, excluding `solana_kit_helius` because PR #183 is already covering that package.

## Production TODO / unimplemented markers

No production `lib/` APIs currently throw `UnimplementedError` or contain active `TODO` / `FIXME` implementation markers. Matches are limited to tests, docs describing previously fixed work, lint configuration, or defensive error handling.

## High-priority gaps

### Compute Budget helper layer

Upstream `solana-program/compute-budget` includes non-generated helper APIs in `clients/js/src/introspect.ts`, `setComputeLimit.ts`, `setComputePrice.ts`, and estimation helpers.

Implemented in this branch:

- `findSetComputeUnitLimitInstructionIndexAndUnits`
- `findSetComputeUnitPriceInstructionIndexAndMicroLamports`
- `fillProvisorySetComputeUnitLimitInstruction`
- `setTransactionMessageComputeUnitPrice`
- `updateOrAppendSetComputeUnitLimitInstruction`
- `updateOrAppendSetComputeUnitPriceInstruction`

Remaining:

- RPC-backed `estimateComputeUnitLimitFactory` equivalent.
- RPC-backed `estimateAndSetComputeUnitLimit` equivalent.

These require choosing or adding a stable simulation/RPC abstraction in Dart.

### Core transaction/signing APIs

Against `anza-xyz/kit`, notable missing or partial areas remain:

- Transaction message v0/v1/legacy codec/decompile parity beyond the currently exposed Dart shape.
- Resource/priority-fee helpers that compose compute-budget estimation with transaction messages.
- Signer helpers: grinding keypair signers, off-chain-message signing, keypair persistence helpers.
- Instruction plan error helpers analogous to upstream transaction-plan errors.

### SPL Account Compression

`solana_kit_spl_account_compression` is generated-instruction focused. Upstream/reference surfaces include higher-level account/type/event APIs such as concurrent Merkle tree account helpers, tree header/path/canopy types, and compression events.

### Token / Token-2022 handwritten helpers

Generated instruction parity is good. Remaining work is mostly handwritten helper/plugin parity such as higher-level token client extension APIs and verifying UI amount helpers.

## Program package notes

Generated program-package file parity is mostly complete for:

- system
- token
- token-2022
- address lookup table
- memo
- compute budget generated instructions
- stake
- config

False positives from simple file matching include Dart renames/combined files (`loader_v3.dart`, `loader_v4.dart`, `stake_account.dart`, `config_account.dart`) and package-specific compatibility aliases.

## Suggested implementation order

1. Finish Compute Budget helpers that do not need RPC abstractions. ✅ started in this branch.
2. Add RPC-backed compute estimation once the simulation abstraction is confirmed.
3. Add signer helper gaps.
4. Expand SPL Account Compression account/event helpers.
5. Add higher-level token client helper parity.
