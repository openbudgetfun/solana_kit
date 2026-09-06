# solana_kit_functional

[![pub package](https://img.shields.io/pub/v/solana_kit_functional.svg)](https://pub.dev/packages/solana_kit_functional) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_functional/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_functional) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_functional)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_functional)

> [!WARNING]
> This package is deprecated and kept only as a compatibility shim. New code should import the `Pipe` extension from `package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart` or the umbrella `package:solana_kit/solana_kit.dart` instead.
>
> The standalone `solana_kit_functional` package may be removed in a future release once downstream migration is complete.

The `Pipe` extension that used to live here now lives in `solana_kit_transaction_messages`. This package is an empty placeholder that exists so existing imports keep resolving during migration.

<!-- {=packageInstallSection:"solana_kit_functional"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_functional": ^0.9.2
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_functional"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_functional
- API reference: https://pub.dev/documentation/solana_kit_functional/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_functional
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_functional

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

Import `Pipe` from `solana_kit_transaction_messages` instead:

```dart
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

void main() {
  final result = 5.pipe((value) => value * 2 + 1);

  print(result); // 11
}
```

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_functional"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_functional/solana_kit_functional.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_functional`.

- Import path: `package:solana_kit_functional/solana_kit_functional.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
