# Commands

All workspace commands are defined as `devenv` scripts and should be treated as the single source of truth for routine development tasks.

If you are not already inside a `devenv` shell, run commands as:

```bash
devenv shell -- bash -lc '<command>'
```

## Common workspace commands

| Command           | Purpose                                                                          |
| ----------------- | -------------------------------------------------------------------------------- |
| `install:all`     | Install local tooling and resolve Dart dependencies.                             |
| `install:dart`    | Run `flutter pub get` for the workspace.                                         |
| `install:eget`    | Install local binaries declared in `.eget/.eget.toml`.                           |
| `fix:all`         | Run sync, docs updates, formatting, and lint fixes.                              |
| `fix:format`      | Format tracked files.                                                            |
| `fix:lint`        | Apply Dart fixes.                                                                |
| `lint:all`        | Run sync checks, docs checks, formatting checks, Kotlin lint, and Dart analysis. |
| `lint:format`     | Run `dprint check`.                                                              |
| `lint:analyze`    | Run `dart analyze --fatal-infos .`.                                              |
| `lint:kotlin`     | Run `ktlint` against tracked Kotlin files.                                       |
| `test:all`        | Run all workspace tests.                                                         |
| `test:coverage`   | Generate merged LCOV coverage.                                                   |
| `bench:all`       | Run local benchmark scripts across workspace packages.                           |
| `docs:check`      | Verify generated docs blocks and workspace metadata are up to date.              |
| `docs:update`     | Refresh generated docs blocks.                                                   |
| `docs:site:build` | Build the Jaspr docs site.                                                       |
| `docs:site:serve` | Serve the Jaspr docs site locally.                                               |
| `docs:site:smoke` | Build and smoke test the docs site.                                              |
| `sync:check`      | Validate synced dependency versions and changelog outputs.                       |
| `sync:write`      | Rewrite synced dependency versions and changelog outputs.                        |
| `clone:repos`     | Clone or update reference repositories into `.repos/`.                           |
| `upstream:check`  | Check tracked upstream compatibility metadata and local drift.                   |
| `update:deps`     | Update `devenv` and pub dependencies.                                            |

## Raw tool entrypoints

Use these when you specifically need the underlying tool rather than a higher-level script:

- `dart`
- `flutter`
- `melos`
- `jaspr`
- `knope`
- `dprint`

## Renderer package

When working directly in `packages/codama-renderers-dart`, package-local tasks may also use `pnpm`, for example:

```bash
cd packages/codama-renderers-dart
pnpm install --frozen-lockfile
pnpm typecheck
pnpm test
```
