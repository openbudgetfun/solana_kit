# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

### 💥 Breaking Change

#### Add the Pyth Network client

Add the Pyth Network client package: the Hermes HTTP client (price feeds, binary price updates), Wormhole VAA and accumulator update parsing, Solana price-account and price-update-v2 decoders, `postUpdateAtomic`/`postUpdate` instruction builders for the Pyth Solana receiver program, and typed price-feed models.

```dart
final hermes = HermesClient(HermesConfig());
final feeds = await hermes.getLatestPriceFeeds([feedId]);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)

### 🐛 Fixed

#### Harden Pyth and SNS validation

Require the Pyth price-update account signer declared by the receiver IDL, validate Pyth account headers and bounded integer inputs, normalize malformed update data to typed decode errors, and cover the signer requirement through the Surfpool transaction flow. Also enforce SNS record lengths, EVM address sizes, and TLD-trimmed domain-key inputs.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)
