---
"solana_kit_mobile_wallet_adapter": patch
---

Fixes CI regressions in the mobile wallet adapter example and Android compile check.

- Renames the Android example package namespace to satisfy `ktlint` package-name rules.
- Hardens `check-mobile-wallet-adapter-android-compile.sh` to use local workspace `solana_kit_*` dependency overrides during temp-app resolution.
