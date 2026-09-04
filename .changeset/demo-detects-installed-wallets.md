---
"solana_kit_wallet_adapter": minor
"solana_kit_wallet_ui": patch
---

# List detected wallets in the embedded demo

`createDefaultWalletRegistry` accepts `additionalWallets` that stay available alongside the wallets detected on the platform. The embedded docs demo now composes the deterministic demo wallet with the visitor's installed Wallet Standard wallets, so Phantom, Backpack, Solflare, and any other standard-compatible extension appear in the picker the same way the wallet adapter examples surface them.
