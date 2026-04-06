# Reference repos

Clone or update reference repos with:

```bash
clone:repos
```

They are stored under `.repos/`.

## Core SDK references

- `.repos/kit` — upstream TypeScript source from `anza-xyz/kit`
- `.repos/espresso-cash-public` — Dart Solana reference from `brij-digital/espresso-cash-public`
- `.repos/mobile-wallet-adapter` — Solana Mobile Wallet Adapter reference from `solana-mobile/mobile-wallet-adapter`

## solana-program/* references

Each program repo is pinned to a specific tag or commit. When a new version
ships upstream, update the pin in `devenv.nix` under `clone:repos`, run
`clone:repos`, regenerate the affected package with `codama-renderers-dart`,
bump the package version, and add a changeset.

| Path | Repo | Pinned version | Used by |
|------|------|---------------|---------|
| `.repos/solana-program/system` | [solana-program/system](https://github.com/solana-program/system) | `js@v0.12.0` | `solana_kit_system` (#131) |
| `.repos/solana-program/token` | [solana-program/token](https://github.com/solana-program/token) | `js@v0.13.0` | `solana_kit_token` |
| `.repos/solana-program/token-2022` | [solana-program/token-2022](https://github.com/solana-program/token-2022) | `js@v0.9.0` | `solana_kit_token_2022` |
| `.repos/solana-program/associated-token-account` | [solana-program/associated-token-account](https://github.com/solana-program/associated-token-account) | `program@v8.0.0` | `solana_kit_associated_token_account` (#132) — handwritten, use as interface reference |
| `.repos/solana-program/address-lookup-table` | [solana-program/address-lookup-table](https://github.com/solana-program/address-lookup-table) | `js@v0.11.0` | `solana_kit_address_lookup_table` (#134) |
| `.repos/solana-program/memo` | [solana-program/memo](https://github.com/solana-program/memo) | `js@v0.11.0` | `solana_kit_memo` (#135) |
| `.repos/solana-program/compute-budget` | [solana-program/compute-budget](https://github.com/solana-program/compute-budget) | `js@v0.15.0` | `solana_kit_compute_budget` (#133) |
| `.repos/solana-program/stake` | [solana-program/stake](https://github.com/solana-program/stake) | `js@v0.6.0` | `solana_kit_stake` (#136) |
| `.repos/solana-program/config` | [solana-program/config](https://github.com/solana-program/config) | `solana-config-program-client@v1.1.0` | `solana_kit_config` (#137) |
| `.repos/solana-program/loader-v3` | [solana-program/loader-v3](https://github.com/solana-program/loader-v3) | `js@v0.3.0` | `solana_kit_loader` (#138) |
| `.repos/solana-program/loader-v4` | [solana-program/loader-v4](https://github.com/solana-program/loader-v4) | commit `5df834d` (2026-03-08, no tag yet) | `solana_kit_loader` (#138) |

## Updating a pinned version

1. Find the new tag on the upstream repo (e.g. `js@v0.14.0`).
2. Update the tag string in `devenv.nix` under `clone:repos`.
3. Run `clone:repos` to fetch the new version.
4. Re-run the Codama generator for the affected Dart package.
5. Review the generated diff, update the package, bump version, add a changeset.
