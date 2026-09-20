# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.10.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.10.0) (2026-09-21)

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

### Fixes

#### Restore complete version inventories in package READMEs

The `versions.json` data source that renders every package README's installation section had drifted: packages first released after the legacy knope era were never added, so their READMEs told consumers to depend on a bare `^` with no version. The retired `solana_kit_functional` entry and a stale `solana_kit_mobile_wallet_adapter_example` version were also lingering.

The inventory now matches every package's `pubspec.yaml`, the `solana_kit_functional` key is gone, and the affected installation sections render the real published version again:

```yaml
dependencies:
  "solana_kit_jupiter": ^0.9.3
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [4c8855b](https://github.com/openbudgetfun/solana_kit/commit/4c8855bd608bb9f05324b001b552c9329679e441)

## [0.9.3](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.3) (2026-09-12)

### Changed

- **No package-specific changes were recorded; `solana_kit_mpl_token_metadata` was updated to 0.9.3 as part of group `main`.**

## [0.9.2](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.2) (2026-09-06)

### Changed

- No package-specific changes were recorded; `solana_kit_mpl_token_metadata` was updated to 0.9.2 as part of group `main`.

## [0.9.1](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.1) (2026-08-30)

### 🐛 Fixed

#### Fix publish validation for ecosystem packages

Declare the `meta` and `solana_kit_accounts` dependencies that the generated Squads and mpl-token-metadata clients import, so `dart pub publish` validation passes, and normalize `readme.md` to `README.md` across the ecosystem packages to satisfy the pub README requirement.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`a53391f`](https://github.com/openbudgetfun/solana_kit/commit/a53391f69a4668422096a31bcac46397770a5d33)

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

### 💥 Breaking Change

#### Add the Token Metadata program client

Add the mpl-token-metadata program client, generated with `codama-renderers-dart` from the metaplex-foundation shank IDL: 58 instruction builders, 14 account codecs, 203 error helpers, instruction identification and parsing, and PDA derivations for metadata, master editions, edition markers, collection and use authority records, token records, delegate records, and program-as-burner.

```dart
final (metadata, bump) = await findMetadataPda(mint: mint);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)
