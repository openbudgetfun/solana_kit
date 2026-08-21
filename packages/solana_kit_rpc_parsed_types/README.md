# solana_kit_rpc_parsed_types

[![pub package](https://img.shields.io/pub/v/solana_kit_rpc_parsed_types.svg)](https://pub.dev/packages/solana_kit_rpc_parsed_types) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_rpc_parsed_types/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_parsed_types) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_rpc_parsed_types)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_rpc_parsed_types)

Parsed account data types for the Solana Kit Dart SDK.

When an RPC call returns `jsonParsed` account data, the response carries a `type` string and an `info` map. This package defines those shapes, including the typed variants for well-known programs such as SPL Token.

<!-- {=packageInstallSection:"solana_kit_rpc_parsed_types"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_rpc_parsed_types": ^0.8.0
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_rpc_parsed_types"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_rpc_parsed_types
- API reference: https://pub.dev/documentation/solana_kit_rpc_parsed_types/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_parsed_types
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_rpc_parsed_types

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Parsed account data

`RpcParsedType` models the `{type, info}` shape of a `jsonParsed` account response.

```dart
import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';

void main() {
  const parsed = RpcParsedType(
    type: 'spl-token-account',
    info: {'mint': 'So11111111111111111111111111111111111111112'},
  );

  print('Parsed type: ${parsed.type}');
  print('Parsed info: ${parsed.info}');
}
```

### Typed token variants

For SPL Token accounts, the package provides typed variants of the parsed data so you can pattern match instead of casting maps.

```dart
import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';

void main() {
  const parsed = RpcParsedType(
    type: 'spl-token-account',
    info: {'mint': 'So11111111111111111111111111111111111111112'},
  );

  print(parsed.type);
}
```

## Key APIs

- `RpcParsedType`: the generic `{type, info}` shape.
- Typed variants for well-known programs (for example SPL Token account and mint data).

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_rpc_parsed_types"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_rpc_parsed_types`.

- Import path: `package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
