# Publishing Guide

This guide covers how to version, release, and publish the `solana_kit` Dart SDK packages to [pub.dev](https://pub.dev/).

## Overview

<!-- workspace-summary:start -->

This monorepo contains **69 packages** under `packages/`: **67 publishable** and **2 internal** (`solana_kit_integration_tests`, `solana_kit_test_matchers`).

<!-- workspace-summary:end -->

Versioning is managed by [monochange](https://github.com/monochange/monochange) using changesets stored in `.changeset/`. Release PRs, release tags, GitHub release notes, and package publishing are executed through MonoChange's built-in release and publishing steps in GitHub Actions.

## Package Inventory

### Publishable Packages

| Layer | Package                                          | Dependencies                                                                                                                                                                          |
| ----- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0     | `solana_kit_errors`                              | (none)                                                                                                                                                                                |
| 1     | `solana_kit_functional`                          | errors                                                                                                                                                                                |
| 1     | `solana_kit_fast_stable_stringify`               | (none)                                                                                                                                                                                |
| 1     | `solana_kit_fixed_points`                        | (none)                                                                                                                                                                                |
| 1     | `solana_kit_helius`                              | errors                                                                                                                                                                                |
| 2     | `solana_kit_codecs_core`                         | errors                                                                                                                                                                                |
| 2     | `solana_kit_codecs_numbers`                      | codecs_core                                                                                                                                                                           |
| 2     | `solana_kit_codecs_strings`                      | codecs_core                                                                                                                                                                           |
| 2     | `solana_kit_codecs_data_structures`              | codecs_core, codecs_numbers                                                                                                                                                           |
| 2     | `solana_kit_options`                             | codecs_core, codecs_data_structures                                                                                                                                                   |
| 2     | `solana_kit_codecs`                              | (umbrella re-export of all codec packages)                                                                                                                                            |
| 3     | `solana_kit_addresses`                           | errors, codecs_strings                                                                                                                                                                |
| 3     | `solana_kit_keys`                                | errors, addresses, codecs_strings                                                                                                                                                     |
| 3     | `solana_kit_rpc_spec_types`                      | errors                                                                                                                                                                                |
| 3     | `solana_kit_rpc_types`                           | errors, addresses, codecs_strings                                                                                                                                                     |
| 3     | `solana_kit_mobile_wallet_adapter_protocol`      | errors, codecs_strings                                                                                                                                                                |
| 4     | `solana_kit_instructions`                        | errors, addresses                                                                                                                                                                     |
| 4     | `solana_kit_programs`                            | errors                                                                                                                                                                                |
| 4     | `solana_kit_rpc_spec`                            | errors, rpc_spec_types                                                                                                                                                                |
| 4     | `solana_kit_rpc_parsed_types`                    | addresses, rpc_types                                                                                                                                                                  |
| 4     | `solana_kit_rpc_transformers`                    | errors, rpc_spec_types, rpc_types                                                                                                                                                     |
| 4     | `solana_kit_rpc_transport_http`                  | errors, rpc_spec_types                                                                                                                                                                |
| 5     | `solana_kit_transaction_messages`                | errors, addresses, codecs, instructions, keys                                                                                                                                         |
| 5     | `solana_kit_offchain_messages`                   | errors, addresses, codecs, keys                                                                                                                                                       |
| 5     | `solana_kit_rpc_api`                             | addresses, rpc_spec, rpc_spec_types, rpc_types, rpc_parsed_types, rpc_transformers                                                                                                    |
| 5     | `solana_kit_subscribable`                        | errors                                                                                                                                                                                |
| 5     | `solana_kit_system`                              | addresses, codecs_core, codecs_data_structures, codecs_numbers, instructions                                                                                                          |
| 5     | `solana_kit_associated_token_account`            | addresses, codecs_core, codecs_data_structures, codecs_numbers, errors, instructions                                                                                                  |
| 5     | `solana_kit_address_lookup_table`                | addresses, codecs_core, codecs_data_structures, codecs_numbers, instructions                                                                                                          |
| 5     | `solana_kit_compute_budget`                      | addresses, codecs_core, codecs_data_structures, codecs_numbers, instructions                                                                                                          |
| 5     | `solana_kit_memo`                                | addresses, codecs_core, codecs_data_structures, codecs_strings, instructions                                                                                                          |
| 6     | `solana_kit_transactions`                        | errors, addresses, codecs, instructions, keys, transaction_messages                                                                                                                   |
| 6     | `solana_kit_rpc`                                 | rpc_api, rpc_spec, rpc_transport_http, rpc_transformers                                                                                                                               |
| 6     | `solana_kit_rpc_subscriptions_api`               | addresses, rpc_spec_types, rpc_types                                                                                                                                                  |
| 6     | `solana_kit_rpc_subscriptions_channel_websocket` | errors, rpc_spec_types                                                                                                                                                                |
| 7     | `solana_kit_signers`                             | errors, addresses, keys, transactions, transaction_messages                                                                                                                           |
| 7     | `solana_kit_accounts`                            | errors, addresses, codecs, rpc_api, rpc_spec, rpc_types                                                                                                                               |
| 7     | `solana_kit_sysvars`                             | errors, addresses, codecs, rpc_api, rpc_spec, rpc_types, accounts                                                                                                                     |
| 7     | `solana_kit_program_client_core`                 | errors, addresses, instructions, rpc_api, rpc_spec                                                                                                                                    |
| 7     | `solana_kit_rpc_subscriptions`                   | errors, rpc_spec_types, rpc_subscriptions_api, rpc_subscriptions_channel_websocket, subscribable                                                                                      |
| 7     | `solana_kit_mobile_wallet_adapter`               | addresses, errors, keys, mobile_wallet_adapter_protocol, transactions                                                                                                                 |
| 8     | `solana_kit_transaction_confirmation`            | addresses, errors, keys, rpc, rpc_api, rpc_spec, rpc_subscriptions_channel_websocket, rpc_types, subscribable, transactions                                                           |
| 8     | `solana_kit_instruction_plans`                   | errors, instructions, keys, transaction_messages, transactions                                                                                                                        |
| 8     | `solana_kit_config`                              | accounts, addresses, codecs_core, codecs_data_structures, codecs_numbers, instructions                                                                                                |
| 9     | `solana_kit_loader`                              | addresses, codecs_core, codecs_data_structures, codecs_numbers, instruction_plans, instructions                                                                                       |
| 9     | `solana_kit_spl_account_compression`             | accounts, addresses, codecs, codecs_core, codecs_data_structures, codecs_numbers, errors, instruction_plans, instructions, keys                                                       |
| 9     | `solana_kit_stake`                               | accounts, addresses, codecs_core, codecs_data_structures, codecs_numbers, codecs_strings, instruction_plans, instructions, system, sysvars                                            |
| 9     | `solana_kit_token`                               | accounts, addresses, associated_token_account, codecs_core, codecs_data_structures, codecs_numbers, codecs_strings, errors, instruction_plans, instructions, system                   |
| 9     | `solana_kit_token_2022`                          | accounts, addresses, associated_token_account, codecs_core, codecs_data_structures, codecs_numbers, codecs_strings, errors, instruction_plans, instructions, options, signers, system |
| 10    | `solana_kit_mpl_bubblegum`                       | accounts, addresses, codecs, codecs_core, codecs_data_structures, codecs_numbers, errors, instruction_plans, instructions, keys, spl_account_compression                              |
| 10    | `solana_kit`                                     | (umbrella re-export of all packages above)                                                                                                                                            |

### Internal Packages (not published)

| Package                    | Purpose                                  |
| -------------------------- | ---------------------------------------- |
| `solana_kit_lints`         | Shared lint rules (`very_good_analysis`) |
| `solana_kit_test_matchers` | Solana-specific test matchers            |

### Workspace Dependency Graph (generated)

Generated from package `pubspec.yaml` files with `dart run scripts/workspace_doc_drift.dart --write`.

<!-- workspace-dependency-graph:start -->

```text
solana_kit -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs, solana_kit_errors, solana_kit_fast_stable_stringify, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_keys, solana_kit_lints, solana_kit_offchain_messages, solana_kit_options, solana_kit_program_client_core, solana_kit_programs, solana_kit_rpc, solana_kit_rpc_api, solana_kit_rpc_parsed_types, solana_kit_rpc_spec, solana_kit_rpc_spec_types, solana_kit_rpc_subscriptions, solana_kit_rpc_subscriptions_channel_websocket, solana_kit_rpc_transport_http, solana_kit_rpc_types, solana_kit_signers, solana_kit_subscribable, solana_kit_surfpool, solana_kit_sysvars, solana_kit_transaction_confirmation, solana_kit_transaction_introspection, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_accounts -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_strings, solana_kit_errors, solana_kit_rpc, solana_kit_rpc_api, solana_kit_rpc_spec, solana_kit_rpc_types
solana_kit_address -> solana_kit_codecs_core, solana_kit_codecs_strings, solana_kit_errors
solana_kit_address_constants -> solana_kit_address
solana_kit_address_lookup_table -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_instructions, solana_kit_rpc_spec
solana_kit_addresses -> solana_kit_address, solana_kit_address_constants, solana_kit_codecs_core, solana_kit_codecs_strings, solana_kit_errors
solana_kit_anchor -> solana_kit_addresses, solana_kit_codecs, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors
solana_kit_associated_token_account -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_errors, solana_kit_instructions
solana_kit_codecs -> solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_fixed_points, solana_kit_options
solana_kit_codecs_core -> solana_kit_errors
solana_kit_codecs_data_structures -> solana_kit_codecs_core, solana_kit_codecs_numbers, solana_kit_errors
solana_kit_codecs_numbers -> solana_kit_codecs_core, solana_kit_errors
solana_kit_codecs_strings -> solana_kit_codecs_core, solana_kit_codecs_numbers, solana_kit_errors
solana_kit_compute_budget -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_errors, solana_kit_instructions, solana_kit_transaction_messages
solana_kit_config -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_instructions
solana_kit_errors -> (none)
solana_kit_fast_stable_stringify -> (none)
solana_kit_fixed_points -> (none)
solana_kit_functional -> (none)
solana_kit_helius -> solana_kit_addresses, solana_kit_associated_token_account, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_rpc, solana_kit_rpc_subscriptions_channel_websocket, solana_kit_signers, solana_kit_token, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_instruction_plans -> solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_signers, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_instructions -> solana_kit_addresses, solana_kit_errors
solana_kit_integration_tests -> solana_kit_accounts, solana_kit_address_constants, solana_kit_address_lookup_table, solana_kit_addresses, solana_kit_associated_token_account, solana_kit_codecs_core, solana_kit_compute_budget, solana_kit_config, solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_loader, solana_kit_memo, solana_kit_mpl_bubblegum, solana_kit_pyth, solana_kit_rpc, solana_kit_rpc_api, solana_kit_rpc_spec, solana_kit_rpc_types, solana_kit_signers, solana_kit_stake, solana_kit_subscriptions, solana_kit_surfpool, solana_kit_system, solana_kit_token, solana_kit_token_2022, solana_kit_transaction_confirmation, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_jupiter -> solana_kit_addresses, solana_kit_codecs_strings, solana_kit_errors, solana_kit_signers, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_keys -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_strings, solana_kit_errors
solana_kit_lints -> (none)
solana_kit_loader -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_instruction_plans, solana_kit_instructions
solana_kit_memo -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_strings, solana_kit_instructions
solana_kit_mobile_wallet_adapter -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_mobile_wallet_adapter_protocol, solana_kit_transactions
solana_kit_mobile_wallet_adapter_protocol -> solana_kit_codecs_strings, solana_kit_errors
solana_kit_mpl_bubblegum -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_keys, solana_kit_spl_account_compression
solana_kit_mpl_core -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_keys
solana_kit_mpl_token_metadata -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_keys
solana_kit_offchain_messages -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_keys
solana_kit_options -> solana_kit_codecs_core, solana_kit_codecs_numbers, solana_kit_errors
solana_kit_program_client_core -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs_core, solana_kit_errors, solana_kit_instructions, solana_kit_rpc_spec, solana_kit_rpc_types, solana_kit_signers
solana_kit_programs -> solana_kit_addresses, solana_kit_errors
solana_kit_pyth -> solana_kit_addresses, solana_kit_codecs, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_keys
solana_kit_rpc -> solana_kit_addresses, solana_kit_errors, solana_kit_fast_stable_stringify, solana_kit_keys, solana_kit_rpc_api, solana_kit_rpc_spec, solana_kit_rpc_spec_types, solana_kit_rpc_transformers, solana_kit_rpc_transport_http, solana_kit_rpc_types
solana_kit_rpc_api -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_rpc_parsed_types, solana_kit_rpc_spec, solana_kit_rpc_spec_types, solana_kit_rpc_transformers, solana_kit_rpc_types, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_rpc_parsed_types -> solana_kit_addresses, solana_kit_errors, solana_kit_rpc_types
solana_kit_rpc_spec -> solana_kit_errors, solana_kit_rpc_spec_types, solana_kit_subscribable
solana_kit_rpc_spec_types -> solana_kit_errors
solana_kit_rpc_subscriptions -> solana_kit_addresses, solana_kit_errors, solana_kit_fast_stable_stringify, solana_kit_keys, solana_kit_rpc_spec_types, solana_kit_rpc_subscriptions_api, solana_kit_rpc_subscriptions_channel_websocket, solana_kit_rpc_types, solana_kit_subscribable
solana_kit_rpc_subscriptions_api -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_rpc_types
solana_kit_rpc_subscriptions_channel_websocket -> solana_kit_errors, solana_kit_subscribable
solana_kit_rpc_transformers -> solana_kit_errors, solana_kit_rpc_spec_types, solana_kit_rpc_types
solana_kit_rpc_transport_http -> solana_kit_errors, solana_kit_rpc_spec, solana_kit_rpc_spec_types
solana_kit_rpc_types -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors
solana_kit_signers -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_sns -> solana_kit_addresses, solana_kit_codecs, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_keys
solana_kit_spl_account_compression -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_keys
solana_kit_squads -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_keys
solana_kit_stake -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_system, solana_kit_sysvars
solana_kit_subscribable -> solana_kit_errors
solana_kit_subscriptions -> solana_kit_accounts, solana_kit_address_constants, solana_kit_addresses, solana_kit_associated_token_account, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instructions
solana_kit_surfpool -> solana_kit_address_constants, solana_kit_addresses, solana_kit_associated_token_account, solana_kit_keys, solana_kit_rpc, solana_kit_rpc_api, solana_kit_rpc_spec, solana_kit_rpc_subscriptions, solana_kit_signers
solana_kit_system -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instructions
solana_kit_sysvars -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_errors, solana_kit_rpc_spec, solana_kit_rpc_types
solana_kit_test_matchers -> solana_kit_accounts, solana_kit_addresses, solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_rpc, solana_kit_rpc_spec, solana_kit_rpc_subscriptions, solana_kit_rpc_types, solana_kit_signers, solana_kit_subscribable, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_token -> solana_kit_accounts, solana_kit_addresses, solana_kit_associated_token_account, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_system
solana_kit_token_2022 -> solana_kit_accounts, solana_kit_addresses, solana_kit_associated_token_account, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_options, solana_kit_signers, solana_kit_system
solana_kit_transaction_confirmation -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_rpc, solana_kit_rpc_api, solana_kit_rpc_spec, solana_kit_rpc_subscriptions_channel_websocket, solana_kit_rpc_types, solana_kit_subscribable, solana_kit_transactions
solana_kit_transaction_introspection -> solana_kit_addresses, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instructions, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_transaction_messages -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instructions
solana_kit_transactions -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_transaction_messages
solana_kit_wallet_adapter -> solana_kit_addresses, solana_kit_codecs_strings, solana_kit_keys, solana_kit_mobile_wallet_adapter, solana_kit_mobile_wallet_adapter_protocol, solana_kit_signers, solana_kit_transactions, solana_kit_wallet_standard
solana_kit_wallet_standard -> (none)
solana_kit_wallet_ui -> solana_kit_wallet_adapter, solana_kit_wallet_standard
```

<!-- workspace-dependency-graph:end -->

## Managing Release

### Creating a Changeset

When making changes to any package, create a changeset file:

```bash
monochange run document
```

This is required for PRs that modify files under `packages/*` (CI enforces this with `Require changes to be documented`).

This interactively creates a Markdown file in `.changeset/` with a release note description. Use YAML frontmatter keyed by monochange package ids:

```markdown
---
"solana_kit_rpc": minor
---

Add support for program derived addresses with custom seeds.
```

Use monochange package ids from `monochange.toml` in changeset frontmatter. For lockstep Dart releases, listing the affected package ids is enough; `group.main` propagates the bump to the grouped packages.

Bump types:

- `patch` - Bug fixes, documentation changes
- `minor` - New features, backwards-compatible additions
- `major` - Breaking changes

### Preparing a Release

Release preparation is driven locally. `monochange run release --commit --tag --push`:

1. Reads all changeset files in `.changeset/`
2. Bumps versions in each package's `pubspec.yaml`
3. Updates each package's `CHANGELOG.md`
4. Refreshes lockfiles and generated release documentation
5. Commits the release changes and pushes the MonoChange release tags (the primary `v*` tag plus scoped `<id>/v*` tags for independently versioned targets)

Review the generated versions and release notes with the dry run before running the real release.

For local previewing, use dry runs only:

```bash
monochange run release --dry-run --diff
monochange step publish-packages --dry-run --all --format json
```

### Publishing with monochange

Package publishing is handled by `.github/workflows/publish.yml`, triggered by pushing a release tag. pub.dev Trusted Publishing validates the triggering tag against the version being published, so each version group publishes from its own release tag:

- Primary group packages (lockstep releases) tag as `v{{version}}` (for example `v0.9.1`). Their run is the release orchestrator.
- Independently versioned packages tag as `<id>/v{{version}}` (for example `solana_kit_token/v0.8.1`) and are published by child runs that the orchestrator dispatches.

The run triggered by the primary tag orchestrates the whole release:

1. It resolves the MonoChange release record and the workspace dependency graph with `.github/scripts/publish_scope.py`.
2. It publishes the primary group's packages in dependency order.
3. Whenever a package depends on an independently versioned package in the same release, it dispatches an awaited `workflow_dispatch` child run for that package's release tag, so sibling versions are on pub.dev before their dependents publish.
4. After the last batch, it publishes the GitHub release objects.

Child runs publish only the packages owned by their own release tag. To rerun publishing for an existing release tag, dispatch the `publish` workflow with that tag:

```bash
gh workflow run publish --ref v0.9.1
gh workflow run publish --ref solana_kit_token/v0.8.1 -f tag=solana_kit_token/v0.8.1
```

Pushing a namespaced tag alone does not trigger publishing; publishing is orchestrated from the primary tag.

Important requirements before running publish workflows:

- The release commit must include a valid MonoChange release record.
- Every release tag must point at a commit reachable from `origin/main`.
- pub.dev Trusted Publishing must be configured per package at `https://pub.dev/packages/<name>/admin`: repository `openbudgetfun/solana_kit`, tag pattern `v{{version}}` for primary group packages or `<name>/v{{version}}` for independently versioned packages, the `publisher` GitHub environment required, and `workflow_dispatch` events allowed (child runs and manual retries are dispatched runs).
- npm Trusted Publishing must list `.github/workflows/publish.yml` for `codama-renderers-dart`.
- Each package `CHANGELOG.md` must contain the current package version heading.

For local verification from a release commit or checked-out release tag, run:

```bash
monochange step release-record --from HEAD --format json
monochange step publish-readiness --from HEAD --format json
monochange step publish-packages --dry-run --format json
```

For large publish sets, use MonoChange readiness output and registry rate-limit planning to decide whether the release needs operational monitoring:

```bash
monochange step plan-publish-rate-limits --from HEAD --format md
```

The CI publish workflow uses MonoChange's built-in package publishing so Dart packages are published via pub.dev Trusted Publishing and the NPM renderer package is published with provenance enabled.

After publishing completes, verify published versions on pub.dev before continuing.

## Publishing to pub.dev

### Pre-Publish Checklist

Before publishing, verify each package meets these requirements:

1. **pubspec.yaml** is complete:
   - `name` matches the package directory name
   - `description` is 60-180 characters
   - `version` follows semver
   - `repository` points to the GitHub repo
   - `homepage` or `documentation` URL is set
   - `environment.sdk` constraint is set
   - Dependencies use caret constraints (`^x.y.z`) for published packages
   - No `publish_to: none` (unless intentionally unpublished)

2. **README.md** exists with:
   - Package purpose and features
   - Installation instructions
   - Basic usage example
   - Link to API docs

3. **CHANGELOG.md** exists and is up to date (managed by monochange)

4. **LICENSE** file exists at the repo root (applies to all packages)

5. **No workspace resolution in published packages**:
   - The `resolution: workspace` field in `pubspec.yaml` is used for local development
   - Before publishing, this must be removed or the workspace constraint must be resolved
   - Dart 3.10+ workspace packages resolve dependencies from the root `pubspec.yaml`
   - When publishing, `dart pub publish` handles workspace resolution automatically

6. **Analysis is clean**:
   ```bash
   dart analyze packages/<package_name>
   ```

7. **Tests pass**:
   ```bash
   dart test packages/<package_name>
   ```

8. **Formatting is correct**:
   ```bash
   dprint check
   ```

### Dependency-Order Publishing

Packages must be published in dependency order (leaf packages first). `monochange step publish-packages` handles dependency ordering from the workspace package graph, so maintainers should not manually sequence packages except when intentionally following a registry rate-limit plan.

The expected publishing order follows the layer table above:

1. Layer 0: `solana_kit_errors`
2. Layer 1: `solana_kit_functional`, `solana_kit_fast_stable_stringify`, `solana_kit_fixed_points`
3. Layer 2: Codec packages (`codecs_core` -> `codecs_numbers`, `codecs_strings` -> `codecs_data_structures` -> `options` -> `codecs`)
4. Layer 3+: Address, keys, RPC types
5. Continue upward through the dependency graph
6. Layer 10: `solana_kit` umbrella package (published last)

### Running the Publish Workflow

The normal path is the release tag push: `monochange run release --commit --tag --push` creates the release tags, and the primary `v*` tag triggers the orchestrator run, which publishes every package in the release record. If maintainers need to rerun publishing for an existing release tag, dispatch the `publish` workflow with that tag (see the commands above).

For a local dry run from the release commit or checked-out release tag:

```bash
monochange step publish-readiness --from HEAD --format json
monochange step publish-packages --dry-run --format json
```

## Known Issues and Considerations

### Large Monorepo Concerns

1. **Namespace reservation**: All packages use the `solana_kit_` prefix. Once the first package is published, the namespace is effectively reserved. Ensure the verified publisher account is set up before initial publish.

2. **pub.dev rate limits**: Publishing many packages in quick succession may trigger limits. For large releases, use `monochange step plan-publish-rate-limits --from HEAD --format md` and monitor the publish workflow output.

3. **Verified publisher**: Set up a [verified publisher](https://dart.dev/tools/pub/verified-publishers) on pub.dev before publishing. This displays a verified badge and prevents package name squatting. All packages should be published under the same verified publisher.

4. **Workspace resolution**: Dart 3.10+ workspaces use `resolution: workspace` in each package's `pubspec.yaml`. This is valid for development but the resolver handles it correctly during `dart pub publish`. The workspace root's `pubspec.yaml` has `publish_to: none` so it is never published.

5. **Dependency constraints for publishing**: When packages are published, their inter-package dependencies must use caret syntax (for this release, `^0.1.0`) rather than path dependencies. The Dart workspace system handles this automatically -- packages within the workspace resolve to local paths during development but use version constraints when published.

6. **Rollback procedures**: If a published version has a critical bug:
   - Publish a patch version with the fix
   - Use `dart pub retract` to retract the broken version (it remains downloadable but shows a warning)
   - Retracted versions cannot be re-used; always increment the version

7. **Package scoring (pana)**: pub.dev scores packages using the [pana](https://pub.dev/packages/pana) tool. To maximize scores:
   - Ensure all documentation is complete
   - Provide example files in `example/`
   - Maintain high test coverage
   - Keep dependencies up to date
   - Support all platforms (vm, web, wasm) where applicable

### Workspace-Specific Publishing Notes

- The root `pubspec.yaml` has `publish_to: none` and is not published
- `solana_kit_lints` has `publish_to: none` (internal lint rules)
- `solana_kit_test_matchers` has `publish_to: none` (test utilities)
- All other packages are publishable

### First-Time Publishing Checklist

Before the very first publish of any package:

1. Create a [pub.dev](https://pub.dev/) account
2. Set up a [verified publisher](https://dart.dev/tools/pub/verified-publishers)
3. Configure pub.dev Trusted Publishing for each package at `https://pub.dev/packages/<name>/admin`: repository `openbudgetfun/solana_kit`, tag pattern `v{{version}}` for primary group packages or `<name>/v{{version}}` for independently versioned packages, the `publisher` environment, and `workflow_dispatch` events allowed
4. Verify all packages pass `dart pub publish --dry-run`
5. Publish packages by pushing the release tags (the primary `v*` tag triggers the orchestrator run)
6. Verify each package appears on pub.dev after the workflow completes
7. After all packages are published, verify the umbrella `solana_kit` package correctly resolves all dependencies from pub.dev

### Release and Publishing Integration

The release flow is automated with MonoChange and GitHub Actions while staying review-first:

1. **PR merged to main**: CI checks run (analyze, test, format, changeset enforcement, docs drift check)
2. **Release preparation**: Maintainers run `monochange run release --commit --tag --push`, which prepares versions, changelogs, lockfiles, docs, and a MonoChange release commit, then pushes the MonoChange release tags
3. **Publish orchestration**: The primary `v*` tag push triggers `.github/workflows/publish.yml`. The run checks out the tag, verifies readiness, publishes the primary group's packages, and dispatches awaited child runs for each independently versioned release target in dependency order
4. **GitHub releases**: The orchestrator publishes the GitHub release objects after the last publish batch
5. **Verification**: Check pub.dev for all packages with correct versions and smoke test a clean consumer project

Keep pub.dev Trusted Publishing entries aligned with `.github/workflows/publish.yml` and its `publisher` GitHub environment: per-package tag patterns (`v{{version}}` for primary group packages, `<name>/v{{version}}` for independently versioned packages) and `workflow_dispatch` events allowed. Keep public release notes focused on consumer-visible changes, minimum SDK constraints, and migration steps.
