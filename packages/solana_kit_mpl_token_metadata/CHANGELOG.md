# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

### 💥 Breaking Change

#### Add the Token Metadata program client

Add the mpl-token-metadata program client, generated with `codama-renderers-dart` from the metaplex-foundation shank IDL: 58 instruction builders, 14 account codecs, 203 error helpers, instruction identification and parsing, and PDA derivations for metadata, master editions, edition markers, collection and use authority records, token records, delegate records, and program-as-burner.

```dart
final (metadata, bump) = await findMetadataPda(mint: mint);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)
