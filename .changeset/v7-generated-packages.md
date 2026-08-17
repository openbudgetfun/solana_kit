---
"solana_kit_system": minor
"solana_kit_token": minor
"solana_kit_token_2022": minor
"solana_kit_address_lookup_table": minor
"solana_kit_memo": minor
"solana_kit_compute_budget": minor
"solana_kit_stake": minor
"solana_kit_loader": minor
---

# Regenerated program packages from upstream v7 IDLs

Regenerated all 8 generated program packages from their latest upstream Codama IDLs:

- solana_kit_system: js@v0.12.2 → v0.13.0
- solana_kit_token: js@v0.14.0 → v0.15.0
- solana_kit_token_2022: js@v0.12.0 → v0.14.1
- solana_kit_address_lookup_table: js@v0.12.1 → v0.13.0
- solana_kit_memo: js@v0.11.2 → v0.12.0
- solana_kit_compute_budget: js@v0.16.0 → v0.17.0
- solana_kit_stake: js@v0.7.2 → v0.8.0; applied the upstream Stake Codama preprocessing before rendering so generated defined-type imports resolve to Dart files
- solana_kit_loader: loader-v3 js@v0.4.0 → v0.5.0; migrated planning helpers to the generated v0.5 API and retained the handwritten Loader v3 account codecs and Loader v4 client surface

Generated using `node scripts/generate_program_packages.mjs` — a new generator script that runs the Codama renderer against upstream IDLs.
