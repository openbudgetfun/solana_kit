# solana_kit_rpc_api

[![pub package](https://img.shields.io/pub/v/solana_kit_rpc_api.svg)](https://pub.dev/packages/solana_kit_rpc_api) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_rpc_api/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_api) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_rpc_api)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_rpc_api)

RPC method type definitions and parameter builders for the Solana Kit Dart SDK.

This package defines the request and response shapes for every Solana JSON-RPC method: config classes like `GetBalanceConfig`, parameter builders like `getBalanceParams`, and the response types those calls return. `solana_kit_rpc` composes these into the typed client you call directly.

<!-- {=packageInstallSection:"solana_kit_rpc_api"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_rpc_api": ^0.9.0
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_rpc_api"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_rpc_api
- API reference: https://pub.dev/documentation/solana_kit_rpc_api/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_api
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_rpc_api

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Building method parameters

Each RPC method has a `get<Method>Params` function that turns typed arguments into the JSON-RPC params list.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  const target = Address('11111111111111111111111111111111');
  const config = GetBalanceConfig(commitment: Commitment.finalized);

  final params = getBalanceParams(target, config);

  print('RPC method params: $params');
}
```

### Composing an API

`createSolanaRpcApi` assembles the full set of method builders into a map you can pass to an `Rpc` implementation.

```dart
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';

void main() {
  final api = createSolanaRpcApi();
  print(api.runtimeType);
}
```

## Key APIs

- Config classes: `GetBalanceConfig`, `GetLatestBlockhashConfig`, `GetAccountInfoConfig`, and the rest of the method configs.
- Parameter builders: `getBalanceParams`, `getLatestBlockhashParams`, `getAccountInfoParams`, and so on.
- `createSolanaRpcApi()`: the composed method map.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_rpc_api"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_rpc_api/solana_kit_rpc_api.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_rpc_api`.

- Import path: `package:solana_kit_rpc_api/solana_kit_rpc_api.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
