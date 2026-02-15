# Research: Solana Kit Dart SDK — Full Port

**Branch**: `001-solana-kit-port` | **Date**: 2026-02-15

## R1: Package Mapping (TS → Dart)

**Decision**: 37 Dart packages map to 37 of the 55 upstream TS packages. 18 TS
packages are excluded (JS-specific, build tooling, or Dart-native equivalents).

**Rationale**: The 18 excluded packages fall into clear categories:
- **JS polyfills** (9): crypto-impl, text-encoding-impl, event-target-impl,
  fetch-impl, ws-impl, webcrypto-ed25519-polyfill, assertions, promises,
  nominal-types — Dart has native equivalents for all of these.
- **Build tooling** (5): build-scripts, eslint-config, test-config, tsconfig —
  replaced by Dart workspace config and solana_kit_lints.
- **JS-specific** (2): react (React hooks), compat (web3.js legacy).
- **Plugin system** (2): plugin-core, plugin-interfaces — deferred; Dart
  mixins/extensions provide equivalent extensibility.
- **Out of scope** (1): rpc-graphql.
- **Merged** (1): rpc-subscriptions-spec folded into rpc_subscriptions.

**Alternatives**: Porting all 55 was rejected (18 are JS-specific or private).
The plugin system may be added later as a separate feature if demand exists.

## R2: Ed25519 Cryptography

**Decision**: Use `cryptography` package (^2.9.0) for Ed25519 operations.

**Rationale**: Production-proven in espresso-cash. Pure Dart fallback works on
all platforms (CLI, Flutter mobile/web/desktop). Optional native acceleration
via `cryptography_flutter` for Flutter apps (50x faster on mobile/desktop,
100x on web via Web Crypto API). Active maintenance by terrier989.

**Alternatives**:
- `pinenacl`: TweetNaCl port, older API, less maintained.
- `ed25519_edwards`: Basic Go port, minimal API, stale.
- Custom: Too much effort for signing; espresso-cash still uses custom code
  only for Curve25519 point validation (PDA derivation).

## R3: Base58 Encoding

**Decision**: Custom implementation in solana_kit_addresses, adapted from
espresso-cash's production code (itself ported from Bitcoin's C++ base58).

**Rationale**: ~35 lines for encode and ~35 for decode. Zero external
dependencies. Battle-tested in espresso-cash production. Available packages
(`bs58`) are minimally maintained.

**Alternatives**: `bs58` package rejected (stale, last update 2+ years ago).

## R4: SHA-256 Hashing

**Decision**: Use `crypto` package (^3.0.0) from dart-lang.

**Rationale**: Official Dart SDK package. Simple API (`sha256.convert(bytes)`).
Excellent maintenance. For higher-performance needs (web), the `cryptography`
package (already a dependency for Ed25519) also provides SHA-256 with Web Crypto
API acceleration.

**Alternatives**: Using only `cryptography` for hashing was considered but
`crypto` is simpler and universally used.

## R5: HTTP Transport

**Decision**: Use `http` package (^1.6.0) for RPC HTTP transport.

**Rationale**: Official dart-lang package. Cross-platform (CLI, Flutter, web).
Lightweight — appropriate for an SDK library. Used by espresso-cash for Solana
RPC. Simple composable API ideal for JSON-RPC 2.0.

**Alternatives**: `dio` rejected (too heavy for SDK library; interceptors/
transformers unnecessary). `dart:io HttpClient` rejected (not cross-platform).

## R6: WebSocket Transport

**Decision**: Use `web_socket_channel` package (^3.0.3) for subscription
transport.

**Rationale**: Official dart-lang package (part of dart-lang/http monorepo).
Cross-platform abstraction over dart:io and dart:html WebSockets. StreamChannel
API integrates naturally with Dart async patterns. Used by espresso-cash.

**Alternatives**: Raw `dart:io WebSocket` rejected (not cross-platform).

## R7: BigInt Handling

**Decision**: Use Dart native `BigInt` for u64/u128 values. Use `int` for
values guaranteed < 2^53 (array lengths, indices, counts).

**Rationale**: Dart's `BigInt` provides arbitrary precision on all platforms.
On web, `int` is only 53-bit precision, so any Solana numeric type (u64, u128,
lamports, token amounts) MUST use `BigInt`. On native, `int` is 64-bit but
`BigInt` ensures cross-platform correctness.

**Alternatives**: No external package needed. Dart's native BigInt is sufficient.

## R8: Typed Data / Byte Manipulation

**Decision**: Use `dart:typed_data` (built-in) for `Uint8List`, `ByteData`.
Add `typed_data` package for `Uint8Buffer` (growable buffers) if needed.

**Rationale**: `dart:typed_data` is part of the Dart SDK. Provides all core
byte manipulation types. The `typed_data` package adds utilities but may not
be needed if growable buffers aren't required.

## R9: Testing Framework

**Decision**: Use `package:test` (^1.25.0+) for all packages.

**Rationale**: Official Dart testing framework. Correct choice for pure Dart
SDK packages (no Flutter dependency). Used by espresso-cash for their Solana
package. `flutter_test` is only for widget testing.

## R10: Pub.dev Publishing Strategy

**Decision**: Synchronized versioning starting at 0.1.0, caret constraints for
inter-package dependencies, melos for dependency-order publishing.

**Rationale**:
- **Caret constraints** (`^0.1.0`): Standard pub.dev practice. Allows compatible
  updates without being too restrictive.
- **Melos publish**: Automatically determines dependency-order publishing for
  all 37 packages. Supports dry-run validation.
- **Synchronized 0.1.0**: Simplifies initial release. All packages start at same
  version, clearly signaling pre-release status.

**Key pub.dev requirements per package**:
- `pubspec.yaml`: name, description, version, environment.sdk
- `readme.md` (per our lowercase convention)
- `changelog.md` (generated by knope)
- `LICENSE` file
- Remove `resolution: workspace` before publishing
- Add caret version constraints to inter-package deps

**37-package concerns**:
- No namespace reservation on pub.dev (first-come first-served) — publish early.
- No documented rate limits for bulk publishing.
- Each package scored independently — small focused packages can score well.
- Verified publisher recommended for trust.
- Pre-validate with `pana` tool before publishing.

**Knope vs Melos for versioning**: Knope manages changesets and version bumps.
Melos handles workspace-aware publishing. Use both: knope for version management,
melos for publishing execution.

## R11: Implementation Order

**Decision**: Bottom-up dependency-order implementation across 9 layers.

```
Layer 0 — Foundation (already done: errors, lints)
  + functional, fast_stable_stringify

Layer 1 — Core Codecs
  codecs_core → codecs_numbers, codecs_strings
  → codecs_data_structures → options → codecs (umbrella)

Layer 2 — Addresses & Keys
  addresses → keys

Layer 3 — RPC Foundation
  rpc_spec_types → rpc_types, rpc_spec
  → rpc_parsed_types, rpc_transformers, rpc_transport_http

Layer 4 — Instructions & Programs
  instructions, programs

Layer 5 — Messages
  transaction_messages, offchain_messages

Layer 6 — Transactions & Signers
  transactions → signers, subscribable

Layer 7 — RPC Complete
  rpc_api → rpc
  rpc_subscriptions_api → rpc_subscriptions_channel_websocket
  → rpc_subscriptions

Layer 8 — High-Level
  accounts, sysvars, instruction_plans,
  program_client_core, transaction_confirmation

Layer 9 — Finalization
  test_matchers, solana_kit (umbrella)
```

## R12: TS Source/Test File Counts (Key Packages)

| Package | TS Source Files | TS Test Files |
|---------|----------------|---------------|
| errors | 13 | 9 |
| codecs_core | 17 | 28 |
| codecs_data_structures | 21 | 38 |
| codecs_numbers | 17 | 15 |
| codecs_strings | 10 | 8 |
| addresses | 7 | 6 |
| keys | 10 | 10 |
| signers | 22 | 33 |
| transactions | 15 | 17 |
| transaction_messages | 38 | 22 |
| rpc_api | 107 | 61 |
| rpc_types | 20 | 11 |
| rpc_subscriptions_api | 11 | 21 |
| offchain_messages | 26 | 11 |
| **Total (all 36 ported)** | **~500+** | **~380+** |
