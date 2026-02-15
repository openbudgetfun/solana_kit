# Implementation Plan: Solana Kit Dart SDK — Full Port

**Branch**: `001-solana-kit-port` | **Date**: 2026-02-15 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-solana-kit-port/spec.md`

## Summary

Port all 37 packages of the Solana Kit Dart SDK from the upstream `@solana/kit`
TypeScript SDK, achieving full feature parity. Implementation follows a bottom-up
dependency order across 9 layers, starting from the already-implemented foundation
(errors, lints) through codecs, addresses, keys, RPC, transactions, signers, and
the umbrella package. Each package includes a comprehensive test suite ported from
the TS SDK's 380+ test files. A publishing guide documents the process for
releasing all 37 packages to pub.dev.

## Technical Context

**Language/Version**: Dart 3.10+ (pinned via `.fvmrc`)
**Primary Dependencies**: `cryptography` (Ed25519), `crypto` (SHA-256), `http`
(RPC transport), `web_socket_channel` (subscriptions), `typed_data` (byte buffers)
**Storage**: N/A (SDK library, no persistent storage)
**Testing**: `package:test` via `melos test` across all packages
**Target Platform**: All Dart platforms (CLI/server, Flutter mobile/web/desktop)
**Project Type**: Dart monorepo with 37 packages under `packages/`
**Performance Goals**: Byte-identical codec output vs upstream TS SDK; no
measurable regression vs native Dart operations
**Constraints**: No code generation, no `dynamic` types, `const` constructors
wherever possible, pure Dart (no Flutter SDK dependency at package level)
**Scale/Scope**: 37 packages, ~500 source files, ~380 test files to port

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Faithful Port | PASS | 37 packages mirror upstream 1:1; API contracts in contracts/ |
| II. Modern Dart, No Codegen | PASS | All types hand-written; Dart 3.10+ features (sealed classes, extension types) |
| III. Package Independence | PASS | 37 independent packages with own pubspec, analysis, barrel exports |
| IV. Type Safety | PASS | No `dynamic`; `Object?` where needed; `const` constructors; `very_good_analysis` |
| V. Test-Driven Quality | PASS | 380+ TS test files serve as baseline; ported per package |
| VI. Changeset Discipline | PASS | Each implementation PR includes changeset files |
| VII. Emoji Conventional Commits | PASS | PR titles follow `EMOJI TYPE(SCOPE): description` |

No violations. Complexity Tracking section not needed.

## Project Structure

### Documentation (this feature)

```text
specs/001-solana-kit-port/
├── plan.md                              # This file
├── spec.md                              # Feature specification
├── research.md                          # Phase 0: research findings
├── data-model.md                        # Phase 1: entity model
├── quickstart.md                        # Phase 1: developer quickstart
├── contracts/
│   └── package-api-surface.md           # Phase 1: public API contracts
├── checklists/
│   └── requirements.md                  # Spec quality checklist
└── tasks.md                             # Phase 2: task breakdown (via /speckit.tasks)
```

### Source Code (repository root)

```text
packages/
├── solana_kit/                          # Umbrella re-export package
│   ├── lib/solana_kit.dart
│   ├── pubspec.yaml
│   └── analysis_options.yaml
├── solana_kit_errors/                   # IMPLEMENTED — foundation
│   ├── lib/
│   │   ├── solana_kit_errors.dart       # Barrel export
│   │   └── src/                         # 11 source files
│   └── test/                            # 7 test files
├── solana_kit_lints/                    # IMPLEMENTED — shared lint rules
│   └── lib/analysis_options.yaml
├── solana_kit_codecs_core/              # Core codec interfaces
│   ├── lib/
│   │   ├── solana_kit_codecs_core.dart
│   │   └── src/                         # ~17 source files (to port)
│   └── test/                            # ~28 test files (to port)
├── solana_kit_addresses/                # Base58 addresses, PDAs
│   ├── lib/
│   │   ├── solana_kit_addresses.dart
│   │   └── src/
│   └── test/
├── solana_kit_keys/                     # Ed25519 key pairs
│   ├── lib/
│   │   ├── solana_kit_keys.dart
│   │   └── src/
│   └── test/
├── solana_kit_rpc_api/                  # 40+ typed RPC methods
│   ├── lib/
│   │   ├── solana_kit_rpc_api.dart
│   │   └── src/                         # ~107 source files (largest package)
│   └── test/                            # ~61 test files
└── ... (32 more packages, same structure)
```

**Structure Decision**: Dart workspace monorepo. Each of the 37 packages follows
the standard Dart package layout (`lib/`, `lib/src/`, `test/`, `pubspec.yaml`,
`analysis_options.yaml`). No nested directories — all packages are flat under
`packages/`. This mirrors the upstream TS SDK structure.

## Implementation Layers

Implementation proceeds bottom-up through the dependency graph. Each layer can
only begin after all packages in the previous layer are complete.

### Layer 0: Foundation (2 packages — ALREADY DONE)

- `solana_kit_errors` — 200+ error codes, SolanaError class, RPC/instruction/
  transaction error mapping. **IMPLEMENTED with 7 test files.**
- `solana_kit_lints` — Shared lint rules extending `very_good_analysis`.
  **IMPLEMENTED.**

### Layer 1: Foundation Utilities (2 packages)

- `solana_kit_functional` — `pipe()` function for composable transforms.
  ~2 source files, ~2 test files from TS.
- `solana_kit_fast_stable_stringify` — Deterministic JSON stringification.
  ~1 source file, ~2 test files from TS.

### Layer 2: Core Codecs (6 packages)

The most complex layer by file count. Port order within layer:

1. `solana_kit_codecs_core` — Codec/Encoder/Decoder interfaces, composition
   utilities, byte helpers. ~17 source files, ~28 test files.
2. `solana_kit_codecs_numbers` — u8–u128, i8–i128, f32, f64, shortU16.
   ~17 source files, ~15 test files.
3. `solana_kit_codecs_strings` — utf8, base58, base64, base16, base10, baseX.
   ~10 source files, ~8 test files.
4. `solana_kit_codecs_data_structures` — struct, array, tuple, map, set, enum,
   union, bool, nullable, bitArray. ~21 source files, ~38 test files.
5. `solana_kit_options` — Option<T> type (Some/None) with codec.
   ~6 source files, ~5 test files.
6. `solana_kit_codecs` — Umbrella re-exporting all codec packages.
   ~1 source file, ~0 test files.

### Layer 3: Addresses & Keys (2 packages)

1. `solana_kit_addresses` — Address extension type, base58 codec, PDA
   computation, isOnCurve validation. Depends on codecs_core, codecs_strings,
   errors. ~7 source files, ~6 test files.
2. `solana_kit_keys` — Ed25519 key generation, signing, verification. Depends
   on addresses, codecs_core, errors. Uses `cryptography` package.
   ~10 source files, ~10 test files.

### Layer 4: RPC Foundation (6 packages)

1. `solana_kit_rpc_spec_types` — RpcRequest, RpcResponse, RpcPlan types.
   ~7 source files, ~3 test files.
2. `solana_kit_rpc_types` — Commitment, Lamports, Blockhash, AccountInfo types.
   ~20 source files, ~11 test files.
3. `solana_kit_rpc_spec` — createJsonRpcApi, Rpc<T>, RpcTransport interface.
   ~4 source files, ~6 test files.
4. `solana_kit_rpc_parsed_types` — Parsed account types (token, stake, vote).
   ~10 source files, ~8 test files.
5. `solana_kit_rpc_transformers` — Request/response transformers, BigInt
   upcast/downcast. ~16 source files, ~7 test files.
6. `solana_kit_rpc_transport_http` — HTTP transport using `http` package.
   ~9 source files, ~10 test files.

### Layer 5: Instructions & Programs (2 packages)

1. `solana_kit_instructions` — IInstruction, IAccountMeta, AccountRole.
   ~4 source files, ~2 test files.
2. `solana_kit_programs` — isProgramError, getProgramErrorMessage.
   ~2 source files, ~2 test files.

### Layer 6: Messages (2 packages)

1. `solana_kit_transaction_messages` — TransactionMessage creation, compilation,
   decompilation, blockhash/nonce lifetime, fee payer. Largest non-RPC package.
   ~38 source files, ~22 test files.
2. `solana_kit_offchain_messages` — Offchain message v0/v1 encoding/decoding.
   ~26 source files, ~11 test files.

### Layer 7: Transactions & Signers (3 packages)

1. `solana_kit_transactions` — Transaction compilation, signing, wire format,
   size calculation. ~15 source files, ~17 test files.
2. `solana_kit_signers` — Signer abstraction hierarchy (partial, modifying,
   sending), KeyPairSigner, NoopSigner. ~22 source files, ~33 test files.
3. `solana_kit_subscribable` — DataPublisher, async iterable helpers.
   ~5 source files, ~5 test files.

### Layer 8: RPC Complete (5 packages)

1. `solana_kit_rpc_api` — All 40+ Solana RPC method definitions. **Largest
   package** by file count. ~107 source files, ~61 test files.
2. `solana_kit_rpc` — createSolanaRpc, cluster URLs, integer overflow handling.
   ~8 source files, ~6 test files.
3. `solana_kit_rpc_subscriptions_api` — All subscription method definitions.
   ~11 source files, ~21 test files.
4. `solana_kit_rpc_subscriptions_channel_websocket` — WebSocket channel using
   `web_socket_channel`. ~3 source files, ~3 test files.
5. `solana_kit_rpc_subscriptions` — createSolanaRpcSubscriptions, autopinger,
   coalescer. ~14 source files, ~9 test files.

### Layer 9: High-Level (5 packages)

1. `solana_kit_accounts` — fetchEncodedAccount, decodeAccount, parseAccount.
   ~10 source files, ~9 test files.
2. `solana_kit_sysvars` — Clock, EpochSchedule, Rent, etc.
   ~13 source files, ~12 test files.
3. `solana_kit_instruction_plans` — InstructionPlan, TransactionPlan, execution.
   ~8 source files, ~15 test files.
4. `solana_kit_program_client_core` — Base program client utilities.
   ~5 source files, ~7 test files.
5. `solana_kit_transaction_confirmation` — Confirmation strategies (blockheight,
   nonce, signature, timeout). ~10 source files, ~9 test files.

### Layer 10: Finalization (2 packages)

1. `solana_kit_test_matchers` — Dart test matchers for Solana-specific
   assertions. ~2 source files.
2. `solana_kit` — Umbrella package re-exporting all 36 other packages.
   ~1 source file.

## Key Technical Decisions

### TS → Dart Language Mapping

| TypeScript Feature | Dart Equivalent |
|-------------------|-----------------|
| Branded/nominal types | Extension types |
| Discriminated unions | Sealed classes |
| `bigint` | `BigInt` |
| `Uint8Array` | `Uint8List` |
| `Promise<T>` | `Future<T>` |
| Generic type constraints | Generic type constraints (same) |
| `readonly` arrays | `UnmodifiableListView` or immutable patterns |
| Template literal types | Not applicable (runtime validation) |
| Overloaded function signatures | Named constructors or optional parameters |

### Dependency Versions (External)

| Package | Version | Used By |
|---------|---------|---------|
| `cryptography` | ^2.9.0 | keys, addresses (Ed25519) |
| `crypto` | ^3.0.0 | addresses (SHA-256 for PDAs) |
| `http` | ^1.6.0 | rpc_transport_http |
| `web_socket_channel` | ^3.0.3 | rpc_subscriptions_channel_websocket |
| `typed_data` | ^1.4.0 | codecs_core (Uint8Buffer) |
| `test` | ^1.25.0 | All packages (dev_dependency) |
| `very_good_analysis` | ^7.0.0 | solana_kit_lints |

### Publishing Preparation

Before first publish, each package needs:
1. `readme.md` with usage examples
2. `changelog.md` (generated by knope on release)
3. `LICENSE` file (symlink or copy from root)
4. Remove `resolution: workspace` from pubspec.yaml
5. Add caret version constraints (`^0.1.0`) to inter-package deps
6. Run `pana` locally to validate pub.dev score
7. Ensure `>=20%` of public API has doc comments

Publishing order is handled by `melos publish` which respects the dependency
graph automatically.

## Per-Package PR Strategy

Each package (or small group of related packages) is implemented as a separate PR:
- PR title: `✨ feat(package_name): description`
- Includes changeset file in `.changeset/`
- Must pass all 6 CI checks
- Tests ported alongside implementation (not as separate PRs)

For Layer 2 (codecs), the 6 packages may be split into 2-3 PRs to keep
review size manageable:
1. codecs_core + codecs_numbers
2. codecs_strings + codecs_data_structures
3. options + codecs umbrella
