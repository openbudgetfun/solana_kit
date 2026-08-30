# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.9.1](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_codecs_strings` was updated to 0.9.1 as part of group `main`.

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

### 🐛 Fixed

#### Sync upstream `@solana/kit` v7.1.1

Tracks upstream APIs and behavior through `v7.1.1`:

- `solana_kit`: README now documents `v7.1.1` as the latest supported upstream version.
- `solana_kit_codecs_strings`: base-X decoders now report the end of the buffer as the next offset when no bytes remain to decode, matching upstream `@solana/codecs-strings` (#1926).
- `solana_kit_rpc_transformers`: subscription responses for `blockSubscribe`/`blockNotification` now consult the `blockNotifications` numeric allow-list, matching upstream `@solana/rpc-transformers` (#1925).
- `solana_kit_instruction_plans`: `successfulSingleTransactionPlanResultFromTransaction` is deprecated in favor of `successfulSingleTransactionPlanResult` with an explicit context, matching upstream `@solana/instruction-plans` (#1924).

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #220](https://github.com/openbudgetfun/solana_kit/pull/220) · _Related issues:_ [#1924](https://github.com/openbudgetfun/solana_kit/issues/1924), [#1925](https://github.com/openbudgetfun/solana_kit/issues/1925), [#1926](https://github.com/openbudgetfun/solana_kit/issues/1926)

### 📖 Documentation

#### Unslop package docs and code comments

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)

## [0.8.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.8.0) (2026-08-19)

### 💥 Breaking Change

#### Preserve UTF-8 data exactly during decoding

UTF-8 codecs now preserve embedded null characters and reject malformed byte sequences. Lossy compatibility modes and null-character rejection modes have been removed; callers can opt into null removal explicitly with `removeNullCharacters` after decoding.

```dart
final value = getUtf8Codec().decode(bytes);
final withoutPadding = removeNullCharacters(value);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #218](https://github.com/openbudgetfun/solana_kit/pull/218)

## [0.7.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.7.0) (2026-08-18)

### 📖 Documentation

#### Reformat package docs

Docs have been reformatted to remove line wrapping.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #212](https://github.com/openbudgetfun/solana_kit/pull/212)

## [0.6.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.6.0) (2026-08-12)

### 📖 Documentation

#### Centralize package version documentation

Centralize package version metadata in `versions.json` and render package installation snippets from the shared MDT data source. Published package behavior is unchanged.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #188](https://github.com/openbudgetfun/solana_kit/pull/188)

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)

## [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.5.0) (2026-06-01)

### 💥 Breaking Change

#### Raise minimum Dart SDK to 3.12

Raise the minimum supported Dart SDK constraint to `^3.12.0` across public Dart packages.

This is a breaking change because consumers must use Dart 3.12 or newer. Flutter consumers must use a Flutter SDK that bundles Dart 3.12 or newer.

```yaml
environment:
  sdk: ^3.12.0
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`32d5d36`](https://github.com/openbudgetfun/solana_kit/commit/32d5d367abb7615fea5ee341f03d17c2bc0d66dd)

### 🧪 Testing

#### Improve test coverage to 95%+ across all packages

Added 500+ tests covering equality/hashCode/toString, codec edge cases, error paths, and constructor variants. Removed dead code in fast_stable_stringify. Fixed concurrent modification bug in subscribable.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`48216f9`](https://github.com/openbudgetfun/solana_kit/commit/48216f9af0ff058d7db83994e5bdb3b9be95fdf8) · _Last updated in:_ [`b7f5419`](https://github.com/openbudgetfun/solana_kit/commit/b7f5419bbe792d4ba1731eba227088d8f74a3ebb)

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-30)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add UTF-8 null-char decoding controls

Add strict and explicit UTF-8 null-character decoding…

Add strict and explicit UTF-8 null-character decoding controls to `solana_kit_codecs_strings`, while preserving the default `@solana/kit` compatibility behavior that strips decoded null characters.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`ad3e6ad`](https://github.com/openbudgetfun/solana_kit/commit/ad3e6ad2cef3860dd70c2802650b773a25f3b356) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)
