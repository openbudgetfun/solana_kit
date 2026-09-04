# solana_kit_rpc_transformers

[![pub package](https://img.shields.io/pub/v/solana_kit_rpc_transformers.svg)](https://pub.dev/packages/solana_kit_rpc_transformers) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_rpc_transformers/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_transformers) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_rpc_transformers)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_rpc_transformers)

Request and response transformers for the Solana Kit Dart SDK.

Transformers sit between the transport and the typed RPC layer. They inject default commitments into requests, upcast large integers to `BigInt` in responses, and throw structured `SolanaError`s for RPC failures. `solana_kit_rpc` and `solana_kit_rpc_subscriptions` use these internally.

<!-- {=packageInstallSection:"solana_kit_rpc_transformers"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_rpc_transformers": ^0.9.1
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_rpc_transformers"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_rpc_transformers
- API reference: https://pub.dev/documentation/solana_kit_rpc_transformers/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_transformers
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_rpc_transformers

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Default request transformer

`getDefaultRequestTransformerForSolanaRpc` injects a default commitment into requests that accept one.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  final transformer = getDefaultRequestTransformerForSolanaRpc(
    const RequestTransformerConfig(defaultCommitment: Commitment.confirmed),
  );

  final transformed = transformer(
    RpcRequest<Object?>(
      methodName: 'getBalance',
      params: <Object?>[
        '11111111111111111111111111111111',
        <String, Object?>{'minContextSlot': BigInt.from(123)},
      ],
    ),
  );

  print('Transformed params: ${transformed.params}');
}
```

### Default response transformer

`getDefaultResponseTransformerForSolanaRpc` composes error throwing, result extraction, and BigInt upcast.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';

void main() {
  final transformer = getDefaultResponseTransformerForSolanaRpc();

  final request = RpcRequest<Object?>(
    methodName: 'getSlot',
    params: [],
  );
  final response = <String, Object?>{
    'jsonrpc': '2.0',
    'id': 1,
    'result': 42,
  };

  final result = transformer(response, request);
  print(result);
}
```

### Tree walker transformers

`getTreeWalkerRequestTransformer` and `getTreeWalkerResponseTransformer` walk request or response payloads node by node, applying visitor functions. Use `KEYPATH_WILDCARD` to match any key at a given position.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';

void main() {
  NodeVisitor uppercaseVisitor = (value, state) {
    if (value is String) return value.toUpperCase();
    return value;
  };

  final transformer = getTreeWalkerRequestTransformer(
    [uppercaseVisitor],
    const TraversalState(keyPath: []),
  );

  final request = RpcRequest<Object?>(
    methodName: 'test',
    params: ['hello', {'name': 'world'}],
  );

  final result = transformer(request);
  print(result.params); // ['HELLO', {'name': 'WORLD'}]
}
```

## Key APIs

- `getDefaultRequestTransformerForSolanaRpc`, `getDefaultResponseTransformerForSolanaRpc`.
- `getTreeWalkerRequestTransformer`, `getTreeWalkerResponseTransformer`, `NodeVisitor`, `TraversalState`, `KEYPATH_WILDCARD`.
- `parseJsonWithBigInts`, `stringifyJsonWithBigInts`.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_rpc_transformers"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_rpc_transformers`.

- Import path: `package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
