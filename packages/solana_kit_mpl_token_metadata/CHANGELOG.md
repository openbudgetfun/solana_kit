# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

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
