# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

### 💥 Breaking Change

#### Add the Metaplex Core program client

Add the mpl-core (Metaplex Core) program client generated from the metaplex-foundation shank IDL: 42 instruction builders, 6 account codecs, 57 error helpers, program-level instruction identification and parsing, and PDA derivations for the asset signer, preconfigured plugin accounts, dynamic extra accounts, and oracle accounts.

```dart
final (assetSigner, bump) = await findAssetSignerPda(asset: asset);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)
