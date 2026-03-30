# Solana Kit Dart SDK

Solana Kit is a multi-package Dart workspace that ports `@solana/kit` and related Solana tooling to Dart and Flutter packages.

## Universal defaults

- Use `devenv` for routine workspace tasks. Outside a `devenv` shell, run `devenv shell -- bash -lc '<command>'`.
- Use FVM-managed `dart` and `flutter` when running those tools directly.
- Use `pnpm` only inside `packages/codama-renderers-dart`.

## Non-standard workspace commands

- `install:all`
- `fix:all`
- `lint:all`
- `test:all`
- `docs:check`
- `docs:update`
- `sync:check`
- `sync:write`

## Repo-wide rules

- Prefer additive, non-breaking changes unless the task explicitly requires a breaking change.
- Never delete files in `.changeset/`.
- Changes under `packages/*` require a `.changeset/*.md` file before PR or merge.
- Keep affected public docs in sync when public APIs or behavior change.

## Task-specific guides

- [Workspace commands and tooling](docs/agents/workspace-commands.md)
- [Architecture and package boundaries](docs/agents/architecture.md)
- [Dart conventions and API style](docs/agents/dart-conventions.md)
- [Documentation updates](docs/agents/documentation.md)
- [Changesets and releases](docs/agents/changesets-and-releases.md)
- [Git and PR workflow](docs/agents/git-and-prs.md)
- [Reference repos](docs/agents/reference-repos.md)
