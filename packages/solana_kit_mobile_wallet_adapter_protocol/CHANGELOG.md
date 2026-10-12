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

## solana_kit_mobile_wallet_adapter_protocol [0.5.3](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mobile_wallet_adapter_protocol/v0.5.3) (2026-09-12)

### Changed

- **No package-specific changes were recorded; `solana_kit_mobile_wallet_adapter_protocol` was updated to 0.5.3.**

## solana_kit_mobile_wallet_adapter_protocol [0.6.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mobile_wallet_adapter_protocol/v0.6.0) (2026-09-21)

### Breaking changes

#### Raise the Dart and Flutter baseline

The workspace now builds against Dart 3.13.3 and Flutter 3.47.4, and every package declares that floor instead of the previous Dart 3.12 range. Consumers on older SDKs can no longer resolve these packages, so this release is breaking even though no Dart API changed.

The Flutter floor rises from 3.44 to 3.47 for `solana_kit_mobile_wallet_adapter`, `solana_kit_mobile_wallet_adapter_protocol`, and `solana_kit_wallet_adapter`, matching the floor `solana_kit_wallet_ui` already required. `solana_kit_lints` ships the raised floor to consumers, so it carries the same breaking bump. Every other package raises only the Dart SDK floor.

Raising the language version also switches `dart format` to the tall style, so 83 files across library, test, script, and Codama-generated trees are reflowed. The renderer pipes generated output through `dart format`, so regenerating stays consistent.

Align your own SDK constraint with the workspace:

```yaml
environment:
  sdk: ^3.13.0
  # Omit for pure Dart packages; required for the Flutter packages above.
  flutter: ">=3.47.0"
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [5f5fe01](https://github.com/openbudgetfun/solana_kit/commit/5f5fe01f3e2220ccfee54cc26e82c3face26589d) · _Last updated in:_ [19932db](https://github.com/openbudgetfun/solana_kit/commit/19932dba1979f1190b7501947b87eb8a4d4cc8d5)

## solana_kit_mobile_wallet_adapter_protocol [0.7.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mobile_wallet_adapter_protocol/v0.7.0) (2026-10-12)

### Fixes

- **Monostyle style pass.** Blank-line breathing room around control flow and returns, group splits, and collapsed blank runs, applied by `monostyle fix` and kept where dprint puts them. No behavior change: the renderers' emitted code and every package's API are untouched. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #283](https://github.com/openbudgetfun/solana_kit/pull/283)

#### Clear MWA session secrets on close and validate parsed association URIs

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #291](https://github.com/openbudgetfun/solana_kit/pull/291)

Closing a local or remote Mobile Wallet Adapter session now zeroes the AES session key (`Uint8List.fillRange`) and releases the handshake keypair references, so session secrets no longer outlive the session object. The P-256 private scalars live inside PointyCastle `BigInt`s, which Dart cannot zero deterministically, so only their references are dropped — the limitation stays documented in the workspace security policy.

`parseAssociationUri` now runs the same validators the URI builder uses: a crafted local association URI with a port outside the RFC 6335 dynamic range (49152-65535) or a reflector ID above 2^53-1 is rejected with the existing typed MWA errors instead of silently accepted, and the Android wallet bridge no longer reinterprets malformed base64 payloads as raw UTF-8 bytes — a corrupt address or auth token now fails the request instead of becoming a plausible-looking value.

### Documentation

- **Track `@solana-mobile/mobile-wallet-adapter-protocol-kit` `3.0.0`.** The reference pin shared by the Mobile Wallet Adapter packages advances to `@solana-mobile/mobile-wallet-adapter-protocol-kit@3.0.0`. Upstream's 3.0.0 majors are JavaScript packaging changes (ESM-only build, `@solana/kit` 8 peer range, version-group realignment) with no Dart counterpart; the transport behavior this package implements was already equivalent to the upstream 3.0.0 runtime fixes. See `docs/agents/upstream-audit-solana_kit_mobile_wallet_adapter-v3.0.0.md`. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #300](https://github.com/openbudgetfun/solana_kit/pull/300) · _Related issues:_ [#1640](https://github.com/openbudgetfun/solana_kit/issues/1640), [#1659](https://github.com/openbudgetfun/solana_kit/issues/1659), [#1715](https://github.com/openbudgetfun/solana_kit/issues/1715), [#1716](https://github.com/openbudgetfun/solana_kit/issues/1716), [#299](https://github.com/openbudgetfun/solana_kit/issues/299)

#### Publish a per-package upstream support table in each package README

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #285](https://github.com/openbudgetfun/solana_kit/pull/285) · _Related issues:_ [#223](https://github.com/openbudgetfun/solana_kit/issues/223), [#284](https://github.com/openbudgetfun/solana_kit/issues/284)

Every package that ports something outside `@solana/kit` now documents which upstream revision each of its releases was generated and verified against, so a reader can pick the Dart version that matches the upstream program version they target.

```markdown
| `solana_kit_system` version | `system`     | Released                |
| --------------------------- | ------------ | ----------------------- |
| _next release_              | `js@v0.15.0` | _unreleased_            |
| `0.7.2` – `0.8.0`           | `js@v0.14.1` | 2026-09-06 – 2026-09-21 |
| `0.7.0` – `0.7.1`           | `js@v0.14.0` | 2026-08-30              |
```

**One row per upstream revision, not per release.** Consecutive releases that were generated against the same upstream ref collapse into a single `0.7.2` – `0.8.0` range, so a package that shipped several patches against one upstream tag reports one row instead of burying the mapping in repetition. Packages whose releases moved with the umbrella `solana_kit` version (the lockstep group members) are keyed by that version and label the column accordingly.

The leading `_next release_` row shows the pin the working tree is currently generated against, so the mapping for unreleased work is visible before the release tooling assigns a version.

Tables are generated, not hand-written. `scripts/sync_package_upstream_support.dart` reads `config/reference-repos.json` at every `"<package>/v<version>"` release tag, collapses the ranges, and writes `config/package-upstream-support.json`; `scripts/generate_upstream_docs.dart` renders that into each README between `upstream-support` markers. Both run through `docs:update`, so the tables refresh alongside the other generated docs. The history is committed rather than derived at check time because CI checks out shallowly and would see no tags.

No package code changes; this is documentation only.
