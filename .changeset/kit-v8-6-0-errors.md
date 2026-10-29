---
"solana_kit_errors": minor
---

# Track `@solana/errors` v8.6.0: one new error code

Adds `walletFeatureVersionUnsupported` (8900007) with its upstream number and message: the wallet supports an older version of a requested feature than required. Reserved with no throw site today — the wallet-account feature-negotiation surface is not implemented in the Dart port yet.
