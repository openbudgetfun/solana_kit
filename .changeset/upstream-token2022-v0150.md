---
"solana_kit_token_2022": patch
---

# Sync upstream `solana-program/token-2022` `js@v0.15.0`

- Tracks the upstream `js@v0.15.0` tag in `config/reference-repos.json`. The `v0.15.0` IDL changes are limited to clear-signing display metadata (`display`/`provides` nodes) and add no instructions, accounts, types, or wire-format changes, so the generated client is unchanged. The existing handwritten helpers (`getInitializeInstructionsForExtensions`, `getMintSize`, `getTokenSize`) and their upstream counterparts are unchanged in this release.
