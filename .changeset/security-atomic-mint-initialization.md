---
"solana_kit_token": patch
---

# Keep mint account initialization atomic

Keep mint account creation and initialization atomic so constrained transaction plans cannot expose a funded, uninitialized mint between separate transactions.
