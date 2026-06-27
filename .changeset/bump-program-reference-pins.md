---
"solana_kit_token": patch
"solana_kit_address_lookup_table": patch
"solana_kit_memo": patch
"solana_kit_compute_budget": patch
"solana_kit_stake": patch
"solana_kit_loader": patch
---

# Bump program reference pins to latest upstream tags

Updates `config/reference-repos.json` and docs to track the latest
upstream tags for program packages whose IDLs are unchanged or
tooling-only:

- Token: `js@v0.13.0` → `js@v0.14.0`
- Address Lookup Table: `js@v0.11.0` → `js@v0.12.1`
- Memo: `js@v0.11.1` → `js@v0.11.2`
- Compute Budget: `js@v0.15.0` → `js@v0.16.0`
- Stake: `js@v0.6.1` → `js@v0.7.2`
- Loader v3: `js@v0.3.0` → `js@v0.4.0`

No generated Dart API changes for these packages — IDL comparison
confirmed semantic equivalence. Updates are reference pin and
documentation only.