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

## Repo-wide rules

- Prefer additive, non-breaking changes unless the task explicitly requires a breaking change.
- Never delete files in `.changeset/`.
- Changes under `packages/*` require a `.changeset/*.md` file before PR or merge.
- Keep affected public docs in sync when public APIs or behavior change.
- Every package under `packages/*` must have a `LICENSE` (MIT) and `README.md` file. New packages must include both before their first publish. The README must describe the package purpose, show usage examples, and list key APIs. Use badges for pub.dev, CI, and coverage. See `packages/solana_kit_compute_budget/README.md` for the canonical structure.
- New packages must start at `version: 0.0.0` in their `pubspec.yaml` with a `major` changeset. This ensures the first release lands at `0.1.0` (the minimum viable publishable version). Never set an unpublished package to a higher version.

## Task-specific guides

- [Workspace commands and tooling](docs/agents/workspace-commands.md)
- [Architecture and package boundaries](docs/agents/architecture.md)
- [Dart conventions and API style](docs/agents/dart-conventions.md)
- [Documentation updates](docs/agents/documentation.md)
- [Changesets and releases](docs/agents/changesets-and-releases.md)
- [Git and PR workflow](docs/agents/git-and-prs.md)
- [Reference repos](docs/agents/reference-repos.md)
