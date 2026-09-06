# solana_kit_program_client_core

[![pub package](https://img.shields.io/pub/v/solana_kit_program_client_core.svg)](https://pub.dev/packages/solana_kit_program_client_core) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_program_client_core/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_program_client_core) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_program_client_core)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_program_client_core)

Core building blocks for generated Solana program clients in the Solana Kit Dart SDK.

This package provides the foundational types and utilities used by generated program clients, including instruction types that track storage changes, self-fetch functions for decoder-based account retrieval, and instruction input resolution helpers. You normally reach it through a generated client such as `solana_kit_system` or `solana_kit_token`.

<!-- {=packageInstallSection:"solana_kit_program_client_core"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_program_client_core": ^0.9.2
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_program_client_core"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_program_client_core
- API reference: https://pub.dev/documentation/solana_kit_program_client_core/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_program_client_core
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_program_client_core

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Resolving instruction inputs

Generated instruction builders accept either concrete values or resolvers. The resolution helpers normalize those inputs into the values the builder needs.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_program_client_core/solana_kit_program_client_core.dart';

void main() {
  const account = Address('11111111111111111111111111111111');

  final requiredValue = getNonNullResolvedInstructionInput(
    'authority',
    account,
  );
  final resolvedAddress = getAddressFromResolvedInstructionAccount(
    'authority',
    requiredValue,
  );

  print('Resolved instruction account: ${resolvedAddress.value}');
}
```

### Self-fetch functions

Generated clients expose `fetch*` helpers that retrieve and decode accounts through a decoder, so callers get typed account data without manual RPC plumbing.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

Future<void> main() async {
  const address = Address('11111111111111111111111111111111');
  print(address);
}
```

## Key APIs

- Instruction types that track storage changes.
- Self-fetch functions for decoder-based account retrieval.
- Instruction input resolution helpers (`getNonNullResolvedInstructionInput`, `getAddressFromResolvedInstructionAccount`).

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_program_client_core"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_program_client_core/solana_kit_program_client_core.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_program_client_core`.

- Import path: `package:solana_kit_program_client_core/solana_kit_program_client_core.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
