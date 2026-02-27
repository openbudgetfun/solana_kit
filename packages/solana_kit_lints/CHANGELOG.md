# Changelog

All notable changes to this package will be documented in this file.

## 0.2.0 (2026-02-27)

### Breaking Changes

#### Initial Release

The initial release of all libraries.

### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Add runnable, non-placeholder examples for `solana_kit_lints` and `solana_kit_test_matchers`, including analyzer configuration guidance for lint usage and direct matcher usage examples.

#### Add a `solana_kit_lints` workspace dependency checker and run it as part of

`lint:all` to ensure internal package dependencies use `workspace: true` in
`pubspec.yaml` files.

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
