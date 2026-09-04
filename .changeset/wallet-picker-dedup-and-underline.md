---
"solana_kit_wallet_standard": patch
"solana_kit_wallet_ui": patch
---

# Deduplicate detected wallets and clean up picker text

The registry now ignores wallets whose name is already registered, so extensions that announce themselves more than once (additional content-script worlds, reloads) no longer produce duplicate picker tiles. Wallet picker content carries an explicit default text style, which removes the framework fallback's yellow double underline that leaked under every label in Cupertino presentations.
