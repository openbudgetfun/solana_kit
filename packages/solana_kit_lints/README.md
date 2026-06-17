# solana_kit_lints

[![pub package](https://img.shields.io/pub/v/solana_kit_lints.svg)](https://pub.dev/packages/solana_kit_lints)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_lints/latest/)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_lints)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_lints)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_lints)

Shared lint rules for all packages in the Solana Kit Dart SDK.

This is an internal package (`publish_to: none`) that centralizes the analysis configuration for the monorepo. It is not published to pub.dev.

## Installation

Install with:

```bash
dart pub add --dev solana_kit_lints
```

Within the `solana_kit` monorepo, the package resolves through the Dart workspace. This package is not intended for use outside the monorepo.

## Documentation

- Package page: https://pub.dev/packages/solana_kit_lints
- API reference: https://pub.dev/documentation/solana_kit_lints/latest/
- Guides website: https://openbudgetfun.github.io/solana_kit/

## Usage

### Including the lint rules

Create or update your package's `analysis_options.yaml` to include the shared rules:

```yaml
include: package:solana_kit_lints/analysis_options.yaml
```

This single line gives your package the full set of lint rules used across the Solana Kit SDK. No additional configuration is needed in most cases.

For Flutter packages, include the Flutter preset instead:

```yaml
include: package:solana_kit_lints/flutter_analysis_options.yaml
```

The Flutter preset uses [`flutter_lints`](https://pub.dev/packages/flutter_lints) as its base, then reapplies the Solana Kit analyzer severities and project-specific lint policy.

### Adding package-specific overrides

If a specific package needs to adjust a rule, add overrides after the include:

```yaml
include: package:solana_kit_lints/analysis_options.yaml

linter:
  rules:
    avoid_print: false # Allow print in example/CLI packages
```

## Configuration

The shared `analysis_options.yaml` provided by this package includes [`very_good_analysis`](https://pub.dev/packages/very_good_analysis) as its base and applies the following customizations:

### Base

```yaml
include: package:very_good_analysis/analysis_options.yaml
```

Flutter packages use a separate preset because Dart analysis options only allow one top-level `include`:

```yaml
include: package:flutter_lints/flutter.yaml
```

That Flutter preset then layers the Solana Kit rules back on top.

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

### Lint rule customizations

The following rules from the base presets are customized for this project:

| Rule                                            | Value   | Reason                                                                                                               |
| ----------------------------------------------- | ------- | -------------------------------------------------------------------------------------------------------------------- |
| `public_member_api_docs`                        | `true`  | Published packages should document public API.                                                                       |
| `lines_longer_than_80_chars`                    | `false` | Disabled because many error messages, type signatures, and constant names in the SDK naturally exceed 80 characters. |
| `cancel_subscriptions`                          | `true`  | Catch leaked stream subscriptions.                                                                                   |
| `close_sinks`                                   | `true`  | Catch leaked sinks and controllers.                                                                                  |
| `avoid_equals_and_hash_code_on_mutable_classes` | `false` | Value-like mutable classes are allowed where package APIs require them.                                              |

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
    public_member_api_docs: true
    lines_longer_than_80_chars: false
    cancel_subscriptions: true
    close_sinks: true
    avoid_equals_and_hash_code_on_mutable_classes: false
```

## API Reference

### Provided files

- **`lib/analysis_options.yaml`** -- The shared analysis options file that all Dart packages include. Built on top of `very_good_analysis` with project-specific customizations.
- **`lib/flutter_analysis_options.yaml`** -- The shared analysis options file for Flutter packages. Built on top of `flutter_lints` with the Solana Kit analyzer severities and project-specific customizations layered back in.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_lints"|replace:"__EXAMPLE_PATH__":"example/README.md"|replace:"__IMPORT_PATH__":"N/A (lint package)"} -->

## Example

Use [`example/README.md`](./example/README.md) as a runnable starting point for `solana_kit_lints`.

- Import path: `N/A (lint package)`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
