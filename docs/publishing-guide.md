# Publishing Guide

This guide covers how to version, release, and publish the `solana_kit` Dart SDK packages to [pub.dev](https://pub.dev/).

## Overview

The Solana Kit SDK consists of 35 publishable packages under `packages/` plus 2 internal packages (`solana_kit_lints` and `solana_kit_test_matchers`) that are not published. Versioning is managed by [knope](https://knope.tech/) using changesets stored in `.changeset/`. Publishing is executed via the `knope publish` workflow which runs `dart pub publish` for each package in dependency order.

## Package Inventory

### Publishable Packages (35)

| Layer | Package | Dependencies |
|-------|---------|-------------|
| 0 | `solana_kit_errors` | (none) |
| 1 | `solana_kit_functional` | errors |
| 1 | `solana_kit_fast_stable_stringify` | (none) |
| 2 | `solana_kit_codecs_core` | errors |
| 2 | `solana_kit_codecs_numbers` | codecs_core |
| 2 | `solana_kit_codecs_strings` | codecs_core |
| 2 | `solana_kit_codecs_data_structures` | codecs_core, codecs_numbers |
| 2 | `solana_kit_options` | codecs_core, codecs_data_structures |
| 2 | `solana_kit_codecs` | (umbrella re-export of all codec packages) |
| 3 | `solana_kit_addresses` | errors, codecs_strings |
| 3 | `solana_kit_keys` | errors, addresses, codecs_strings |
| 3 | `solana_kit_rpc_spec_types` | errors |
| 3 | `solana_kit_rpc_types` | errors, addresses, codecs_strings |
| 4 | `solana_kit_instructions` | errors, addresses |
| 4 | `solana_kit_programs` | errors |
| 4 | `solana_kit_rpc_spec` | errors, rpc_spec_types |
| 4 | `solana_kit_rpc_parsed_types` | addresses, rpc_types |
| 4 | `solana_kit_rpc_transformers` | errors, rpc_spec_types, rpc_types |
| 4 | `solana_kit_rpc_transport_http` | errors, rpc_spec_types |
| 5 | `solana_kit_transaction_messages` | errors, addresses, codecs, instructions, keys |
| 5 | `solana_kit_offchain_messages` | errors, addresses, codecs, keys |
| 5 | `solana_kit_rpc_api` | addresses, rpc_spec, rpc_spec_types, rpc_types, rpc_parsed_types, rpc_transformers |
| 5 | `solana_kit_subscribable` | errors |
| 6 | `solana_kit_transactions` | errors, addresses, codecs, instructions, keys, transaction_messages |
| 6 | `solana_kit_rpc` | rpc_api, rpc_spec, rpc_transport_http, rpc_transformers |
| 6 | `solana_kit_rpc_subscriptions_api` | addresses, rpc_spec_types, rpc_types |
| 6 | `solana_kit_rpc_subscriptions_channel_websocket` | errors, rpc_spec_types |
| 7 | `solana_kit_signers` | errors, addresses, keys, transactions, transaction_messages |
| 7 | `solana_kit_accounts` | errors, addresses, codecs, rpc_api, rpc_spec, rpc_types |
| 7 | `solana_kit_sysvars` | errors, addresses, codecs, rpc_api, rpc_spec, rpc_types, accounts |
| 7 | `solana_kit_program_client_core` | errors, addresses, instructions, rpc_api, rpc_spec |
| 7 | `solana_kit_rpc_subscriptions` | errors, rpc_spec_types, rpc_subscriptions_api, rpc_subscriptions_channel_websocket, subscribable |
| 8 | `solana_kit_transaction_confirmation` | errors, keys, rpc, rpc_subscriptions, rpc_types, transactions |
| 8 | `solana_kit_instruction_plans` | errors, instructions, keys, transaction_messages, transactions |
| 9 | `solana_kit` | (umbrella re-export of all packages above) |

### Internal Packages (not published)

| Package | Purpose |
|---------|---------|
| `solana_kit_lints` | Shared lint rules (`very_good_analysis`) |
| `solana_kit_test_matchers` | Solana-specific test matchers |

## Versioning with Knope

### Creating a Changeset

When making changes to any package, create a changeset file:

```bash
knope document-change
```

This interactively creates a Markdown file in `.changeset/` with the affected package(s) and a description. Each changeset file uses YAML frontmatter to specify the package and version bump type:

```markdown
---
solana_kit_addresses: minor
---

Add support for program derived addresses with custom seeds.
```

Bump types:
- `patch` - Bug fixes, documentation changes
- `minor` - New features, backwards-compatible additions
- `major` - Breaking changes

### Preparing a Release

When ready to release, run:

```bash
knope release
```

This workflow:
1. Reads all changeset files in `.changeset/`
2. Bumps versions in each package's `pubspec.yaml`
3. Updates each package's `changelog.md`
4. Formats with dprint
5. Commits and pushes
6. Creates a GitHub release

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

2. **readme.md** exists with:
   - Package purpose and features
   - Installation instructions
   - Basic usage example
   - Link to API docs

3. **changelog.md** exists and is up to date (managed by knope)

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
   dart format --set-exit-if-changed packages/<package_name>
   ```

### Dependency-Order Publishing

Packages must be published in dependency order (leaf packages first). The `knope publish` workflow handles this automatically by publishing packages in the order defined in `knope.toml`.

The correct publishing order follows the layer table above:
1. Layer 0: `solana_kit_errors`
2. Layer 1: `solana_kit_functional`, `solana_kit_fast_stable_stringify`
3. Layer 2: Codec packages (`codecs_core` -> `codecs_numbers`, `codecs_strings` -> `codecs_data_structures` -> `options` -> `codecs`)
4. Layer 3+: Address, keys, RPC types
5. Continue upward through the dependency graph
6. Layer 9: `solana_kit` umbrella package (published last)

### Running the Publish Workflow

```bash
knope publish
```

This executes `dart pub publish --force` for each package in order. The `--force` flag skips the interactive confirmation prompt.

### Dry Run

To verify all packages are ready to publish without actually publishing:

```bash
# Check a single package
cd packages/solana_kit_errors && dart pub publish --dry-run

# Check all packages (run from repo root)
for dir in packages/solana_kit_errors packages/solana_kit_functional packages/solana_kit_fast_stable_stringify packages/solana_kit_codecs_core packages/solana_kit_codecs_numbers packages/solana_kit_codecs_strings packages/solana_kit_codecs_data_structures packages/solana_kit_options packages/solana_kit_codecs packages/solana_kit_addresses packages/solana_kit_keys packages/solana_kit_rpc_spec_types packages/solana_kit_rpc_types packages/solana_kit_instructions packages/solana_kit_programs packages/solana_kit_rpc_spec packages/solana_kit_rpc_parsed_types packages/solana_kit_rpc_transformers packages/solana_kit_rpc_transport_http packages/solana_kit_transaction_messages packages/solana_kit_offchain_messages packages/solana_kit_rpc_api packages/solana_kit_subscribable packages/solana_kit_transactions packages/solana_kit_rpc packages/solana_kit_rpc_subscriptions_api packages/solana_kit_rpc_subscriptions_channel_websocket packages/solana_kit_signers packages/solana_kit_accounts packages/solana_kit_sysvars packages/solana_kit_program_client_core packages/solana_kit_rpc_subscriptions packages/solana_kit_transaction_confirmation packages/solana_kit_instruction_plans packages/solana_kit; do
  echo "=== Checking $(basename $dir) ==="
  (cd "$dir" && dart pub publish --dry-run) || echo "FAILED: $dir"
done
```

## Known Issues and Considerations

### 37-Package Monorepo Concerns

1. **Namespace reservation**: All packages use the `solana_kit_` prefix. Once the first package is published, the namespace is effectively reserved. Ensure the verified publisher account is set up before initial publish.

2. **pub.dev rate limits**: Publishing many packages in quick succession may trigger rate limits. The knope publish workflow publishes sequentially with `--force`, which should be sufficient. If rate-limited, add a delay between publishes.

3. **Verified publisher**: Set up a [verified publisher](https://dart.dev/tools/pub/verified-publishers) on pub.dev before publishing. This displays a verified badge and prevents package name squatting. All packages should be published under the same verified publisher.

4. **Workspace resolution**: Dart 3.10+ workspaces use `resolution: workspace` in each package's `pubspec.yaml`. This is valid for development but the resolver handles it correctly during `dart pub publish`. The workspace root's `pubspec.yaml` has `publish_to: none` so it is never published.

5. **Dependency constraints for publishing**: When packages are published, their inter-package dependencies must use caret syntax (`^0.0.1`) rather than path dependencies. The Dart workspace system handles this automatically -- packages within the workspace resolve to local paths during development but use version constraints when published.

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
5. Publish packages in dependency order starting from `solana_kit_errors`
6. Verify each package appears on pub.dev before publishing dependent packages
7. After all packages are published, verify the umbrella `solana_kit` package correctly resolves all dependencies from pub.dev

### CI/CD Integration

The recommended CI/CD workflow for publishing:

1. **PR merged to main**: Triggers CI checks (analyze, test, format)
2. **Release preparation**: Run `knope release` to bump versions and create GitHub release
3. **Publishing**: Run `knope publish` to publish all packages to pub.dev
4. **Verification**: Check pub.dev for all packages with correct versions

The GitHub Actions workflow should include:
- A `release` job that runs `knope release` on push to main (when changesets exist)
- A `publish` job that runs `knope publish` after the release job succeeds
- The publish job needs `dart pub login` credentials (via `PUB_TOKEN` environment variable or `dart pub token add` with a service account)
