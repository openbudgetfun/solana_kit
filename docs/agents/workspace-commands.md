# Workspace commands

Use `devenv` scripts as the default entrypoint for routine workspace tasks.

If you are not already inside a `devenv` shell, run commands as:

```bash
devenv shell -- bash -lc '<command>'
```

## Cursor cloud agents

`.cursor/install.sh` is the cloud-agent bootstrap. It installs Nix, the devenv binary cache, devenv, the Flutter SDK pinned in `.fvmrc`, and workspace Dart packages (`install:all`). `.cursor/start.sh` starts the Nix daemon on each boot; the daemon does not survive the environment snapshot. There is no separate compile-all step: `lint:all` includes `dart analyze`, and `test:all` is the Dart test suite.

Android plugin compilation needs an Android SDK and stays in the `android-plugin-compile` CI job. iOS builds cannot run on the Linux agent VM. `test:integration` starts Surfpool from the devenv shell and is separate from `test:all`.

## Common workspace commands

| Command            | Purpose                                                                                          |
| ------------------ | ------------------------------------------------------------------------------------------------ |
| `install:all`      | Install local tooling and resolve Dart dependencies.                                             |
| `fix:all`          | Run sync, docs updates, formatting, and lint fixes.                                              |
| `lint:all`         | Run sync checks, docs checks, formatting checks, Kotlin lint, and Dart analysis.                 |
| `test:all`         | Run all workspace tests.                                                                         |
| `test:coverage`    | Generate merged LCOV coverage.                                                                   |
| `coverage:check`   | Run package-level coverage for risk-tier packages and enforce configured floors.                 |
| `mutation:list`    | List the configured mutation testing scopes and their sizes.                                     |
| `mutation:check`   | Report how completely each mutation scope's test list covers its dependents.                     |
| `mutation:changed` | Run mutation testing for scopes touched since `origin/main`.                                     |
| `mutation:run`     | Run scoped mutation testing (`--scope`, `--changed`, `--full`, `--coverage`).                    |
| `docs:check`       | Verify generated docs blocks, source comment consumers, and workspace metadata are up to date.   |
| `docs:update`      | Refresh generated docs blocks and print mdt diagnostics.                                         |
| `upstream:check`   | Check tracked upstream compatibility metadata and local drift.                                   |
| `upstream:parity`  | Generate runtime fixtures from the tracked `@solana/kit` release and compare selected behaviors. |
| `audit:deps`       | Audit current Dart and pnpm lockfiles for known vulnerabilities with `osv-scanner`.              |
| `update:deps`      | Update `devenv` and pub dependencies.                                                            |

## Direct tools

Use direct tools only when you specifically need them instead of a workspace task:

- `dart`
- `flutter`
- `melos`
- `jaspr`
- `monochange`
- `dprint`

## Renderer package

When working directly in `packages/codama-renderers-dart`, package-local tasks may use `pnpm`.
