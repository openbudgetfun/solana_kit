# Workspace commands

Use `devenv` scripts as the default entrypoint for routine workspace tasks.

If you are not already inside a `devenv` shell, run commands as:

```bash
devenv shell -- bash -lc '<command>'
```

## Common workspace commands

| Command          | Purpose                                                                                        |
| ---------------- | ---------------------------------------------------------------------------------------------- |
| `install:all`    | Install local tooling and resolve Dart dependencies.                                           |
| `fix:all`        | Run sync, docs updates, formatting, and lint fixes.                                            |
| `lint:all`       | Run sync checks, docs checks, formatting checks, Kotlin lint, and Dart analysis.               |
| `test:all`       | Run all workspace tests.                                                                       |
| `test:coverage`  | Generate merged LCOV coverage.                                                                 |
| `docs:check`     | Verify generated docs blocks, source comment consumers, and workspace metadata are up to date. |
| `docs:update`    | Refresh generated docs blocks and print mdt diagnostics.                                       |
| `sync:check`     | Validate synced dependency versions and changelog outputs.                                     |
| `sync:write`     | Rewrite synced dependency versions and changelog outputs.                                      |
| `upstream:check` | Check tracked upstream compatibility metadata and local drift.                                 |
| `audit:deps`     | Audit current Dart and pnpm lockfiles for known vulnerabilities with `osv-scanner`.            |
| `update:deps`    | Update `devenv` and pub dependencies.                                                          |

## Direct tools

Use direct tools only when you specifically need them instead of a workspace task:

- `dart`
- `flutter`
- `melos`
- `jaspr`
- `knope`
- `dprint`

## Renderer package

When working directly in `packages/codama-renderers-dart`, package-local tasks may use `pnpm`.
