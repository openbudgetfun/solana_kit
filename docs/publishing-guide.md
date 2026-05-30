# Publishing Guide

This guide covers how to version, release, and publish the `solana_kit` Dart SDK packages to [pub.dev](https://pub.dev/).

## Overview

<!-- workspace-summary:start -->

This monorepo contains **51 packages** under `packages/`: **49 publishable** and **2 internal** (`solana_kit_lints`, `solana_kit_test_matchers`).

<!-- workspace-summary:end -->

Versioning is managed by [monochange](https://github.com/monochange/monochange) using changesets stored in `.changeset/`. Release PRs, release tags, GitHub release notes, and package publishing are executed through the configured `mc` workflows in `monochange.toml`.

## Package Inventory

### Publishable Packages (41)

| Layer | Package                                          | Dependencies                                                                                                                                                                          |
| ----- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0     | `solana_kit_errors`                              | (none)                                                                                                                                                                                |
| 1     | `solana_kit_functional`                          | errors                                                                                                                                                                                |
| 1     | `solana_kit_fast_stable_stringify`               | (none)                                                                                                                                                                                |
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
| 5     | `solana_kit_compute_budget`                      | addresses, codecs_core, codecs_data_structures, codecs_numbers, instructions                                                                                                          |
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
| 9     | `solana_kit_stake`                               | accounts, addresses, codecs_core, codecs_data_structures, codecs_numbers, codecs_strings, instruction_plans, instructions, system, sysvars                                            |
| 9     | `solana_kit_token`                               | accounts, addresses, associated_token_account, codecs_core, codecs_data_structures, codecs_numbers, codecs_strings, errors, instruction_plans, instructions, system                   |
| 9     | `solana_kit_token_2022`                          | accounts, addresses, associated_token_account, codecs_core, codecs_data_structures, codecs_numbers, codecs_strings, errors, instruction_plans, instructions, options, signers, system |
| 9     | `solana_kit`                                     | (umbrella re-export of all packages above)                                                                                                                                            |

### Internal Packages (not published)

| Package                    | Purpose                                  |
| -------------------------- | ---------------------------------------- |
| `solana_kit_lints`         | Shared lint rules (`very_good_analysis`) |
| `solana_kit_test_matchers` | Solana-specific test matchers            |

### Workspace Dependency Graph (generated)

Generated from package `pubspec.yaml` files with `scripts/workspace-doc-drift.sh --write`.

<!-- workspace-dependency-graph:start -->

```text
solana_kit -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs, solana_kit_errors, solana_kit_fast_stable_stringify, solana_kit_functional, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_keys, solana_kit_offchain_messages, solana_kit_options, solana_kit_program_client_core, solana_kit_programs, solana_kit_rpc, solana_kit_rpc_parsed_types, solana_kit_rpc_spec_types, solana_kit_rpc_subscriptions, solana_kit_rpc_transport_http, solana_kit_rpc_types, solana_kit_signers, solana_kit_subscribable, solana_kit_sysvars, solana_kit_transaction_confirmation, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_accounts -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_strings, solana_kit_errors, solana_kit_rpc, solana_kit_rpc_api, solana_kit_rpc_spec, solana_kit_rpc_types
solana_kit_addresses -> solana_kit_codecs_core, solana_kit_codecs_strings, solana_kit_errors
solana_kit_associated_token_account -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_errors, solana_kit_instructions
solana_kit_codecs -> solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_fixed_points, solana_kit_options
solana_kit_codecs_core -> solana_kit_errors
solana_kit_codecs_data_structures -> solana_kit_codecs_core, solana_kit_codecs_numbers, solana_kit_errors
solana_kit_codecs_numbers -> solana_kit_codecs_core, solana_kit_errors
solana_kit_codecs_strings -> solana_kit_codecs_core, solana_kit_codecs_numbers, solana_kit_errors
solana_kit_compute_budget -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_instructions
solana_kit_config -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_instructions
solana_kit_errors -> (none)
solana_kit_fast_stable_stringify -> (none)
solana_kit_fixed_points -> (none)
solana_kit_functional -> (none)
solana_kit_helius -> solana_kit_errors
solana_kit_instruction_plans -> solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_signers, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_instructions -> solana_kit_addresses, solana_kit_errors
solana_kit_keys -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_strings, solana_kit_errors
solana_kit_lints -> (none)
solana_kit_loader -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_instruction_plans, solana_kit_instructions
solana_kit_memo -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_strings, solana_kit_instructions
solana_kit_mobile_wallet_adapter -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_mobile_wallet_adapter_protocol, solana_kit_transactions
solana_kit_mobile_wallet_adapter_protocol -> solana_kit_codecs_strings, solana_kit_errors
solana_kit_mpl_bubblegum -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_keys, solana_kit_spl_account_compression
solana_kit_offchain_messages -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_keys
solana_kit_options -> solana_kit_codecs_core, solana_kit_codecs_numbers, solana_kit_errors
solana_kit_program_client_core -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs_core, solana_kit_errors, solana_kit_instructions, solana_kit_rpc_spec, solana_kit_rpc_types, solana_kit_signers
solana_kit_programs -> solana_kit_addresses, solana_kit_errors
solana_kit_rpc -> solana_kit_addresses, solana_kit_errors, solana_kit_fast_stable_stringify, solana_kit_keys, solana_kit_rpc_api, solana_kit_rpc_spec, solana_kit_rpc_spec_types, solana_kit_rpc_transformers, solana_kit_rpc_transport_http, solana_kit_rpc_types
solana_kit_rpc_api -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_rpc_parsed_types, solana_kit_rpc_spec, solana_kit_rpc_spec_types, solana_kit_rpc_transformers, solana_kit_rpc_types, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_rpc_parsed_types -> solana_kit_addresses, solana_kit_errors, solana_kit_rpc_types
solana_kit_rpc_spec -> solana_kit_errors, solana_kit_rpc_spec_types
solana_kit_rpc_spec_types -> solana_kit_errors
solana_kit_rpc_subscriptions -> solana_kit_addresses, solana_kit_errors, solana_kit_fast_stable_stringify, solana_kit_keys, solana_kit_rpc_spec_types, solana_kit_rpc_subscriptions_api, solana_kit_rpc_subscriptions_channel_websocket, solana_kit_rpc_types, solana_kit_subscribable
solana_kit_rpc_subscriptions_api -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_rpc_types
solana_kit_rpc_subscriptions_channel_websocket -> solana_kit_errors, solana_kit_subscribable
solana_kit_rpc_transformers -> solana_kit_errors, solana_kit_rpc_spec_types, solana_kit_rpc_types
solana_kit_rpc_transport_http -> solana_kit_errors, solana_kit_rpc_spec, solana_kit_rpc_spec_types
solana_kit_rpc_types -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors
solana_kit_signers -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_spl_account_compression -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_keys
solana_kit_subscribable -> solana_kit_errors
solana_kit_system -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_instructions
solana_kit_stake -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_system, solana_kit_sysvars
solana_kit_sysvars -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_errors, solana_kit_rpc_spec, solana_kit_rpc_types
solana_kit_test_matchers -> solana_kit_accounts, solana_kit_addresses, solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_rpc, solana_kit_rpc_spec, solana_kit_rpc_subscriptions, solana_kit_rpc_types, solana_kit_signers, solana_kit_subscribable, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_token -> solana_kit_accounts, solana_kit_addresses, solana_kit_associated_token_account, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_system
solana_kit_token_2022 -> solana_kit_accounts, solana_kit_addresses, solana_kit_associated_token_account, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_options, solana_kit_signers, solana_kit_system
solana_kit_transaction_confirmation -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_rpc, solana_kit_rpc_api, solana_kit_rpc_spec, solana_kit_rpc_subscriptions_channel_websocket, solana_kit_rpc_types, solana_kit_subscribable, solana_kit_transactions
solana_kit_transaction_messages -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instructions
solana_kit_transactions -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_transaction_messages
```

<!-- workspace-dependency-graph:end -->

## Managing Release

### Creating a Changeset

When making changes to any package, create a changeset file:

```bash
mc document
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

When ready to release, run:

```bash
mc release --commit --push --tag --publish-release
```

This workflow:

1. Reads all changeset files in `.changeset/`
2. Bumps versions in each package's `pubspec.yaml`
3. Updates each package's `CHANGELOG.md`
4. Formats with dprint
5. Commits and pushes
6. Creates a GitHub release

### Publishing with monochange

Use a dry run before any real publish:

```bash
mc step:publish-readiness --from HEAD --format json
mc publish --dry-run
```

Important requirements before running publish workflows:

- The git worktree must be clean. `pub publish --dry-run` returns a non-zero exit code when warnings are present, including "checked-in file is modified in git".
- Each package `CHANGELOG.md` must contain the current package version heading (for this release: `0.1.0`).

For the first release, publish in staged workflows to handle pub.dev limits:

```bash
mc step:plan-publish-rate-limits --from HEAD --format md
mc publish --dry-run
mc publish
```

For large publish sets, use monochange publish-readiness output and registry rate-limit planning to decide whether to publish in batches. The configured `mc publish` workflow delegates Dart package ordering to Melos and publishes the renderer package with pnpm.

If limits are not a concern, publish everything in one pass:

```bash
mc publish
```

After any publish batch, verify published versions on pub.dev before continuing.

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

Packages must be published in dependency order (leaf packages first). The configured `mc publish` workflow handles this automatically through `melos publish`, which computes package ordering from the workspace dependency graph.

The correct publishing order follows the layer table above:

1. Layer 0: `solana_kit_errors`
2. Layer 1: `solana_kit_functional`, `solana_kit_fast_stable_stringify`
3. Layer 2: Codec packages (`codecs_core` -> `codecs_numbers`, `codecs_strings` -> `codecs_data_structures` -> `options` -> `codecs`)
4. Layer 3+: Address, keys, RPC types
5. Continue upward through the dependency graph
6. Layer 9: `solana_kit` umbrella package (published last)

### Running the Publish Workflow

```bash
mc publish
```

This workflow currently runs:

1. `melos publish`
2. `pnpm --filter codama-renderers-dart publish --access public --no-git-checks`

### Dry Run

To verify all packages are ready to publish without actually publishing:

```bash
mc step:publish-readiness --from HEAD --format json
mc publish --dry-run
```

## Known Issues and Considerations

### 40-Package Monorepo Concerns

1. **Namespace reservation**: All packages use the `solana_kit_` prefix. Once the first package is published, the namespace is effectively reserved. Ensure the verified publisher account is set up before initial publish.

2. **pub.dev rate limits**: Publishing many packages in quick succession may trigger limits. For the first release, use `mc step:plan-publish-rate-limits --from HEAD --format md` and verify results between any manual batches.

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
3. Run `dart pub login` to authenticate
4. Verify all packages pass `dart pub publish --dry-run`
5. Publish packages in dependency order starting from `solana_kit_errors` (use monochange readiness and rate-limit planning for first release)
6. Verify each package appears on pub.dev before running the next publish workflow
7. After all packages are published, verify the umbrella `solana_kit` package correctly resolves all dependencies from pub.dev

### CI/CD Integration

The recommended CI/CD workflow for publishing:

1. **PR merged to main**: CI checks run (analyze, test, format, changeset enforcement, docs drift check)
2. **Release preparation**: The `release` GitHub Actions workflow opens or updates a monochange release PR with `mc release-pr`
3. **Publishing**: Trigger the `publish` GitHub Actions workflow (`workflow_dispatch`) for a release tag after publish-readiness passes
4. **Verification**: Check pub.dev for all packages with correct versions

The GitHub Actions workflow should include:

- A `release` workflow that opens/updates the monochange release PR and tags release commits after merge
- A manually triggered `publish` workflow that checks publish readiness and runs `mc publish` from a release tag
- The publish job uses GitHub Actions OIDC trusted publishing (`id-token: write`) for pub.dev and npm provenance; configure trusted publishers in pub.dev and npm before using it.
