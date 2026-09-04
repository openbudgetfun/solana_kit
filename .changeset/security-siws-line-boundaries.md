---
"solana_kit_mobile_wallet_adapter_protocol": patch
---

# Reject SIWS field and resource line injection

Reject carriage returns and newlines in every Sign In With Solana field and resource before constructing the message to sign. This prevents embedded line breaks from changing field boundaries or adding unintended signed resources.
