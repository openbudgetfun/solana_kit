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
- Changesets describe **completed** changes only — they are release inputs that ship to users. Never use them as planning documents for in-progress work (no "remaining", "in progress", or TODO sections). The rare exception is documenting deprecations or future work that belongs to a _future release_; if a PR lands partially, split the work so each changeset only describes what actually shipped.
- Keep affected public docs in sync when public APIs or behavior change.
- `SolanaErrorCode` numbers must match the upstream `@solana/kit` error codes: a code that exists upstream uses the upstream number, and a port-only code must not occupy a number upstream uses. `upstream:error-codes` (part of `docs:check`) enforces this. See `docs/agents/error-codes.md`.
- Every package under `packages/*` must have a `LICENSE` (MIT) and `README.md` file. New packages must include both before their first publish. The README must describe the package purpose, show usage examples, and list key APIs. Use badges for pub.dev, CI, and coverage. See `packages/solana_kit_compute_budget/README.md` for the canonical structure.
- New packages must start at `version: 0.0.0` in their `pubspec.yaml` with a `major` changeset. This ensures the first release lands at `0.1.0` (the minimum viable publishable version). Never set an unpublished package to a higher version.
- Never push commits, edit files, or rebase generated release pull requests (branches matching `monochange/release/**`, e.g. `monochange/release/step-open-release-request`). These PRs are produced by the release tooling and must stay untouched. If a generated release PR fails CI, fix the root cause on `main` (or the appropriate feature branch) and let the release PR pick up the change on its next regeneration. Re-running failed checks (`gh run rerun`) and merging are allowed; modifying the PR content is not.
- When release preparation makes a package version breaking, resolve the `remove_deprecations_in_breaking_versions` lint by removing the `@Deprecated` members it names (and their tests) — never by adding ignore comments. See `docs/agents/dart-conventions.md`.
- `versions.json` is auto-generated/updated by the release tooling (`monochange versions sync`). Do not edit or commit changes to it outside of a release — its versions are only bumped when a release is prepared. Exceptions: the `@solana/kit` key is the upstream compatibility marker, and missing or stale package entries must be fixed so the mdt-rendered installation sections stay complete.
- The tracked upstream `@solana/kit` version is kept current by the scheduled `upstream-version-sync` workflow: when npm's `latest` dist-tag moves, it opens a draft pull request with the mechanical pin updates (version tables, reference-repo pin, changeset) via `scripts/sync_upstream_kit_release.dart`. Never bump the compatibility claim without the upstream audit and a passing `upstream:parity`.

## No stubs

There are no stubs in this codebase, and adding one is never an acceptable way to make an API exist. A stub is worse than a missing function: it compiles, it type-checks, and it silently returns something wrong, so the failure surfaces later as a bad transaction or a wrong balance rather than as an unimplemented call. When you port a function, port its behavior.

A stub is any function that promises behavior it does not deliver:

- A pass-through or identity function presented as real logic — especially a `*Factory` that returns its parameter unchanged, or an `estimate*`/`simulate*`/`resolve*` that computes nothing.
- A doc comment describing real work over a body that does none of it.
- `throw UnimplementedError` / `throw UnsupportedError` on a path the public API implies works.
- A "placeholder", "for now", "in a full implementation this would…", or "not yet implemented" comment.
- A parameter that is accepted and silently ignored.
- A silent fallback that swallows a malformed or unexpected value into a plausible default (`?? 0`, `?? 200000`, `_ => null`, empty `catch`). Throw instead: a wrong number that looks real is the most expensive failure mode in this repo.

When a function cannot be implemented where it lives, that is an architecture signal, not a reason to stub. Check where upstream defines it, then move it to the package whose dependency graph can express it. `estimateResourceLimitsFactory` is the cautionary example: upstream defines it in the umbrella `@solana/kit` package because it needs both an RPC client and the transaction compiler, so the port's copy in `solana_kit_transaction_messages` could never work and became a pass-through. The fix was relocation, not a bigger stub.

Before you finish work on any function:

- If it takes a value, returns a value, and has no observable effect, justify it in a comment or delete it.
- If you cannot implement it now, do not add it to the public API. Leave it unported and say so.
- Grep for the error codes your function should throw. A code that is defined but never thrown anywhere in `packages/*/lib` usually marks a missing validation or failure path. `scripts/check_error_code_parity.dart` covers numbering, not reachability.
- When a behavioral test asserts current-but-wrong behavior (a pass-through factory, a silent default), the test is the bug. Fix the implementation and the test together.

## Task-specific guides

- [Workspace commands and tooling](docs/agents/workspace-commands.md)
- [Architecture and package boundaries](docs/agents/architecture.md)
- [Dart conventions and API style](docs/agents/dart-conventions.md)
- [Error codes](docs/agents/error-codes.md)
- [Documentation updates](docs/agents/documentation.md)
- [Changesets and releases](docs/agents/changesets-and-releases.md)
- [Git and PR workflow](docs/agents/git-and-prs.md)
- [Reference repos](docs/agents/reference-repos.md)
