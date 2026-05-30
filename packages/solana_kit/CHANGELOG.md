# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-30)

### 🚀 Feature

#### Trim program exports from umbrella

Remove program-specific package exports from the…

Remove program-specific package exports from the `solana_kit` umbrella package so program clients remain explicit imports.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`8285b34`](https://github.com/openbudgetfun/solana_kit/commit/8285b34dc7b78f04693fc0558b6854a776ad03a2) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add integration tests CI job

Add SurfPool integration test CI job and devenv command for running integration tests.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`7983fb5`](https://github.com/openbudgetfun/solana_kit/commit/7983fb5835a8fc4093fab46317f162da76fc47cc) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add per-package codecov flags

Add Codecov patch coverage and package-level coverage…

Add Codecov patch coverage and package-level coverage flags for Dart and renderer packages.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`30e1d19`](https://github.com/openbudgetfun/solana_kit/commit/30e1d192192800481fbdc6afa57dc1a1fd255986) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Fix duplicate ecosystems.dart section in monochange.toml

Merge duplicate `[ecosystem.dart]` and `[ecosystems.dart]` TOML sections into a single `[ecosystems.dart]` section.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`d5765af`](https://github.com/openbudgetfun/solana_kit/commit/d5765af199ad10b93ff613abe46a942b70205ba1)

#### Deploy docs from main pushes

Deploy the docs site from main pushes instead of…

Deploy the docs site from `main` pushes instead of release-tag events so GitHub Pages deployments comply with the repository's `github-pages` environment branch policy.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`8543d72`](https://github.com/openbudgetfun/solana_kit/commit/8543d72c37cef9f94189c4be9209d57863ebcf88) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add shared test fixtures and coverage gates

Add shared workspace test fixtures plus risk-tier package…

Add shared workspace test fixtures plus risk-tier package coverage gates so high-risk Solana Kit packages stay above 90% line coverage in CI.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`ba96efb`](https://github.com/openbudgetfun/solana_kit/commit/ba96efba2e88ada3944ab2a9b0694d18d315a89d) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Expand MDT doc callouts

Expand MDT-backed documentation callouts for preferred…

Expand MDT-backed documentation callouts for preferred Dart paths, compatibility notes, parity status, security guidance, and Android-only Mobile Wallet Adapter platform messaging across the workspace docs and package surfaces.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`53acc17`](https://github.com/openbudgetfun/solana_kit/commit/53acc174471dc42d8f0c6ce92ca9f636754401e9) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Replace dynamic with Object?

Replace dynamic with Object? across lib source files; remaining dynamic usage is only in test matcher API signatures required by the test package.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fe249a4`](https://github.com/openbudgetfun/solana_kit/commit/fe249a46e06edf2f4cc924b30c4c463e8ea9a910) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add barrel-file re-export tests

Add barrel-file re-export tests for solana_kit and solana_kit_codecs umbrella packages.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Expand coverage thresholds to 26 packages

Expand per-package coverage thresholds from 5 packages to…

Expand per-package coverage thresholds from 5 packages to 26 packages; core packages at 80%+, high-risk at 60%+.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fe249a4`](https://github.com/openbudgetfun/solana_kit/commit/fe249a46e06edf2f4cc924b30c4c463e8ea9a910) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add SurfPool integration test directory

Add integration test directory with basic RPC tests…

Add integration test directory with basic RPC tests designed for SurfPool local validator; not run in CI automatically.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fe249a4`](https://github.com/openbudgetfun/solana_kit/commit/fe249a46e06edf2f4cc924b30c4c463e8ea9a910) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Enable public_member_api_docs lint

Enable public_member_api_docs lint rule with file-level suppressions for incremental backfill.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add examples/ directory with 26 scripts

Add a top-level examples/ directory with 26 standalone…

Add a top-level `examples/` directory with 26 standalone Dart example scripts and a README covering addresses, keys, codecs, structs, options, errors, sysvars, offchain messages, transaction building/signing/confirmation, RPC, subscriptions, accounts, Helius DAS/priority-fees, functional pipe, fast-stable-stringify, address comparator, union codecs, and transaction serialisation.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add solana-program reference repos

Add solana-program/ reference repos to clone:repos with…

Add solana-program/* reference repos to clone:repos with pinned version tracking for all 11 program repos.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`0d394fb`](https://github.com/openbudgetfun/solana_kit/commit/0d394fba231feb79137da5f74a015180a2c13c99) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add transaction execution boundary

Add a higher-level transaction execution boundary that…

Add a higher-level transaction execution boundary that combines instruction-plan planning, signing, and sending into a single structured outcome, with a signer-based convenience wrapper for common app flows.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`69db7ef`](https://github.com/openbudgetfun/solana_kit/commit/69db7ef8dce81e51e5980c4254a382c76082617c) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add account client and RPC response models

Add a higher-level Solana account client plus typed RPC…

Add a higher-level Solana account client plus typed RPC response wrappers for common account, balance, blockhash, and multi-account request flows.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`aa54336`](https://github.com/openbudgetfun/solana_kit/commit/aa54336c1e9a6c4ae5df1adafc1822cfccf342fa) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add upstream parity test harness

Add an executable upstream parity harness that compares…

Add an executable upstream parity harness that compares selected Solana Kit Dart behaviors against the tracked `@solana/kit` release in CI and local development.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bf0f168`](https://github.com/openbudgetfun/solana_kit/commit/bf0f168606f039e9029a4f5c25942e591ef9940d) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Expose upstream-compatible client helpers

Expose the new upstream-compatible convenience surface…

Expose the new upstream-compatible convenience surface from the umbrella package. This re-exports the fixed-point helpers, functional helpers, compute-unit estimation helpers, Dart-native client/plugin composition APIs, identity and payer capability interfaces, and slot-tracking stream/reactive-store helpers used to combine an initial RPC value with live subscription updates.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Fix MDT product callout rendering so preferred-path

_Owner:_ Ifiok Jr. · _Introduced in:_ [`a7355ff`](https://github.com/openbudgetfun/solana_kit/commit/a7355ffb6f9227fcf9462cdc1d13608fa3d5242b) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

#### Move reference repos to config JSON

Move reference repo pins out of devenv.nix into…

Move reference repo pins out of `devenv.nix` into `config/reference-repos.json`, and teach `clone:repos` to read that config and report repo status.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`731da8d`](https://github.com/openbudgetfun/solana_kit/commit/731da8da45af0a34e66ad9347f19dbcd6b461485) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)
