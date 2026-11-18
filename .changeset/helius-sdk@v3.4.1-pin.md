---
"solana_kit_helius": patch
---

# Track `helius-labs/helius-sdk` `v3.4.1`

The reference pin advances to `v3.4.1`. The upstream patch release carries one behavioral fix that the Dart package implements: `createSmartTransaction` now applies every supplied signer to the user instructions — one signer per address, fee payer first — so an account an instruction references that a signer also owns is promoted to a required signer (keeping its writable bit). Previously supplied signers were only used to resolve the fee payer, so a multi-signer transaction compiled without the extra signature slots and failed on send. Already-marked signer accounts keep their signer objects, accounts are never appended, and map-shaped draft instructions pass through unchanged. The remaining upstream changes are TypeScript packaging mechanics or fixes to send/websocket/header surfaces the Dart port does not expose; each is mapped in `docs/agents/upstream-audit-solana_kit_helius-v3.4.1.md`.
