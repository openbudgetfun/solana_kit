# Changelog

All notable changes to this package will be documented in this file.

## 0.1.0 (2026-02-21)

### Notes

- First 0.1.0 release of this package.

## 0.0.2 (2026-02-21)

### Features

#### Initial release of shared lint configuration package. Extends `very_good_analysis`

with project-specific overrides: disables `public_member_api_docs` (docs will be
added incrementally) and `lines_longer_than_80_chars` (allows longer lines for
readability in codec/RPC code). All 37 packages in the workspace depend on this
package via `dev_dependencies` for consistent static analysis.

### Fixes

- CI/tooling improvements: add devenv composite action, refactor CI to use devenv shell, add dprint exec plugins, and enable additional lint rules.
