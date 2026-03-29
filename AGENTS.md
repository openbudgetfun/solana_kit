# Solana Kit Dart SDK

Solana Kit is a multi-package Dart workspace that ports `@solana/kit` and related Solana tooling to Dart and Flutter packages.

## Package managers and commands

- Use FVM-managed Dart and Flutter tooling for workspace development.
- All workspace commands are defined as `devenv` scripts (single source of truth).
- Use `pnpm` only when working directly in `packages/codama-renderers-dart`.

Common workspace commands:

| Command           | Purpose                                                                           |
| ----------------- | --------------------------------------------------------------------------------- |
| `install:all`     | Install workspace tooling and Dart dependencies.                                  |
| `fix:all`         | Apply sync, docs, formatting, and lint fixes.                                     |
| `lint:all`        | Run workspace sync, docs, formatting, Kotlin lint, and Dart analysis checks.      |
| `test:all`        | Run all workspace tests.                                                          |
| `test:coverage`   | Generate merged LCOV coverage.                                                    |
| `docs:check`      | Validate generated docs blocks, source comment consumers, and workspace metadata. |
| `docs:update`     | Refresh generated docs blocks and print mdt diagnostics.                          |
| `mdt:info`        | Inspect mdt providers/consumers and cache reuse telemetry.                        |
| `mdt:doctor`      | Run actionable mdt health checks.                                                 |
| `docs:site:smoke` | Build and smoke test the docs site.                                               |
| `upstream:check`  | Validate tracked upstream compatibility metadata.                                 |

## Global rules

- Never delete files in `.changeset/`.
- Any PR that changes files under `packages/*` must include a `.changeset/*.md` file.
- Every changeset must use exactly one frontmatter entry: `default: patch|minor|major`.
- Keep affected `README.md` files and docs in sync when public APIs or behavior change.

## More guidance

- [Architecture](docs/agents/architecture.md)
- [Commands](docs/agents/commands.md)
- [Dart conventions](docs/agents/dart-conventions.md)
- [Release and changesets](docs/agents/release-and-changesets.md)
- [Git and PR conventions](docs/agents/git-and-prs.md)
- [Reference repos](docs/agents/reference-repos.md)
