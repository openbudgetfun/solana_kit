---
"solana_kit_mobile_wallet_adapter": patch
---

# Isolate mobile wallet scenario callbacks

Reject native wallet events from other sessions, events without session IDs, and queued events received after closure before they can invoke authorization or signing callbacks. Prevent an existing wallet scenario from starting a second native session, and close native scenarios whose creation finishes after the wallet scenario was closed.
