---
"solana_kit_anchor": patch
"solana_kit_attestation_service": patch
"solana_kit_jupiter": patch
"solana_kit_mpl_core": patch
"solana_kit_mpl_token_metadata": patch
"solana_kit_pyth": patch
"solana_kit_sns": patch
"solana_kit_squads": patch
---

# Restore complete version inventories in package READMEs

The `versions.json` data source that renders every package README's installation section had drifted: packages first released after the legacy knope era were never added, so their READMEs told consumers to depend on a bare `^` with no version. The retired `solana_kit_functional` entry and a stale `solana_kit_mobile_wallet_adapter_example` version were also lingering.

The inventory now matches every package's `pubspec.yaml`, the `solana_kit_functional` key is gone, and the affected installation sections render the real published version again:

```yaml
dependencies:
  "solana_kit_jupiter": ^0.9.3
```
