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

# Refresh upstream reference pins for solana-program/*, loader-v4, and mpl-bubblegum

Track the latest upstream references in `config/reference-repos.json`: `solana-program/system` `js@v0.15.0` (was `js@v0.14.1`), `solana-program/token` `js@v0.17.0` (was `js@v0.16.1`), `solana-program/token-2022` `js@v0.19.0` (was `js@v0.18.0`), `solana-program/address-lookup-table` `js@v0.15.0` (was `js@v0.14.1`), `solana-program/memo` `js@v0.15.0` (was `js@v0.14.1`), `solana-program/compute-budget` `js@v0.19.0` (was `js@v0.18.1`), `solana-program/stake` `js@v0.10.0` (was `js@v0.9.1`), `solana-program/loader-v3` `js@v0.7.0` (was `js@v0.6.1`), `solana-program/loader-v4` commit `76f8ce27` (was commit `5bb854db`), and `metaplex-foundation/mpl-bubblegum` commit `ad7d32b4` (was commit `07180c73`).

No generated Dart code changes. Every `solana-program/*` release is the same mechanical upstream change — a `@codama/renderers-js` bump that regenerates the TypeScript client, widening its generated account inputs from `TransactionSigner<TAccount>` / `Address<TAccount>` to the `InstructionSignerInput` / `InstructionAccountInput` family — plus Rust dependency bumps and `Cargo.lock` churn. This port generates from each repository's `idl.json`, not its TypeScript client, and `idl.json` is byte-identical between the old and new tags for all eight. `stake` is the only one whose IDL blob changed, and only in its version headers (Codama format `1.8.0` → `1.9.2`, program version `4.4.0` → `5.0.0`); the renderer emits no program version, so nothing reaches Dart.

Verified rather than assumed: regenerating all thirteen generated packages against the old pins and the new pins produced byte-identical output (`diff -rq` clean). `loader-v4` only bumps its JS renderer and regenerates the TypeScript client; its `idl.json` is unchanged. `mpl-bubblegum` carries JS client v6.0.0 and Rust client 4.0.0, but its `idls/bubblegum.json` is byte-identical and the program crate stays `0.12.0`, so the generated layer is unchanged. The JS-only DAS leaf-metadata work in that release (`toLeafMetadataV2`, `asCurrentMetadataV2`, the `sellerFeeBasisPointsRaw` / `creatorsRaw` / `inherited` fields on `AssetWithProof`) is **not ported**; see `docs/agents/upstream-audit-2026-09-26.md` for the gap and why it is deferred.

Package READMEs now cite the refreshed upstream versions they mirror. Upstream `@solana/kit` itself did not move (npm `latest` is still `8.3.0`), so the compatibility claim, `versions.json`, and the `solana_kit` ↔ `@solana/kit` parity table in `readme.md` are unchanged by this refresh.
