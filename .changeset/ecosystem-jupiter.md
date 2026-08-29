---
"solana_kit_jupiter": major
---

# Add the Jupiter Exchange client

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
