# solana_kit_rpc_spec

[![pub package](https://img.shields.io/pub/v/solana_kit_rpc_spec.svg)](https://pub.dev/packages/solana_kit_rpc_spec) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_rpc_spec/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_spec) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_rpc_spec)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_rpc_spec)

The transport-agnostic core of the Solana RPC stack: `Rpc`, `RpcRequest`, `RpcTransport`, and the `createRpc` factory that binds an API map to a transport.

Use this package when you are building a custom RPC client or transport. Most applications use `solana_kit_rpc`, which composes this core with the Solana method set and HTTP transport.

<!-- {=packageInstallSection:"solana_kit_rpc_spec"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_rpc_spec": ^0.9.2
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_rpc_spec"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_rpc_spec
- API reference: https://pub.dev/documentation/solana_kit_rpc_spec/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_spec
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_rpc_spec

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Creating an RPC over a custom transport

`createRpc` binds an API map to a transport function. Each API entry returns an `RpcPlan` that describes how to execute the request.

```dart
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

Future<void> main() async {
  final rpc = createRpc(
    RpcConfig(
      api: MapRpcApi({
        'ping': (params) {
          return RpcPlan<Object?>(
            execute: (config) => config.transport(
              RpcTransportConfig(
                payload: createRpcMessage(
                  RpcRequest<List<Object?>>(methodName: 'ping', params: params),
                ),
                signal: config.signal,
              ),
            ),
          );
        },
      }),
      transport: (_) async => <String, Object?>{'ok': true},
    ),
  );

  final result = await rpc.request('ping', ['demo']).send();
  print('RPC result: $result');
}
```

### Pending requests

`rpc.request(...)` returns a `PendingRpcRequest<T>` that only executes when you call `.send()`. This lets callers build, cache, and batch requests before hitting the network.

```dart
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

Future<void> main() async {
  final rpc = createRpc(
    RpcConfig(
      api: MapRpcApi({}),
      transport: (_) async => <String, Object?>{'result': 1},
    ),
  );

  final pending = rpc.request<Object?>('getSlot', <Object?>[]);
  final result = await pending.send();
  print(result);
}
```

## Key APIs

- `Rpc`, `RpcRequest<T>`, `RpcResponse<T>`, `PendingRpcRequest<T>`.
- `createRpc`, `RpcConfig`, `MapRpcApi`, `RpcPlan`.
- `RpcTransport`, `RpcTransportConfig`, `createRpcMessage`.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_rpc_spec"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_rpc_spec`.

- Import path: `package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
