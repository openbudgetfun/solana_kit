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
