# Dart conventions

## Language and API style

- Use modern Dart 3.10+ features when they improve clarity.
- Avoid `dynamic`; use `Object?` when a value is intentionally untyped.
- Prefer `const` constructors wherever possible.

## Error modeling

- Error codes live as `static const int` values on `SolanaErrorCode`.
- Error messages should use `$variableName` interpolation.

## Tooling constraints

- Linting is driven by `very_good_analysis` through `solana_kit_lints`.

## Deprecations and breaking releases

- `remove_deprecations_in_breaking_versions` (fatal under `--fatal-infos`) fires when release preparation moves a package into a breaking version while `@Deprecated` members still exist. Resolve it by **removing the deprecated elements and their tests** — a breaking release is the scheduled moment to delete them.
- Do not add `// ignore_for_file:` comments for this diagnostic. Suppressions strand themselves across version transitions (a later non-breaking release turns them into `unnecessary_ignore` failures) and hide removals users are owed.
- `monochange run release` runs `dart fix --apply` during preparation, which cleans suppressions a version transition strands. If the release still aborts on this lint, remove the members it names by hand, then re-run.
