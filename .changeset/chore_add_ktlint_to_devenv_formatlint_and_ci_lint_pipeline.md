---
default: patch
---

# chore: add ktlint to devenv format/lint and CI lint pipeline

#72 by @ifiokjr

## Summary

Adds Kotlin lint/format support to the repository `devenv` workflows and ensures CI runs those checks.

## What changed

- Added `ktlint` to `packages` in `devenv.nix`.
- Updated `fix:format` to run Kotlin formatting via:
  - `ktlint --relative --format` on tracked `*.kt` and `*.kts` files.
- Added a new `lint:kotlin` script that runs:
  - `ktlint --relative` on tracked Kotlin files.
- Updated `lint:all` to include `lint:kotlin` so Kotlin linting is part of the standard CI lint command.
- Updated CI lint step label to explicitly indicate ktlint is included.

## Why

The repo already linted and formatted Dart/Markdown/JSON/YAML paths, but Kotlin files were not covered by the same developer and CI workflows. This aligns Kotlin quality gates with the rest of the codebase.

## Validation

- `dprint check .github/workflows/ci.yml`
- Structural verification of `devenv.nix` script blocks for:
  - `fix:format`
  - `lint:kotlin`
  - `lint:all`
