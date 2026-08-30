# solana_kit_rpc_spec_types

[![pub package](https://img.shields.io/pub/v/solana_kit_rpc_spec_types.svg)](https://pub.dev/packages/solana_kit_rpc_spec_types) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_rpc_spec_types/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_spec_types) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_rpc_spec_types)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_rpc_spec_types)

Low-level JSON-RPC message and transform types for the Solana Kit Dart SDK. Defines `RpcRequest`, `RpcResponseData` (result or error), request/response transformer typedefs, and BigInt-aware JSON parsing. Other packages in the RPC stack depend on these types rather than reinventing them.

<!-- {=packageInstallSection:"solana_kit_rpc_spec_types"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_rpc_spec_types": ^0.9.0
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_rpc_spec_types"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_rpc_spec_types
- API reference: https://pub.dev/documentation/solana_kit_rpc_spec_types/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_spec_types
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_rpc_spec_types

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### RpcRequest

`RpcRequest` pairs a method name with parameters for a single JSON-RPC call.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

void main() {
  const request = RpcRequest<List<Object?>>(
    methodName: 'getBalance',
    params: ['11111111111111111111111111111111'],
  );

  print(request.methodName); // getBalance
  print(request.params); // [11111111111111111111111111111]
}
```

### RpcResponseData

The `RpcResponseData` sealed class wraps a JSON-RPC response as either a result or an error.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

void main() {
  const success = RpcResponseResult<int>(id: '1', result: 42);
  print(success.result); // 42

  const error = RpcResponseError<int>(
    id: '1',
    error: RpcErrorResponsePayload(
      code: -32601,
      message: 'Method not found',
    ),
  );
  print(error.error.code); // -32601
  print(error.error.message); // 'Method not found'
}
```

### Request and response transformers

`RpcRequestTransformer` and `RpcResponseTransformer` are function types that the RPC spec layer uses to modify payloads before sending and after receiving.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

void main() {
  // Prefix all method names with a namespace.
  RpcRequestTransformer prefixTransformer = (request) {
    return RpcRequest(
      methodName: 'custom_${request.methodName}',
      params: request.params,
    );
  };

  final original = RpcRequest<Object?>(
    methodName: 'getSlot',
    params: [],
  );
  final transformed = prefixTransformer(original);
  print(transformed.methodName); // custom_getSlot
}
```

### JSON-RPC message creation

`createRpcMessage` builds a spec-compliant JSON-RPC 2.0 message with an auto-incrementing string ID.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

void main() {
  final message = createRpcMessage(RpcRequest(
    methodName: 'getSlot',
    params: <Object?>[],
  ));
  print(message['id']); // '0'
  print(message['jsonrpc']); // '2.0'
}
```

### BigInt-aware JSON parsing

`parseJsonWithBigInts` parses JSON so that integer values become `BigInt` instead of `double`, which avoids precision loss on large Solana values like slot numbers and lamports. `stringifyJsonWithBigInts` does the reverse.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

void main() {
  final parsed = parseJsonWithBigInts(
    '{"balance": 9007199254740993, "rate": 1.5}',
  );
  final map = parsed as Map<String, Object?>;
  print(map['balance'] is BigInt); // true
  print(map['rate'] is double); // true

  final json = stringifyJsonWithBigInts({
    'balance': BigInt.parse('9007199254740993'),
    'rate': 1.5,
  });
  print(json); // {"balance":9007199254740993,"rate":1.5}
}
```

<!-- {=isolateJsonDecodeSection|replace:"__RPC_TRANSPORT_IMPORT_PATH__":"package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart"|replace:"__RPC_URL__":"https://api.mainnet-beta.solana.com"} -->

### Optional Isolate JSON Decoding

For large Solana RPC payloads, you can offload BigInt-aware JSON parsing to a background isolate so the main isolate stays responsive.

```dart
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

void main() {
  final transport = createHttpTransportForSolanaRpc(
    url: 'https://api.mainnet-beta.solana.com',
    decodeSolanaJsonInIsolate: true,
    solanaJsonIsolateThreshold: 262144,
  );

  print(transport);
}
```

For direct parsing, use `parseJsonWithBigIntsAsync(...)` with `runInIsolate: true`. Reserve isolate parsing for larger payloads where the extra hop is worth the reduced UI or server-request blocking.

<!-- {/isolateJsonDecodeSection} -->

## Key APIs

- `RpcRequest<TParams>`: method name + params.
- `RpcResponseData<T>`: sealed class, `RpcResponseResult<T>` or `RpcResponseError<T>`.
- `RpcErrorResponsePayload`: error code, message, optional data.
- `createRpcMessage<TParams>(RpcRequest<TParams>)`: builds a JSON-RPC 2.0 message map.
- `parseJsonWithBigInts(String)` / `stringifyJsonWithBigInts(Object?)` / `parseJsonWithBigIntsAsync(String, ...)`: BigInt-safe JSON codec.
- `RpcRequestTransformer`: `RpcRequest<Object?> Function(RpcRequest<Object?>)`.
- `RpcResponseTransformer<T>`: `T Function(Object? response, RpcRequest<Object?> request)`.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_rpc_spec_types"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_rpc_spec_types`.

- Import path: `package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
