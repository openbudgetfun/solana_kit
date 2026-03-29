# Solana Kit Dart SDK

Solana Kit is a multi-package Dart workspace that ports `@solana/kit` and related Solana tooling to Dart and Flutter packages.

## Defaults

- Use `devenv` scripts as the default entrypoint for workspace tasks.
- Use FVM-managed Dart and Flutter tooling when running Dart or Flutter directly.
- Use `pnpm` only when working in `packages/codama-renderers-dart`.

## Common commands

- `install:all`
- `fix:all`
- `lint:all`
- `test:all`
- `docs:check`
- `docs:update`
- `sync:check`
- `sync:write`

## Repo-wide rules

- Never delete files in `.changeset/`.
- Any change under `packages/*` must include a `.changeset/*.md` file.
- Keep affected public docs in sync when public APIs or behavior change.

## More guidance

- [Workspace commands](docs/agents/workspace-commands.md)
- [Architecture](docs/agents/architecture.md)
- [Dart conventions](docs/agents/dart-conventions.md)
- [Changesets and releases](docs/agents/changesets-and-releases.md)
- [Git and PR conventions](docs/agents/git-and-prs.md)
- [Reference repos](docs/agents/reference-repos.md)
