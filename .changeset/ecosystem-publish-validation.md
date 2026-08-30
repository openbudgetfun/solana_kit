---
"solana_kit_squads": patch
"solana_kit_mpl_token_metadata": patch
"solana_kit_anchor": patch
"solana_kit_jupiter": patch
"solana_kit_mpl_core": patch
"codama-renderers-dart": patch
---

# Fix publish validation for ecosystem packages

Declare the `meta` and `solana_kit_accounts` dependencies that the generated Squads and mpl-token-metadata clients import, so `dart pub publish` validation passes, and normalize `readme.md` to `README.md` across the ecosystem packages to satisfy the pub README requirement.
