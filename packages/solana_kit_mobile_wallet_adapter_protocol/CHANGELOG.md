# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_mobile_wallet_adapter_protocol [0.3.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mobile_wallet_adapter_protocol/v0.3.2) (2026-05-30)

### 🚀 Feature

#### Detached from main group

These packages are now released independently rather than as part of the main solana_kit group. The Mobile Wallet Adapter packages target Flutter mobile platforms and are not tightly coupled to the core solana_kit release cycle, so an independent release track is more appropriate.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

## solana_kit_mobile_wallet_adapter_protocol [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mobile_wallet_adapter_protocol/v0.4.0) (2026-06-01)

### 💥 Breaking Change

#### Raise minimum Dart SDK to 3.12

Raise the minimum supported Dart SDK constraint to `^3.12.0` across public Dart packages.

This is a breaking change because consumers must use Dart 3.12 or newer. Flutter consumers must use a Flutter SDK that bundles Dart 3.12 or newer.

```yaml
environment:
  sdk: ^3.12.0
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`32d5d36`](https://github.com/openbudgetfun/solana_kit/commit/32d5d367abb7615fea5ee341f03d17c2bc0d66dd)

## solana_kit_mobile_wallet_adapter_protocol [0.4.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mobile_wallet_adapter_protocol/v0.4.1) (2026-06-03)

### 🐛 Fixed

#### Harden security audit findings

Disable placeholder Helius auth signing, redact Helius API keys from JSON-RPC error context, validate malformed encrypted mobile-wallet messages before slicing, and reject negative mobile-wallet sequence numbers.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #181](https://github.com/openbudgetfun/solana_kit/pull/181)

## solana_kit_mobile_wallet_adapter_protocol [0.4.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mobile_wallet_adapter_protocol/v0.4.2) (2026-08-12)

### 🐛 Fixed

#### Harden cryptographic input handling

Harden keypair file writes, validate malformed mobile wallet cryptographic inputs, and update vulnerable renderer test dependencies.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #181](https://github.com/openbudgetfun/solana_kit/pull/181)

### 📖 Documentation

#### Centralize package version documentation

Centralize package version metadata in `versions.json` and render package installation snippets from the shared MDT data source. Published package behavior is unchanged.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #188](https://github.com/openbudgetfun/solana_kit/pull/188)

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)

## solana_kit_mobile_wallet_adapter_protocol [0.4.3](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mobile_wallet_adapter_protocol/v0.4.3) (2026-08-18)

### 🐛 Fixed

#### Harden credentials, keys, transports, and untrusted RPC decoding

Align Helius signup and project provisioning with the v3 bearer-JWT API, generate valid Ed25519 authentication keypairs, validate payment inputs, and redact WebSocket credentials.

Dispose or clear SDK-owned key material deterministically, create key files exclusively with safe POSIX permissions, and preserve caller ownership of Surfpool signers.

Reject malformed RPC transaction and inner-instruction data instead of silently dropping it, expand private WebSocket literal filtering, and update JavaScript dependency overrides to releases without the audited advisories. Make the standalone Codama renderer workspace declare its own build tools and explicitly allow only esbuild's required install script.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #213](https://github.com/openbudgetfun/solana_kit/pull/213) · _Related issues:_ [#159](https://github.com/openbudgetfun/solana_kit/issues/159), [#163](https://github.com/openbudgetfun/solana_kit/issues/163), [#186](https://github.com/openbudgetfun/solana_kit/issues/186), [#198](https://github.com/openbudgetfun/solana_kit/issues/198), [#203](https://github.com/openbudgetfun/solana_kit/issues/203), [#204](https://github.com/openbudgetfun/solana_kit/issues/204), [#205](https://github.com/openbudgetfun/solana_kit/issues/205), [#206](https://github.com/openbudgetfun/solana_kit/issues/206), [#207](https://github.com/openbudgetfun/solana_kit/issues/207), [#208](https://github.com/openbudgetfun/solana_kit/issues/208), [#210](https://github.com/openbudgetfun/solana_kit/issues/210), [#211](https://github.com/openbudgetfun/solana_kit/issues/211), [#34](https://github.com/openbudgetfun/solana_kit/issues/34), [#37](https://github.com/openbudgetfun/solana_kit/issues/37)

### 📖 Documentation

#### Reformat package docs

Docs have been reformatted to remove line wrapping.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #212](https://github.com/openbudgetfun/solana_kit/pull/212)

## solana_kit_mobile_wallet_adapter_protocol [0.4.4](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mobile_wallet_adapter_protocol/v0.4.4) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_mobile_wallet_adapter_protocol` was updated to 0.4.4.

## solana_kit_mobile_wallet_adapter_protocol [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mobile_wallet_adapter_protocol/v0.5.0) (2026-08-30)

### 📖 Documentation

#### Unslop package docs and code comments

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)

## solana_kit_mobile_wallet_adapter_protocol [0.5.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mobile_wallet_adapter_protocol/v0.5.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_mobile_wallet_adapter_protocol` was updated to 0.5.1.

## solana_kit_mobile_wallet_adapter_protocol [0.5.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mobile_wallet_adapter_protocol/v0.5.2) (2026-09-06)

### 🐛 Fixed

#### Preserve wallet association endpoint paths

Preserve wallet-specific base URI path prefixes regardless of trailing slash. Identify local and remote associations by their endpoint suffix rather than substrings in wallet path prefixes, and reject unrelated paths.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Validate P-256 points before wallet key agreement

Reject malformed P-256 public points and mismatched curve parameters before wallet session key agreement. Validate imported public keys against the curve equation so invalid points cannot produce predictable shared secrets.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Reject SIWS field and resource line injection

Reject carriage returns and newlines in every Sign In With Solana field and resource before constructing the message to sign. This prevents embedded line breaks from changing field boundaries or adding unintended signed resources.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)
