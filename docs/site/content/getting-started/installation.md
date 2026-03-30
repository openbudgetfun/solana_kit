---
title: Installation
description: Install Solana Kit in an application or set up the full workspace for contribution.
---

Solana Kit supports two common setups:

1. **Application usage** — install `solana_kit` or a smaller sub-package in your Dart or Flutter app.
2. **Workspace contribution** — clone the monorepo and use `devenv` to get the full toolchain, docs tooling, and reference repos.

## Install in an app

If you want the full SDK surface, install the umbrella package:

```bash
dart pub add solana_kit
```

Then import it in your application code:

```dart
import 'package:solana_kit/solana_kit.dart';
```

### When to install a smaller package instead

Prefer a smaller package when:

- you only need one feature area, such as addresses, codecs, RPC, or signers
- you are building a library and want a narrower dependency surface
- you want your package imports to reflect a specific architectural boundary

Examples:

```bash
dart pub add solana_kit_accounts
dart pub add solana_kit_codecs_core
dart pub add solana_kit_rpc
dart pub add solana_kit_signers
```

## Set up the workspace for contribution

Use the monorepo when you want to run tests, update docs, compare against upstream `@solana/kit`, or contribute changes across packages.

<!-- {=docsWorkspaceSetupSection} -->

```bash
# Clone the repository
git clone https://github.com/openbudgetfun/solana_kit.git
cd solana_kit

# Load devenv
direnv allow

# Install binary tools and Dart dependencies
install:all
dart pub get

# Pull reference repositories used for compatibility checks
clone:repos
```

<!-- {/docsWorkspaceSetupSection} -->

## Verify the toolchain

Run these commands from the repository root:

<!-- {=docsWorkspaceDevCommandsSection} -->

```bash
# Lint, docs drift, formatting, and analysis checks
lint:all

# Run all package tests
test:all

# Generate merged test coverage across all packages
test:coverage

# Run doc-comment snippet checks extracted from synchronized library docs
test:doc-snippets

# Validate markdown templates, Dart doc comments, and generated docs
# (also runs mdt doctor and workspace docs drift checks)
docs:check

# Regenerate documentation template consumers, Dart doc comments, and workspace docs
docs:update

# Inspect mdt provider/consumer state and cache reuse
mdt:info

# Run actionable mdt health checks
mdt:doctor

# Check tracked upstream compatibility metadata
upstream:check

# Audit current Dart and pnpm lockfiles for known vulnerabilities
audit:deps

# Run local benchmark scripts across benchmark-enabled packages
bench:all

# Fix formatting and lint issues where possible
fix:all
```

<!-- {/docsWorkspaceDevCommandsSection} -->

For day-to-day contribution work, the most important commands are `lint:all`, `test:all`, `docs:check`, and `docs:update`.

## Documentation tooling

This workspace uses [`mdt`](https://github.com/ifiokjr/mdt) to keep shared README
blocks and site snippets synchronized. The current `mdt` release still does not
discover `.dart` consumers directly in this repo, so the same provider blocks
are also projected into `///` library doc comments through
`scripts/sync-dart-doc-comments.py`.

Use:

- `docs:update` to regenerate Markdown consumers and synchronized Dart doc comments
- `docs:check` to verify Markdown and Dart doc consumers are current in CI or before committing
- `test:doc-snippets` to analyze fenced Dart examples extracted from synchronized library doc comments
- `mdt:info` to inspect providers, consumers, and cache reuse
- `mdt:doctor` to diagnose template drift or config problems

## Next steps

- [Quick Start](quick-start)
- [Generate a Signer](generate-a-signer)
- [Fetch an Account](fetch-an-account)
- [First Transaction](first-transaction)
