# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.9.2](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.2) (2026-09-06)

### 🐛 Fixed

#### Validate Anchor and Pyth event data

Validate Anchor event provenance against the IDL program's runtime invocation stack, ignoring foreign-program and embedded-message event forgeries. Bound Hermes price conversion work for extreme untrusted exponents to prevent application stalls.

Preserve all 64 bits of unsigned Pyth confidence and slot fields so large confidence intervals cannot become negative and bypass application upper-bound checks.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

## [0.9.1](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_pyth` was updated to 0.9.1 as part of group `main`.

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
