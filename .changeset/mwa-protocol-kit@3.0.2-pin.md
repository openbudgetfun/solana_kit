---
"solana_kit_mobile_wallet_adapter": patch
"solana_kit_mobile_wallet_adapter_protocol": patch
---

# Track `mobile-wallet-adapter` `protocol-kit@3.0.2`

The reference pin advances to `@solana-mobile/mobile-wallet-adapter-protocol-kit@3.0.2` (the same commit carries `wallet-standard-mobile@0.7.1` and `mobile-wallet-adapter-protocol@3.0.2`). The Dart-visible part of the release is the clientlib fix from upstream #1788: `LocalAssociationScenario.start()` on a scenario that was already closed now throws `mwaSessionClosed` ("Scenario closed before it was started") instead of launching a fresh association, and the WebSocket connect-retry loop stops as soon as the scenario is closed instead of retrying until the connection deadline — so cancelling an association never waits out the retry schedule. The remaining upstream changes are React Native fork and bundler-resolution fixes, Wallet Standard adapter fixes outside the pinned packages, and dependency bumps; each is mapped in `docs/agents/upstream-audit-solana_kit_mobile_wallet_adapter-v3.0.2.md`.
