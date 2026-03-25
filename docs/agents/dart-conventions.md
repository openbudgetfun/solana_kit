# Dart conventions

## Language and API style

- Target modern Dart 3.10+ features, including sealed classes, extension types, records, and patterns, where they improve the API.
- Avoid `dynamic`; use `Object?` when a value is intentionally untyped.
- Prefer `const` constructors wherever possible.
- Keep APIs additive and non-breaking unless the task explicitly calls for a breaking change.

## Error modeling

- Error codes live as `static const int` values on `SolanaErrorCode`.
- Error messages should use `$variableName` interpolation.

## Tooling constraints

- Do not add code generation (`freezed`, `build_runner`, etc.).
- Linting is driven by `very_good_analysis` through the shared `solana_kit_lints` package.

## Documentation expectations

- When public APIs or behavior change, update the affected package `README.md` files and any relevant docs pages in the same change.
