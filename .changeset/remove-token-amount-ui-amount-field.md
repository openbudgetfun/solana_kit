---
"solana_kit_rpc_types": major
---

# Remove deprecated TokenAmount.uiAmount field

Removes the deprecated `uiAmount` field from `TokenAmount`. The floating-point `uiAmount` field loses precision for large token balances. Use `uiAmountString` instead, which preserves the full string representation from the RPC.
