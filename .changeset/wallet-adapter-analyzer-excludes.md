---
"solana_kit_wallet_adapter": patch
"solana_kit_mobile_wallet_adapter": patch
---

# Refresh analyzer excludes for the Flutter 3.47 toolchain

The Flutter 3.47 tooling rewrites package `analysis_options.yaml` files during resolution to exclude generated `build/**` output from analysis. This applies the same exclusion to the wallet adapter and mobile wallet adapter packages (and the mobile example), keeping their analysis options stable under the updated FVM pin. No public API or behavior changes.
