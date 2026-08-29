# solana_kit_jupiter

[![pub package](https://img.shields.io/pub/v/solana_kit_jupiter.svg)](https://pub.dev/packages/solana_kit_jupiter) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_jupiter/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_jupiter) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_jupiter)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_jupiter)

Jupiter Exchange client for the Solana Kit Dart SDK: the Swap API v2 (quote, assembled transaction, execution, and raw build), Price API v3, and Token API v2, with Solana Kit transaction decoding.

## What you get

- **Swap API v2** — request a quote plus an assembled v0 transaction (`/swap/v2/order`), submit the signed transaction for managed execution (`/swap/v2/execute`), or fetch the raw instruction set for self-landing swaps (`/swap/v2/build`)
- **Price API v3** — USD prices for up to fifty mints per request
- **Token API v2** — search, tag, category, and recent token metadata
- **Transaction decode** — turn the returned base64 wire transaction into a typed `Transaction` for inspection and signing
- **Injectable transport** — pass a custom HTTP client through `JupiterConfig` for tests and middleware

Out of v1 scope: the Trigger API (limit orders and DCA), the Referral on-chain program, Lend, Prediction, Studio, and the Jupiter Terminal web widget (which cannot serve Dart or Flutter apps).

## Auth

All endpoints accept an optional `x-api-key` header. Without a key, Jupiter serves keyless traffic on `https://api.jup.ag` at a reduced rate limit; keys from the Jupiter developer portal unlock higher tiers on the same base URL.

## Usage

### Request a quote and assembled transaction

```dart
final jupiter = createJupiterClient(
  JupiterConfig(apiKey: 'your-api-key'),
);

final order = await jupiter.swap.getOrder(
  JupiterOrderRequest(
    inputMint: Address(solAddress),
    outputMint: Address(usdcAddress),
    amount: BigInt.from(10000000), // 0.01 SOL
    slippageBps: 50,
  ),
);

final transaction = decodeBase64SwapTransaction(order.encodedTransaction!);
// Inspect, sign the transaction with solana_kit_signers, then submit it.
```

### Execute a signed order

```dart
final execution = await jupiter.swap.executeOrder(
  userPublicKey: walletAddress,
  order: order,
  signedTransaction: base64EncodedSignedTransaction,
);
print(execution.signature);
```

### Prices and tokens

```dart
final prices = await jupiter.price.getPrices([
  Address(solAddress),
  Address(usdcAddress),
]);
print(prices[Address(solAddress)]!.usdPrice);

final tokens = await jupiter.tokens.search('Jupiter');
```

## Key APIs

- `createJupiterClient`, `JupiterConfig`
- `JupiterSwapClient`: `getOrder`, `executeOrder`, `buildSwap`
- `decodeBase64SwapTransaction`
- `JupiterPriceClient`: `getPrices`
- `JupiterTokenClient`: `search`, `tagged`, `category`, `recent`
- Models: `JupiterOrderRequest`, `JupiterOrderResponse`, `JupiterExecutionResponse`, `JupiterBuildResponse`, `JupiterPrice`, `JupiterTokenItem`, `JupiterException`

## Reference

Built against the Jupiter Swap API v2, Price API v3, and Token API v2 as documented at `https://developers.jup.ag`, including the keyless-tier migration from the deprecated `lite-api.jup.ag` host.
