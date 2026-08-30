# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

### 💥 Breaking Change

#### Add the Squads V4 multisig client

Add the Squads V4 multisig program client, generated with `codama-renderers-dart` from the Squads-Protocol v4 Anchor IDL: 36 instruction builders, 9 account codecs, 45 error helpers, program-level parsing, and PDA derivations for multisigs, vaults, transactions, proposals, spending limits, and program config, with `newConfigAuthority` argument naming matching the upstream TS SDK.

```dart
final (multisig, bump) = await findMultisigPda(createKey: createKey);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)
