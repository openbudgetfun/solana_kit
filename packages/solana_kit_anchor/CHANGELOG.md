# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.9.2](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.2) (2026-09-06)

### 🐛 Fixed

#### Validate Anchor and Pyth event data

Validate Anchor event provenance against the IDL program's runtime invocation stack, ignoring foreign-program and embedded-message event forgeries. Bound Hermes price conversion work for extreme untrusted exponents to prevent application stalls.

Preserve all 64 bits of unsigned Pyth confidence and slot fields so large confidence intervals cannot become negative and bypass application upper-bound checks.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Restore Anchor runtime error compatibility

Align the standard Anchor error table with `anchor-lang` 0.31.1 so errors returned by deployed Anchor programs resolve to the correct code, name, and message.

Add live Surfpool compatibility coverage for Anchor, Metaplex Core, Metaplex Token Metadata, Squads V4, RPC subscriptions, transaction introspection, lookup tables, instruction plans, and transaction immutability.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #243](https://github.com/openbudgetfun/solana_kit/pull/243)

## [0.9.1](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.1) (2026-08-30)

### 🐛 Fixed

#### Fix publish validation for ecosystem packages

Declare the `meta` and `solana_kit_accounts` dependencies that the generated Squads and mpl-token-metadata clients import, so `dart pub publish` validation passes, and normalize `readme.md` to `README.md` across the ecosystem packages to satisfy the pub README requirement.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`a53391f`](https://github.com/openbudgetfun/solana_kit/commit/a53391f69a4668422096a31bcac46397770a5d33)

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

### 💥 Breaking Change

#### Support Anchor programs in Dart

Add the Anchor runtime package: Anchor sighash discriminators (`sha256("namespace:name")[0..8]`), Anchor IDL 0.30 parsing, a dynamic coder that builds account, instruction, and event codecs from an IDL at runtime, a pure-Dart SHA-256, and Anchor error resolution against the standard table plus program-defined IDL errors. Generic IDL type instantiations are rejected at codec-build time.

```dart
import 'package:solana_kit_anchor/solana_kit_anchor.dart';

final idl = AnchorIdlProgram.parse(idlJson);
final coder = AnchorCoder(idl);
final args = coder.encodeInstructionData('initialize', {
  'authority': authorityAddress,
});
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)
