---
"solana_kit_anchor": patch
---

# Reject cyclic Anchor IDL type dependencies

Reject cyclic Anchor IDL type dependencies with an `ArgumentError` during codec construction instead of exhausting the call stack. Apply the check to direct codec requests, instructions, accounts, and events while preserving repeated acyclic references.
