<!--
Sync Impact Report
==================
Version change: N/A -> 1.0.0 (initial ratification)
Modified principles: N/A (initial)
Added sections:
  - Core Principles (7 principles)
  - Technical Stack & Constraints
  - Development Workflow & CI
  - Governance
Removed sections: N/A
Templates requiring updates:
  - .specify/templates/plan-template.md: ✅ compatible (Constitution Check section exists)
  - .specify/templates/spec-template.md: ✅ compatible (requirements/success criteria align)
  - .specify/templates/tasks-template.md: ✅ compatible (phase structure supports principles)
Follow-up TODOs: None
-->

# Solana Kit Dart SDK Constitution

## Core Principles

### I. Faithful Port

Every package, API surface, and behavior MUST mirror the upstream
[anza-xyz/kit](https://github.com/anza-xyz/kit) TypeScript SDK. The 37-package
structure, naming conventions (`solana_kit_` prefix), and dependency graph are
derived directly from the TS `@solana/` namespace. Deviations from upstream
behavior MUST be documented with rationale and tracked as issues. When the
upstream SDK changes, this project MUST track those changes.

**Reference repos** (cloned via `clone:repos` to `.repos/`):

- `.repos/kit` -- canonical TS source to port
- `.repos/espresso-cash-public` -- existing Dart Solana reference for idiom guidance

### II. Modern Dart, No Code Generation

All code MUST target Dart 3.10+ and use modern language features: sealed classes,
extension types, records, and pattern matching. Code generation tools (freezed,
build_runner, json_serializable) are prohibited. All types, codecs, and
serialization MUST be hand-written. This ensures full control over the generated
API surface and eliminates build-time dependencies.

### III. Package Independence

Each of the 37 packages under `packages/` MUST be self-contained, independently
versioned (via knope + changesets), independently testable, and independently
publishable to pub.dev. Cross-package dependencies MUST follow the established
dependency graph (errors at the root, umbrella `solana_kit` at the top). No
circular dependencies are permitted. Each package MUST have its own
`pubspec.yaml`, `analysis_options.yaml` (extending `solana_kit_lints`), and
barrel export file.

### IV. Type Safety

The use of `dynamic` is prohibited throughout the codebase. Where a flexible type
is needed, use `Object?`. All constructors MUST be declared `const` wherever
possible. Error codes MUST be `static const int` on the `SolanaErrorCode`
abstract final class. Error messages MUST use `$variableName` interpolation.
Linting is enforced via `very_good_analysis` through the shared
`solana_kit_lints` package across all 37 packages.

### V. Test-Driven Quality

Every implemented package (not scaffold stubs) MUST have a comprehensive test
suite. Tests MUST cover all public API surfaces, error paths, and edge cases.
The `melos test` command runs tests across all packages with `test/` directories.
Tests MUST pass in CI before merge. When porting a TS package, the corresponding
TS test suite serves as the minimum coverage baseline.

### VI. Changeset Discipline

Every pull request that affects user-facing behavior MUST include at least one
changeset file in `.changeset/` describing the change for the changelog. Changeset
files are created via `knope document-change`. The CI `Changeset Required` check
enforces this gate. PRs that do not affect users (CI-only, docs-only internal
tooling) MAY add the `skip-changelog` label to bypass this check. Releases are
managed by knope with semantic versioning.

### VII. Emoji Conventional Commits

Every commit message and PR title MUST follow the format:
`EMOJI TYPE(SCOPE): description`

| Emoji | Type       | Use                                 |
| ----- | ---------- | ----------------------------------- |
| ✨    | `feat`     | New feature                         |
| 🐛    | `fix`      | Bug fix                             |
| 🔧    | `build`    | Build system, dependencies, tooling |
| 💚    | `ci`       | CI/CD changes                       |
| 🤖    | `chore`    | Maintenance, miscellaneous          |
| 📝    | `docs`     | Documentation                       |
| ♻️     | `refactor` | Code refactoring                    |
| 🧪    | `test`     | Tests                               |
| ⚡    | `perf`     | Performance                         |
| 🎨    | `style`    | Code style, formatting              |
| 🎉    | `init`     | Initial/first-time setup            |
| 🌱    | `seed`     | Scaffold/stub packages              |

The `TYPE(SCOPE)` portion is enforced by the `amannn/action-semantic-pull-request`
GitHub Action on PR titles. The emoji prefix is a documented convention.
Description MUST start with a lowercase letter.

## Technical Stack & Constraints

- **Language**: Dart 3.10+ (version pinned via `.fvmrc`)
- **Workspace**: Dart workspaces + Melos for multi-package orchestration
- **Formatting**: dprint (markdown, TOML, YAML) + `dart format` (Dart code)
- **Linting**: `very_good_analysis` via shared `solana_kit_lints` package
- **Release tooling**: knope for changeset-based semantic versioning
- **Dev environment**: devenv (Nix-based) + direnv for automatic loading
- **Binary tooling**: eget for installing CLI tools (`.eget/.eget.toml`)
- **CI platform**: GitHub Actions
- **No Flutter dependency**: Pure Dart packages (no Flutter SDK required at
  package level, though FVM manages the SDK for workspace resolution)
- **Markdown files**: Always lowercase names (`readme.md`, `changelog.md`,
  `claude.md`)

## Development Workflow & CI

All changes to `main` MUST go through pull requests (branch protection enforced).
Every PR MUST pass all 6 required CI checks before merge:

1. **analyze** -- `dart analyze` via melos across all packages
2. **test** -- `melos test` across all packages with test directories
3. **format** -- `dart format --set-exit-if-changed .` + `dprint check`
4. **Secrets Detection** -- gitleaks scan for leaked credentials
5. **PR Title** -- emoji conventional commit format validation
6. **Changeset Required** -- at least one `.changeset/*.md` file present

Admin bypass is enabled (`enforce_admins: false`) so repo admins can merge
in exceptional circumstances. One approving review is required; stale reviews
are dismissed on new pushes.

**Workflow commands** (via devenv scripts):

- `lint:all` -- check formatting + analyze
- `test:all` -- run all tests
- `fix:all` -- auto-fix formatting + lint

## Governance

This constitution is the authoritative source for project principles and
development standards. It supersedes any conflicting guidance in other documents.

**Amendment procedure**:

1. Propose changes via a pull request modifying this file.
2. PR title MUST follow: `📝 docs: amend constitution to vX.Y.Z`
3. Amendment MUST include a Sync Impact Report (HTML comment at top of file).
4. All dependent templates (`plan-template.md`, `spec-template.md`,
   `tasks-template.md`) MUST be updated in the same PR if affected.
5. `claude.md` MUST be kept in sync with any principle changes.

**Versioning policy** (semantic):

- **MAJOR**: Principle removal, redefinition, or backward-incompatible governance change.
- **MINOR**: New principle or section added, material guidance expansion.
- **PATCH**: Wording clarifications, typo fixes, non-semantic refinements.

**Compliance**: All PRs and code reviews MUST verify adherence to these
principles. The `claude.md` file contains the operational subset of these
rules for day-to-day development. This constitution contains the full
authoritative definitions.

**Version**: 1.0.0 | **Ratified**: 2026-02-15 | **Last Amended**: 2026-02-15
