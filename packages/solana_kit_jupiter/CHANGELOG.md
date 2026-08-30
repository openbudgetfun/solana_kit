# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

### 💥 Breaking Change

#### Add the Jupiter Exchange client

Add the Jupiter Exchange client package: Swap API v2 (`/order`, `/execute`, `/build`), Price API v3, Token API v2, base64 transaction decoding, an injectable HTTP transport, and keyless or `x-api-key` authentication on `https://api.jup.ag`.

```dart
final jupiter = createJupiterClient(JupiterConfig(apiKey: 'key'));
final order = await jupiter.swap.getOrder(
  JupiterOrderRequest(
    inputMint: sol,
    outputMint: usdc,
    amount: BigInt.from(10000000),
  ),
);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)
