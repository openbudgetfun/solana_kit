---
"solana_kit_mobile_wallet_adapter": patch
---

# Tolerate empty WebSocket frames in connected MWA sessions

Ports the connected-state hardening from `@solana-mobile/mobile-wallet-adapter-protocol` 3.0.0: an empty binary frame (e.g. a wallet keep-alive) arriving during an established association session is now skipped without advancing the inbound sequence number, instead of failing the session with `mwaInvalidSequenceNumber` and tearing down every pending request. Short frames, out-of-order sequence numbers, and unknown response ids keep their existing strict handling; in-flight requests still settle with `mwaSessionClosed` when the transport ends.

The reference pin advances from `@solana-mobile/mobile-wallet-adapter-protocol-kit@0.4.0` to `@solana-mobile/mobile-wallet-adapter-protocol-kit@3.0.0`. The remaining upstream 3.0.0 changes are JavaScript packaging (ESM-only build, Kit-8 peer range) or target surfaces the Dart port does not implement (Nostr association, Android walletlib); see `docs/agents/upstream-audit-solana_kit_mobile_wallet_adapter-v3.0.0.md`.
