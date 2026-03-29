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

# Validate markdown templates and generated docs
# (also runs mdt doctor and workspace docs drift checks)
docs:check

# Regenerate documentation template consumers and workspace docs
docs:update

# Inspect mdt provider/consumer state and cache reuse
mdt:info

# Run actionable mdt health checks
mdt:doctor

# Check tracked upstream compatibility metadata
upstream:check

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

## Pull Request Expectations

- Keep changes scoped and include tests where behavior changes.
- Update documentation when APIs or workflows change.
- Prefer typed APIs over stringly-typed calls in new code.
