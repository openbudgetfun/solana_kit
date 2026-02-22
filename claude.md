# Solana Kit Dart SDK

A Dart port of the [Solana TypeScript SDK](https://github.com/anza-xyz/kit) (`@solana/kit`), mirroring the TS package structure as ~39 Dart packages.

## Architecture

- **Monorepo**: Dart workspaces + Melos for workspace management
- **39 packages** under `packages/`, flat structure (not nested by category)
- **Package prefix**: `solana_kit_` (except umbrella `solana_kit`)
- **Modern Dart 3.10+**: sealed classes, extension types, records, patterns
- **No code generation**: hand-written, no freezed/build_runner

## Commands

All commands are defined as devenv scripts (single source of truth):

| Command         | Description                                    |
| --------------- | ---------------------------------------------- |
| `dart pub get`  | Resolve all workspace dependencies             |
| `melos analyze` | Run `dart analyze` across all packages         |
| `melos test`    | Run tests in all packages with test dirs       |
| `dprint check`  | Check formatting                               |
| `dprint fmt`    | Fix formatting                                 |
| `clone:repos`   | Clone/update reference repos into `.repos/`    |
| `install:eget`  | Install binaries via eget                      |
| `fix:all`       | Fix formatting + lint                          |
| `lint:all`      | Check formatting + analyze                     |
| `test:all`      | Run all tests via melos                        |
| `test:coverage` | Generate merged LCOV coverage for all packages |

## Package Dependency Graph (Core)

```
solana_kit_errors (foundation - no deps)
  ├── solana_kit_addresses
  │     └── solana_kit_keys
  │           └── solana_kit_signers
  ├── solana_kit_codecs_core
  │     ├── solana_kit_codecs_numbers
  │     ├── solana_kit_codecs_strings
  │     ├── solana_kit_codecs_data_structures
  │     └── solana_kit_codecs (umbrella)
  ├── solana_kit_rpc_types
  │     ├── solana_kit_rpc_spec_types
  │     ├── solana_kit_rpc_spec
  │     ├── solana_kit_rpc_api
  │     └── solana_kit_rpc
  ├── solana_kit_mobile_wallet_adapter_protocol (pure Dart MWA)
  │     └── solana_kit_mobile_wallet_adapter (Flutter MWA plugin)
  └── solana_kit (umbrella - re-exports everything)
```

## Important Rules

- **Never delete files in `.changeset/`** — changeset files track release notes and versioning decisions. They are consumed by `knope release` and must not be manually removed.
- **Always keep readme files and docs up to date** — when modifying a package's public API, behavior, or usage patterns, update its `readme.md` to reflect the changes. Documentation must stay in sync with the code.

## Coding Conventions

- Modern Dart 3.10+ features: sealed classes, extension types, records, patterns
- No `dynamic` types - use `Object?` where needed
- `const` constructors wherever possible
- All markdown files use lowercase names (e.g. `readme.md`, `claude.md`, `CHANGELOG.md`)
- Error codes are `static const int` on `SolanaErrorCode` (abstract final class)
- Error messages use `$variableName` interpolation
- No code generation (no freezed, no build_runner)
- Linting via `very_good_analysis` through shared `solana_kit_lints` package

## Reference Repos

Clone with `clone:repos` to `.repos/`:

- `.repos/kit` - [anza-xyz/kit](https://github.com/anza-xyz/kit) (TS source to port)
- `.repos/espresso-cash-public` - [brij-digital/espresso-cash-public](https://github.com/brij-digital/espresso-cash-public) (existing Dart Solana reference)
- `.repos/mobile-wallet-adapter` - [solana-mobile/mobile-wallet-adapter](https://github.com/solana-mobile/mobile-wallet-adapter) (MWA protocol reference)

## Commit Convention

Every commit and PR title must follow: `EMOJI TYPE(SCOPE): description`

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

Examples:

- `✨ feat(solana_kit_errors): error codes and messages`
- `🔧 build: devenv and FVM configuration`
- `💚 ci: GitHub Actions workflows`

## Release Management

Uses [knope](https://knope.tech/) for changeset-based releases:

- `knope document-change` - Create a changeset file
- `knope release` - Prepare and publish releases
- Changesets stored in `.changeset/`

## Active Technologies

- Dart 3.10+ (pinned via `.fvmrc`) + `cryptography` (Ed25519), `crypto` (SHA-256), `http` (001-solana-kit-port)
- N/A (SDK library, no persistent storage) (001-solana-kit-port)

## Recent Changes

- 001-solana-kit-port: Added Dart 3.10+ (pinned via `.fvmrc`) + `cryptography` (Ed25519), `crypto` (SHA-256), `http`
