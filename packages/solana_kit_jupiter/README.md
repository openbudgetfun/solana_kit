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

<!-- {=packageInstallSection:"solana_kit_jupiter"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_jupiter": ^
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

:::

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_jupiter": ^
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

## Documentation

- Package page: https://pub.dev/packages/solana_kit_jupiter
- API reference: https://pub.dev/documentation/solana_kit_jupiter/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_jupiter
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_jupiter

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

<!-- {=docsJupiterSwapSection} -->

### Swap through Jupiter's managed order flow

Pass the swapping wallet as `taker` to receive an assembled v0 transaction from `/order`. Without a taker the endpoint returns only a quote. Inspect and sign the transaction with Solana Kit signers, then submit it through `executeOrder`; check that the returned `status` is `Success`, since failed executions can also include a signature.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_jupiter/solana_kit_jupiter.dart';

Future<void> previewSwap(Address taker) async {
  const solAddress = Address('So11111111111111111111111111111111111111112');
  const usdcAddress = Address(
    'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
  );

  final jupiter = createJupiterClient(JupiterConfig(apiKey: 'your-api-key'));

  final order = await jupiter.swap.getOrder(
    JupiterOrderRequest(
      inputMint: solAddress,
      outputMint: usdcAddress,
      amount: BigInt.from(10000000), // 0.01 SOL
      slippageBps: 50,
      taker: taker,
    ),
  );

  final encodedTransaction = order.encodedTransaction;
  if (encodedTransaction == null) {
    throw StateError('Jupiter did not return a transaction for this order.');
  }
  final transaction = decodeBase64SwapTransaction(encodedTransaction);
  // Inspect, sign the transaction with solana_kit_signers, then submit it.
  print(transaction);
}
```

For self-landing swaps, use `jupiter.swap.buildSwap(...)` with a taker. Preserve the returned setup, swap, cleanup, other, and optional tip instructions, plus the lookup table mappings and blockhash metadata, when assembling the transaction.

<!-- {/docsJupiterSwapSection} -->

## Transport security

Jupiter requests require an absolute HTTPS base URL without embedded credentials, query parameters, or fragments. Set `allowInsecureHttp: true` only for explicitly trusted development endpoints. API keys belong in `apiKey`, and all HTTP redirects fail rather than forwarding credentials or signed transactions to another origin.

Only configure endpoints and injected HTTP clients you trust. The client does not resolve and filter private DNS destinations or impose response size and timeout limits; custom transports can enforce those application-specific bounds.

Token categories use `category('toptrending', interval: '1h', limit: 50)`; the interval defaults to `24h`. Malformed price response bodies throw `JupiterException` instead of appearing to be an empty market.

## Key APIs

- `createJupiterClient`, `JupiterConfig`
- `JupiterSwapClient`: `getOrder`, `executeOrder`, `buildSwap`
- `decodeBase64SwapTransaction`
- `JupiterPriceClient`: `getPrices`
- `JupiterTokenClient`: `search`, `tagged`, `category`, `recent`
- Models: `JupiterOrderRequest`, `JupiterOrderResponse`, `JupiterExecutionResponse`, `JupiterBuildResponse`, `JupiterPrice`, `JupiterTokenItem`, `JupiterException`

## Reference

Built against the Jupiter Swap API v2, Price API v3, and Token API v2 as documented at `https://developers.jup.ag`, including the keyless-tier migration from the deprecated `lite-api.jup.ag` host.
