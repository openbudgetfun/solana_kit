---
"solana_kit_errors": minor
---

# Track `@solana/errors` v8.5.0: five new error codes

Ports the error codes added upstream in `@solana/kit` v8.5.0:

- `keysVerificationRequiresExtractablePublicKey(3704007)` — WebCrypto-specific upstream; reserved here with its upstream number (the Dart verifier's public keys are always readable), with no throw site today.
- `codecsUnexpectedZeroFixedSizeItemForArrayLikeSizeStrategy(8078030)` — thrown by the array/set/map codecs when a zero-byte fixed-size item codec is combined with the sentinel or remainder size strategy.
- `walletInvalidMessageSignature(8900004)`, `walletInvalidSignInOutput(8900005)`, `walletInvalidNumberOfOutputs(8900006)` — wallet-account signer surface codes; reserved with their upstream numbers (that surface is not implemented in the Dart port yet).

Each code keeps its upstream `SolanaErrorCode` number so error codes remain interoperable across implementations.
