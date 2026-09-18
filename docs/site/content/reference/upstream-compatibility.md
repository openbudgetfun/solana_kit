---
title: Upstream Compatibility
description: How this workspace tracks @solana/kit compatibility.
---

<!-- {=docsUpstreamCompatibilitySection} -->

## Upstream Compatibility

- Latest supported `@solana/kit` version: `8.3.0`
- This Dart port tracks upstream APIs and behavior through `v8.3.0`.

<!-- {/docsUpstreamCompatibilitySection} -->

## Version parity

Each row pairs a published `solana_kit` release with the upstream `@solana/kit` version it tracks. Use the row that matches your Dart dependency to know which upstream release its APIs and behavior correspond to. The `solana_kit` version is the workspace compatibility marker; the other packages release independently.

<!-- upstream-parity:start -->
<!-- dprint-ignore -->
| `solana_kit` | `@solana/kit` | Released   |
| ------------ | ------------- | ---------- |
| `0.9.3`      | `8.2.0`       | 2026-09-12 |
| `0.9.2`      | `8.2.0`       | 2026-09-06 |
| `0.9.1`      | `8.1.0`       | 2026-08-30 |
| `0.8.0`      | `7.1.0`       | 2026-08-19 |
| `0.7.0`      | `7.1.0`       | 2026-08-18 |
| `0.6.0`      | `6.10.0`      | 2026-08-13 |
| `0.5.0`      | `6.9.0`       | 2026-06-01 |
| `0.4.0`      | `6.9.0`       | 2026-05-30 |
| `0.3.1`      | `6.5.0`       | 2026-03-30 |
| `0.3.0`      | `6.5.0`       | 2026-03-29 |
| `0.2.1`      | `6.1.0`       | 2026-02-28 |
| `0.2.0`      | —             | 2026-02-28 |
| `0.1.0`      | —             | 2026-02-25 |

<!-- upstream-parity:end -->

## Upstream client pins

The upstream clients and IDLs the current release was generated and verified against. Tag pins are fixed; branch and commit pins are moving or unversioned upstream refs (`clone:repos` materializes them under `.repos/`, and the short revision records the last checked commit).

<!-- upstream-pins:start -->
<!-- dprint-ignore -->
| Upstream repository                                                                           | Pin                                                       | Dart package(s)                                                                 |
| --------------------------------------------------------------------------------------------- | --------------------------------------------------------- | ------------------------------------------------------------------------------- |
| [kit](https://github.com/anza-xyz/kit)                                                        | `v8.3.0`                                                  | `solana_kit`                                                                    |
| [espresso-cash-public](https://github.com/brij-digital/espresso-cash-public)                  | `master` (77150680d6bf)                                   | —                                                                               |
| [helius-sdk](https://github.com/helius-labs/helius-sdk)                                       | `v3.2.0`                                                  | `solana_kit_helius`                                                             |
| [mobile-wallet-adapter](https://github.com/solana-mobile/mobile-wallet-adapter)               | `@solana-mobile/mobile-wallet-adapter-protocol-kit@0.4.0` | `solana_kit_mobile_wallet_adapter`, `solana_kit_mobile_wallet_adapter_protocol` |
| [system](https://github.com/solana-program/system)                                            | `js@v0.14.1`                                              | `solana_kit_system`                                                             |
| [token](https://github.com/solana-program/token)                                              | `js@v0.16.1`                                              | `solana_kit_token`                                                              |
| [token-2022](https://github.com/solana-program/token-2022)                                    | `js@v0.18.0`                                              | `solana_kit_token_2022`                                                         |
| [subscriptions](https://github.com/solana-foundation/subscriptions)                           | `ts-client-v0.5.0`                                        | `solana_kit_subscriptions`                                                      |
| [associated-token-account](https://github.com/solana-program/associated-token-account)        | `program@v8.0.0`                                          | `solana_kit_associated_token_account`                                           |
| [address-lookup-table](https://github.com/solana-program/address-lookup-table)                | `js@v0.14.1`                                              | `solana_kit_address_lookup_table`                                               |
| [memo](https://github.com/solana-program/memo)                                                | `js@v0.14.1`                                              | `solana_kit_memo`                                                               |
| [compute-budget](https://github.com/solana-program/compute-budget)                            | `js@v0.18.1`                                              | `solana_kit_compute_budget`                                                     |
| [stake](https://github.com/solana-program/stake)                                              | `js@v0.9.1`                                               | `solana_kit_stake`                                                              |
| [config](https://github.com/solana-program/config)                                            | `solana-config-program-client@v1.1.0`                     | `solana_kit_config`                                                             |
| [loader-v3](https://github.com/solana-program/loader-v3)                                      | `js@v0.6.1`                                               | `solana_kit_loader`                                                             |
| [loader-v4](https://github.com/solana-program/loader-v4)                                      | `5bb854dbd2b6`                                            | `solana_kit_loader`                                                             |
| [account-compression](https://github.com/solana-program/account-compression)                  | `ac-mainnet-tag` (b229799e395c)                           | `solana_kit_spl_account_compression`                                            |
| [mpl-bubblegum](https://github.com/metaplex-foundation/mpl-bubblegum)                         | `07180c737ebd`                                            | `solana_kit_mpl_bubblegum`                                                      |
| [mpl-token-metadata](https://github.com/metaplex-foundation/mpl-token-metadata)               | `353d01be4af3`                                            | `solana_kit_mpl_token_metadata`                                                 |
| [mpl-core](https://github.com/metaplex-foundation/mpl-core)                                   | `release/core@0.15.2`                                     | `solana_kit_mpl_core`                                                           |
| [squads-v4](https://github.com/Squads-Protocol/v4)                                            | `af94153ff77a`                                            | `solana_kit_squads`                                                             |
| [solana-attestation-service](https://github.com/solana-foundation/solana-attestation-service) | `5b64cf09843d`                                            | `solana_kit_attestation_service`                                                |

<!-- upstream-pins:end -->

## Upstream refs by release

Which upstream ref each `solana_kit` release was generated and verified against. Cell values are the ref recorded in `config/reference-repos.json` at that release; `—` means the repository was not tracked yet. Branch pins include the short revision that was last checked, so they can be compared across releases even though the branch itself moves.

<!-- upstream-repo-pins:start -->

#### Solana program clients

<!-- dprint-ignore -->
| `solana_kit` | system       | token        | token-2022   | address-lookup-table | memo         | compute-budget | stake       | config                                | loader-v3   | loader-v4      | associated-token-account | account-compression             |
| ------------ | ------------ | ------------ | ------------ | -------------------- | ------------ | -------------- | ----------- | ------------------------------------- | ----------- | -------------- | ------------------------ | ------------------------------- |
| `0.9.3`      | `js@v0.14.1` | `js@v0.16.1` | `js@v0.16.1` | `js@v0.14.1`         | `js@v0.13.1` | `js@v0.18.1`   | `js@v0.9.1` | `solana-config-program-client@v1.1.0` | `js@v0.6.1` | `4f62fb2e25c8` | `program@v8.0.0`         | `ac-mainnet-tag @ b229799e395c` |
| `0.9.2`      | `js@v0.14.1` | `js@v0.16.1` | `js@v0.16.1` | `js@v0.14.1`         | `js@v0.13.1` | `js@v0.18.1`   | `js@v0.9.1` | `solana-config-program-client@v1.1.0` | `js@v0.6.1` | `4f62fb2e25c8` | `program@v8.0.0`         | `ac-mainnet-tag @ b229799e395c` |
| `0.9.1`      | `js@v0.14.0` | `js@v0.16.0` | `js@v0.16.0` | `js@v0.14.0`         | `js@v0.13.0` | `js@v0.18.0`   | `js@v0.9.0` | `solana-config-program-client@v1.1.0` | `js@v0.6.0` | `4f62fb2e25c8` | `program@v8.0.0`         | `ac-mainnet-tag @ b229799e395`  |
| `0.9.0`      | `js@v0.14.0` | `js@v0.16.0` | `js@v0.16.0` | `js@v0.14.0`         | `js@v0.13.0` | `js@v0.18.0`   | `js@v0.9.0` | `solana-config-program-client@v1.1.0` | `js@v0.6.0` | `4f62fb2e25c8` | `program@v8.0.0`         | `ac-mainnet-tag @ b229799e395`  |
| `0.8.0`      | `js@v0.13.0` | `js@v0.15.0` | `js@v0.14.1` | `js@v0.13.0`         | `js@v0.12.0` | `js@v0.17.0`   | `js@v0.8.0` | `solana-config-program-client@v1.1.0` | `js@v0.5.0` | `1d6335be`     | `program@v8.0.0`         | `ac-mainnet-tag @ b229799e395`  |
| `0.7.0`      | `js@v0.13.0` | `js@v0.15.0` | `js@v0.14.1` | `js@v0.13.0`         | `js@v0.12.0` | `js@v0.17.0`   | `js@v0.8.0` | `solana-config-program-client@v1.1.0` | `js@v0.5.0` | `1d6335be`     | `program@v8.0.0`         | `ac-mainnet-tag @ b229799e395`  |
| `0.6.0`      | `js@v0.12.2` | `js@v0.14.0` | `js@v0.12.0` | `js@v0.12.1`         | `js@v0.11.2` | `js@v0.16.0`   | `js@v0.7.2` | `solana-config-program-client@v1.1.0` | `js@v0.4.0` | `5df834d`      | `program@v8.0.0`         | `ac-mainnet-tag @ b229799e395`  |
| `0.5.0`      | `js@v0.12.0` | `js@v0.13.0` | `js@v0.9.0`  | `js@v0.11.0`         | `js@v0.11.0` | `js@v0.15.0`   | `js@v0.6.0` | `solana-config-program-client@v1.1.0` | `js@v0.3.0` | `5df834d`      | `program@v8.0.0`         | `main`                          |
| `0.4.0`      | `js@v0.12.0` | `js@v0.13.0` | `js@v0.9.0`  | `js@v0.11.0`         | `js@v0.11.0` | `js@v0.15.0`   | `js@v0.6.0` | `solana-config-program-client@v1.1.0` | `js@v0.3.0` | `5df834d`      | `program@v8.0.0`         | `main`                          |

#### Solana Foundation programs

<!-- dprint-ignore -->
| `solana_kit` | subscriptions           | solana-attestation-service |
| ------------ | ----------------------- | -------------------------- |
| `0.9.3`      | `ts-client-v0.5.0`      | `5b64cf09843d`             |
| `0.9.2`      | `ts-client-v0.5.0`      | —                          |
| `0.9.1`      | `ts-client-v0.5.0`      | —                          |
| `0.9.0`      | `ts-client-v0.5.0`      | —                          |
| `0.8.0`      | `ts-client-v0.5.0`      | —                          |
| `0.7.0`      | `ts-client-v0.5.0`      | —                          |
| `0.6.0`      | `ts-client-v0.4.0-rc.2` | —                          |
| `0.5.0`      | —                       | —                          |
| `0.4.0`      | —                       | —                          |

#### Metaplex programs

<!-- dprint-ignore -->
| `solana_kit` | mpl-bubblegum         | mpl-token-metadata | mpl-core       |
| ------------ | --------------------- | ------------------ | -------------- |
| `0.9.3`      | `6a6a77e341a3`        | `349e061053c6`     | `2181404f90c7` |
| `0.9.2`      | `6a6a77e341a3`        | `349e061053c6`     | `2181404f90c7` |
| `0.9.1`      | `6a6a77e341a3`        | `349e061053c6`     | `2181404f90c7` |
| `0.9.0`      | `6a6a77e341a3`        | `349e061053c6`     | `2181404f90c7` |
| `0.8.0`      | `68e4bc204099`        | —                  | —              |
| `0.7.0`      | `68e4bc204099`        | —                  | —              |
| `0.6.0`      | `main @ 02c16414e4e0` | —                  | —              |
| `0.5.0`      | `main`                | —                  | —              |
| `0.4.0`      | `main`                | —                  | —              |

#### Wallet and SDK references

<!-- dprint-ignore -->
| `solana_kit` | mobile-wallet-adapter | helius-sdk     | squads-v4      | kit                   | espresso-cash-public    |
| ------------ | --------------------- | -------------- | -------------- | --------------------- | ----------------------- |
| `0.9.3`      | `8642fa3e1edb`        | `ad8f796d81be` | `af94153ff77a` | `main @ 6c1bc6e6aa96` | `master @ 77150680d6bf` |
| `0.9.2`      | `8642fa3e1edb`        | `ad8f796d81be` | `af94153ff77a` | `main @ 6c1bc6e6aa96` | `master @ 77150680d6bf` |
| `0.9.1`      | `8642fa3e1edb`        | `ad8f796d81be` | `af94153ff77a` | `main @ bb54243d8a57` | `master @ 77150680d6bf` |
| `0.9.0`      | `8642fa3e1edb`        | `ad8f796d81be` | `af94153ff77a` | `main @ bb54243d8a57` | `master @ 77150680d6bf` |
| `0.8.0`      | `8642fa3e1edb`        | `4c0c55b86eab` | —              | `main @ 661554c4e85f` | `master @ 77150680d6bf` |
| `0.7.0`      | `8642fa3e1edb`        | `4c0c55b86eab` | —              | `main @ 661554c4e85f` | `master @ 77150680d6bf` |
| `0.6.0`      | `main @ bed51fa2f177` | `4c0c55b86eab` | —              | `main @ 6cd177b14bed` | `master @ 77150680d6bf` |
| `0.5.0`      | `main`                | `4c0c55b86eab` | —              | `main`                | `main`                  |
| `0.4.0`      | `main`                | —              | —              | `main`                | `main`                  |

<!-- upstream-repo-pins:end -->

<!-- {=parityStatusCalloutSection|replace:"PARITY_STATUS_TOKEN":"Executable parity currently covers stable, CI-cheap surfaces: address/signature validation, derivation, transaction message compilation, wire serialization, and selected invalid-input error codes."|replace:"PARITY_NEXT_TOKEN":"Live RPC timing, subscription transport behavior, mobile platform adapters, and other intentionally documented divergences remain tracked separately rather than being implied by the current harness."} -->

> **Parity status**
>
> Executable parity currently covers stable, CI-cheap surfaces: address/signature validation, derivation, transaction message compilation, wire serialization, and selected invalid-input error codes.
>
> Live RPC timing, subscription transport behavior, mobile platform adapters, and other intentionally documented divergences remain tracked separately rather than being implied by the current harness.

<!-- {/parityStatusCalloutSection} -->

## Validation Workflow

- Keep `.repos/kit` updated (`clone:repos`).
- Run `upstream:check` to verify tracked compatibility metadata remains internally consistent.
- Run `upstream:parity` to install the tracked `@solana/kit` release in a local cache, generate runtime fixtures, and compare selected Dart behaviors against upstream.
- Record intentional deviations and migration notes.
- Re-run benchmarks after major upstream alignment changes.

## Current Executable Parity Scope

The first harness focuses on stable, high-signal surfaces that are cheap to run in CI:

- address validation and coercion semantics
- address encoding and derivation helpers
- signature validation/coercion semantics
- signer deduplication and assertion context parity
- transaction message v1 compilation and wire serialization
- transaction message v0 compilation and wire serialization
- transaction size limits (legacy, v0, v1)
- transaction message size limit version-aware helpers
- error-code parity for selected invalid inputs
- JSON-RPC error BigInt code support
- sendTransaction preflight context defaults
- simulateTransaction metadata defaults
- compute-unit helpers (set/limit estimation)
- SOL/Lamports type helpers
- reactive store and slot-tracking subscription helpers
- abortable websocket subscription helpers
- key-pair writing and grinding helpers
- fixed-point binary/decimal arithmetic
- vote-account Agave v3 parsed types
- client/plugin composition helpers
- instruction-plan version-aware size compatibility

The harness intentionally does **not** yet cover live RPC behavior, subscription transport timing, mobile-wallet platform adapters, Helius-specific extensions, or stricter Dart-only transaction-construction invariants such as requiring an explicit lifetime before compilation. Those remain tracked separately in the roadmap and issue set.

## Versioning Guidance

When upstream introduces breaking API behavior, prefer explicit compatibility notes and migration docs over silent behavior changes.
