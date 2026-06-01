# Upstream audit — 2026-06-01

This audit checks the configured reference repositories in `config/reference-repos.json` against their upstream remotes after the latest Solana Kit release.

## What changed in this audit

- Fixed two stale default-branch references so `clone:repos` works from a clean checkout:
  - `brij-digital/espresso-cash-public`: `main` → `master`.
  - `solana-program/account-compression`: `main` → `ac-mainnet-tag`.
- Added `solana_kit_mobile_wallet_adapter` / `solana_kit_mobile_wallet_adapter_protocol` package metadata to the existing `mobile-wallet-adapter` reference repo entry.
- Added `checkedCommit` metadata for branch/commit-tracked repos so we can see the latest upstream commit that was verified during this audit.
- Cloned all configured reference repos and verified them with `clone:repos:status`.

## Verification

```text
clone:repos:status
OK .repos/kit @ 6cd177b1 (branch main in sync)
OK .repos/espresso-cash-public @ 77150680 (branch master in sync)
OK .repos/helius-labs/helius-sdk @ 4c0c55b (commit 4c0c55b86eab0e3abde7896c0aa23c4b6515e9b0)
OK .repos/mobile-wallet-adapter @ bed51fa2 (branch main in sync)
OK .repos/solana-program/system @ 7b0f1a0 (tag js@v0.12.0)
OK .repos/solana-program/token @ a17df15 (tag js@v0.13.0)
OK .repos/solana-program/token-2022 @ 0a7fdd5e (tag js@v0.9.0)
OK .repos/solana-program/associated-token-account @ 0b867b5 (tag program@v8.0.0)
OK .repos/solana-program/address-lookup-table @ c26e9f9 (tag js@v0.11.0)
OK .repos/solana-program/memo @ 9d2f9b8 (tag js@v0.11.0)
OK .repos/solana-program/compute-budget @ a0174b4 (tag js@v0.15.0)
OK .repos/solana-program/stake @ a5274b9 (tag js@v0.6.0)
OK .repos/solana-program/config @ b60f4f2 (tag solana-config-program-client@v1.1.0)
OK .repos/solana-program/loader-v3 @ a2ba53b (tag js@v0.3.0)
OK .repos/solana-program/loader-v4 @ 5df834d (commit 5df834d)
OK .repos/solana-program/account-compression @ b229799 (branch ac-mainnet-tag in sync)
OK .repos/metaplex-foundation/mpl-bubblegum @ 02c1641 (branch main in sync)
```

## Upstream release drift

| Package                                                                          | Current reference                     | Latest matching upstream              | Status                | Notes                                                                                                   |
| -------------------------------------------------------------------------------- | ------------------------------------- | ------------------------------------- | --------------------- | ------------------------------------------------------------------------------------------------------- |
| `solana_kit_system`                                                              | `js@v0.12.0`                          | `js@v0.12.2`                          | Current               | Updated; added `createAccountAllowPrefund` helpers in this branch.                                      |
| `solana_kit_memo`                                                                | `js@v0.11.0`                          | `js@v0.11.1`                          | Current               | Updated reference to `js@v0.11.1`; no Dart API changes required.                                        |
| `solana_kit_stake`                                                               | `js@v0.6.0`                           | `js@v0.6.1`                           | Current               | Updated; applied `authorize*WithSeed`, `delegation`, and `stakeAuthorize` codec changes in this branch. |
| `solana_kit_token`                                                               | `js@v0.13.0`                          | `js@v0.13.0`                          | Current               | No newer matching JS tag found.                                                                         |
| `solana_kit_token_2022`                                                          | `js@v0.9.0`                           | `js@v0.9.0`                           | Current               | No newer matching JS tag found.                                                                         |
| `solana_kit_associated_token_account`                                            | `program@v8.0.0`                      | `program@v8.0.0`                      | Current               | No newer matching program tag found.                                                                    |
| `solana_kit_address_lookup_table`                                                | `js@v0.11.0`                          | `js@v0.11.0`                          | Current               | No newer matching JS tag found.                                                                         |
| `solana_kit_compute_budget`                                                      | `js@v0.15.0`                          | `js@v0.15.0`                          | Current               | No newer matching JS tag found.                                                                         |
| `solana_kit_config`                                                              | `solana-config-program-client@v1.1.0` | `solana-config-program-client@v1.1.0` | Current               | No newer matching client tag found.                                                                     |
| `solana_kit_loader`                                                              | `js@v0.3.0` + `5df834d`               | `js@v0.3.0` + `5df834d03975`          | Current               | Loader v4 still commit-pinned because there is no versioned release tag.                                |
| `solana_kit_spl_account_compression`                                             | `ac-mainnet-tag@b229799`              | `ac-mainnet-tag@b229799`              | Current branch ref    | Branch-tracked, not release-tagged.                                                                     |
| `solana_kit_mpl_bubblegum`                                                       | `main@02c1641`                        | `main@02c1641`                        | Current branch ref    | Branch-tracked; still notes Solita-format IDL conversion needs.                                         |
| `solana_kit_helius`                                                              | `4c0c55b`                             | `4c0c55b86eab`                        | Current pinned commit | Still pinned to v3.0.0 release commit because no v3.0.0 tag exists.                                     |
| `solana_kit_mobile_wallet_adapter` / `solana_kit_mobile_wallet_adapter_protocol` | `main@bed51fa`                        | `main@bed51fa`                        | Current branch ref    | Package metadata added to the reference config.                                                         |
| Core `@solana/kit` parity                                                        | `6.9.0`                               | `6.9.0`                               | Current               | `npm view @solana/kit version` reports `6.9.0`.                                                         |

## Recommended next PRs

1. Verify `solana_kit_system` against `solana-program/system` `js@v0.12.2`.
   - Main API addition to inspect: `createAccountAllowPrefund`.
2. Verify `solana_kit_stake` against `solana-program/stake` `js@v0.6.1`.
   - Pay close attention to authority seed codec changes in `authorizeCheckedWithSeed` / `authorizeWithSeed`.
3. Verify `solana_kit_memo` against `solana-program/memo` `js@v0.11.1`.
   - Likely low risk, but verify generated program metadata and tests.
4. Consider enhancing `clone:repos:status` to display `checkedCommit` for branch-tracked repos and fail when config metadata is stale.
