# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_mobile_wallet_adapter [0.3.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mobile_wallet_adapter/v0.3.2) (2026-05-30)

### 🚀 Feature

#### Detached from main group

These packages are now released independently rather than as part of the main solana_kit group. The Mobile Wallet Adapter packages target Flutter mobile platforms and are not tightly coupled to the core solana_kit release cycle, so an independent release track is more appropriate.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add Android-first Flutter MWA example

Expand the Mobile Wallet Adapter Flutter example into an…

Expand the Mobile Wallet Adapter Flutter example into an Android-first app with explicit platform support gating, wallet session state boundaries, sign-and-send transaction handoff, and clear iOS fallback UX guidance.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`2320606`](https://github.com/openbudgetfun/solana_kit/commit/2320606360e071f308616a15513aeb71f58c82e5) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Update MWA example override metadata

Update the mobile wallet adapter example override…

Update the mobile wallet adapter example override metadata so the example remains aligned with the workspace package graph after the 6.9 compatibility additions.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

## solana_kit_mobile_wallet_adapter [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mobile_wallet_adapter/v0.4.0) (2026-06-01)

### 💥 Breaking Change

#### Raise minimum Dart SDK to 3.12

Raise the minimum supported Dart SDK constraint to `^3.12.0` across public Dart packages.

This is a breaking change because consumers must use Dart 3.12 or newer. Flutter consumers must use a Flutter SDK that bundles Dart 3.12 or newer.

```yaml
environment:
  sdk: ^3.12.0
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`32d5d36`](https://github.com/openbudgetfun/solana_kit/commit/32d5d367abb7615fea5ee341f03d17c2bc0d66dd)

### 🔖 None

#### Update Android compile check command

Update the README maintenance command for the Android compile check to use the Dart project script.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`17fb23f`](https://github.com/openbudgetfun/solana_kit/commit/17fb23fce427bce1dd22b34fea8482ef2278c161)

## solana_kit_mobile_wallet_adapter [0.4.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mobile_wallet_adapter/v0.4.1) (2026-06-03)

### Changed

- No package-specific changes were recorded; `solana_kit_mobile_wallet_adapter` was updated to 0.4.1.

## solana_kit_mobile_wallet_adapter [0.4.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mobile_wallet_adapter/v0.4.2) (2026-07-23)

### 📖 Documentation

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)
