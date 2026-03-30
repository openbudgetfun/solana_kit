---
title: Contributing
description: Local development, docs workflow, and contribution standards.
---

## Local Setup

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

## Day-to-Day Commands

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

## Documentation Site Commands

<!-- {=docsDocsSiteCommandsSection} -->

```bash
# Serve docs site locally at http://localhost:8080
docs:site:serve

# Build static docs output for GitHub Pages
docs:site:build

# Run a smoke test against the built docs site
docs:site:smoke
```

<!-- {/docsDocsSiteCommandsSection} -->

## Security and Platform Expectations

- Keep `allowInsecureHttp` and `allowInsecureWs` disabled outside local development and controlled tests.
- Use `audit:deps` to scan the current workspace `pubspec.lock` and `pnpm-lock.yaml` files present on disk for known vulnerabilities.
- Do not log private keys, auth tokens, wallet session payloads, or full error contexts that may contain sensitive material.
- Treat Mobile Wallet Adapter as Android-only for real wallet handoff today. iOS remains a safe stub/no-op because the current Solana MWA ecosystem does not provide an equivalent iOS integration target.
- Gate MWA flows explicitly with `isMwaSupported()` / `assertMwaSupported()` and provide fallback UX on unsupported platforms.

## Pull Request Expectations

- Keep changes scoped and include tests where behavior changes.
- Update documentation when APIs or workflows change.
- Prefer typed APIs over stringly-typed calls in new code.
