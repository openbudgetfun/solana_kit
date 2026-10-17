---
"solana_kit_mobile_wallet_adapter": patch
"solana_kit_mobile_wallet_adapter_protocol": patch
---

# Track `@solana-mobile/mobile-wallet-adapter-protocol-kit` `3.0.1`

The reference pin shared by the Mobile Wallet Adapter packages advances to `protocol-kit@3.0.1`. The upstream release is a JavaScript module-organization refactor — `startRemoteScenario` moves into its own module so React Native builds can exclude it — plus example-app and dev dependency bumps. The function body is unchanged from 3.0.0 and the Dart port has no module-graph or React Native fork concept, so no Dart code changes; the released patch carries the pin advance and the re-rendered support tables. See `docs/agents/upstream-audit-solana_kit_mobile_wallet_adapter-v3.0.1.md`.
