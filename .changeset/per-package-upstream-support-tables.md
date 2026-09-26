---
"solana_kit_address_lookup_table": docs
"solana_kit_associated_token_account": docs
"solana_kit_attestation_service": docs
"solana_kit_compute_budget": docs
"solana_kit_config": docs
"solana_kit_helius": docs
"solana_kit_loader": docs
"solana_kit_memo": docs
"solana_kit_mobile_wallet_adapter": docs
"solana_kit_mobile_wallet_adapter_protocol": docs
"solana_kit_mpl_bubblegum": docs
"solana_kit_mpl_core": docs
"solana_kit_mpl_token_metadata": docs
"solana_kit_spl_account_compression": docs
"solana_kit_squads": docs
"solana_kit_stake": docs
"solana_kit_subscriptions": docs
"solana_kit_system": docs
"solana_kit_token": docs
"solana_kit_token_2022": docs
---

# Publish a per-package upstream support table in each package README

Every package that ports something outside `@solana/kit` now documents which upstream revision each of its releases was generated and verified against, so a reader can pick the Dart version that matches the upstream program version they target.

```markdown
| `solana_kit_system` version | `system`     | Released                |
| --------------------------- | ------------ | ----------------------- |
| _next release_              | `js@v0.15.0` | _unreleased_            |
| `0.7.2` – `0.8.0`           | `js@v0.14.1` | 2026-09-06 – 2026-09-21 |
| `0.7.0` – `0.7.1`           | `js@v0.14.0` | 2026-08-30              |
```

**One row per upstream revision, not per release.** Consecutive releases that were generated against the same upstream ref collapse into a single `0.7.2` – `0.8.0` range, so a package that shipped several patches against one upstream tag reports one row instead of burying the mapping in repetition. Packages whose releases moved with the umbrella `solana_kit` version (the lockstep group members) are keyed by that version and label the column accordingly.

The leading `_next release_` row shows the pin the working tree is currently generated against, so the mapping for unreleased work is visible before the release tooling assigns a version.

Tables are generated, not hand-written. `scripts/sync_package_upstream_support.dart` reads `config/reference-repos.json` at every `"<package>/v<version>"` release tag, collapses the ranges, and writes `config/package-upstream-support.json`; `scripts/generate_upstream_docs.dart` renders that into each README between `upstream-support` markers. Both run through `docs:update`, so the tables refresh alongside the other generated docs. The history is committed rather than derived at check time because CI checks out shallowly and would see no tags.

No package code changes; this is documentation only.
