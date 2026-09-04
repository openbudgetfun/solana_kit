---
"solana_kit_wallet_adapter": patch
---

# Preserve wallet authorization state across asynchronous lifecycle changes

Invalidate pending wallet connections when disconnecting, switching wallets, unregistering, or disposing the controller. Clear the selected account immediately on disconnect, reject stale connection completions, release old wallet listeners, and prevent delayed discovery or signing failures from overwriting a newer connection.
