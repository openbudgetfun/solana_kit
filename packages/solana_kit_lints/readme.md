# solana_kit_lints

Shared lint rules for all packages in the Solana Kit Dart SDK.

This is an internal package (`publish_to: none`) that centralizes the analysis configuration for the monorepo. It is not published to pub.dev.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dev_dependencies:
  solana_kit_lints:
```

Within the `solana_kit` monorepo, the package resolves through the Dart workspace. This package is not intended for use outside the monorepo.

## Usage

### Including the lint rules

Create or update your package's `analysis_options.yaml` to include the shared rules:

```yaml
include: package:solana_kit_lints/analysis_options.yaml
```

This single line gives your package the full set of lint rules used across the Solana Kit SDK. No additional configuration is needed in most cases.

### Adding package-specific overrides

If a specific package needs to adjust a rule, add overrides after the include:

```yaml
include: package:solana_kit_lints/analysis_options.yaml

linter:
  rules:
    avoid_print: false  # Allow print in example/CLI packages
```

## Configuration

The shared `analysis_options.yaml` provided by this package includes [`very_good_analysis`](https://pub.dev/packages/very_good_analysis) as its base and applies the following customizations:

### Base

```yaml
include: package:very_good_analysis/analysis_options.yaml
```

### Analyzer error severity

The following diagnostics are promoted to errors to catch problems early:

| Diagnostic              | Severity |
| ----------------------- | -------- |
| `missing_return`        | error    |
| `dead_code`             | error    |
| `unused_element`        | error    |
| `unused_import`         | error    |
| `unused_local_variable` | error    |
| `todo`                  | ignore   |

### Disabled lint rules

The following rules from `very_good_analysis` are disabled for this project:

| Rule                          | Reason                                                                                             |
| ----------------------------- | -------------------------------------------------------------------------------------------------- |
| `public_member_api_docs`      | Disabled to reduce friction during initial development. Public API docs are encouraged but not enforced. |
| `lines_longer_than_80_chars`  | Disabled because many error messages, type signatures, and constant names in the SDK naturally exceed 80 characters. |

### Full configuration

For reference, the complete shared analysis options file:

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  errors:
    missing_return: error
    dead_code: error
    unused_element: error
    unused_import: error
    unused_local_variable: error
    todo: ignore

linter:
  rules:
    public_member_api_docs: false
    lines_longer_than_80_chars: false
```

## API Reference

### Provided files

- **`lib/analysis_options.yaml`** -- The shared analysis options file that all packages include. Built on top of `very_good_analysis` with project-specific customizations.
