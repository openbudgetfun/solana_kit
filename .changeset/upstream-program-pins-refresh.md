---
"solana_kit_system": patch
"solana_kit_token": patch
"solana_kit_token_2022": patch
"solana_kit_address_lookup_table": patch
"solana_kit_memo": patch
"solana_kit_compute_budget": patch
"solana_kit_stake": patch
"solana_kit_loader": patch
"solana_kit_mpl_bubblegum": patch
---

# Refresh upstream reference pins for solana-program/* and mpl-bubblegum

- Tracks the latest upstream references in `config/reference-repos.json`: `solana-program/system` `js@v0.14.0` (was `js@v0.13.0`), `solana-program/token` `js@v0.16.0` (was `js@v0.15.0`), `solana-program/token-2022` `js@v0.16.0` (was `js@v0.14.1`), `solana-program/address-lookup-table` `js@v0.14.0` (was `js@v0.13.0`), `solana-program/memo` `js@v0.13.0` (was `js@v0.12.0`), `solana-program/compute-budget` `js@v0.18.0` (was `js@v0.17.0`), `solana-program/stake` `js@v0.9.0` (was `js@v0.8.0`), `solana-program/loader-v3` `js@v0.6.0` (was `js@v0.5.0`), `solana-program/loader-v4` commit `4f62fb2e` (was commit `1d6335be`), and `mpl-bubblegum` commit `6a6a77e3` (was commit `68e4bc20`).
- All of the `js` releases are `@solana/kit` ^7 → ^8 dependency bumps with no instructions, accounts, types, or wire-format changes; the IDL additions are Codama display metadata, which the Dart renderer does not render. Regenerating every affected client from the old and new pins produced byte-identical Dart output, so the generated clients are unchanged. The `mpl-bubblegum` new commit only re-exports the JS `mintV2` helpers and the `loader-v4` new commit only bumps its JS client to `@solana/kit` v8; both IDLs are unchanged. The `token-2022` pin supersedes the stale PR #222 (`js@v0.15.0`).
- `solana-program/stake` restructured its IDL to the Codama v1.8.0 format (program metadata block, `lockupParams` argument links renamed from `lockupArgs`, IDL program node renamed from `solanaStakeInterface` to `stake`). `scripts/generate_program_packages.mjs` now maps both argument link names and keeps the `solanaStakeInterface` renderer-facing program name, so the generated APIs (flattened `setLockup`/`setLockupChecked`/`authorizeWithSeed` argument fields, `SolanaStakeInterface` identifiers) stay stable. No generated Dart code changed.
- Package READMEs now cite the refreshed upstream versions they mirror.
