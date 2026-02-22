# solana_kit_rpc_spec

[![pub package](https://img.shields.io/pub/v/solana_kit_rpc_spec.svg)](https://pub.dev/packages/solana_kit_rpc_spec)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_rpc_spec/latest/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

RPC specification implementation for the Solana Kit Dart SDK.

This is the Dart port of [`@solana/rpc-spec`](https://github.com/anza-xyz/kit/tree/main/packages/rpc-spec) from the Solana TypeScript SDK.

## Installation

Install with:

```bash
dart pub add solana_kit_rpc_spec
```

If you are working within the `solana_kit` monorepo, the package resolves through the Dart workspace. Otherwise, specify a version or path as needed.

## Documentation

- Package page: https://pub.dev/packages/solana_kit_rpc_spec
- API reference: https://pub.dev/documentation/solana_kit_rpc_spec/latest/

## Usage

### Creating an RPC client

The `Rpc` class is the main RPC client. It wraps an `RpcApi` (which defines how method calls become `RpcPlan` instances) and an `RpcTransport` (which handles the actual network communication). Use `createRpc` to construct one.

```dart
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

final rpc = createRpc(
  RpcConfig(
    api: JsonRpcApiAdapter(createJsonRpcApi()),
    transport: myTransport,
  ),
);

// Call an RPC method. This returns a PendingRpcRequest.
final pending = rpc.request('getSlot');

// Send the request and await the response.
final slot = await pending.send();
print('Current slot: $slot');
```

### PendingRpcRequest

Calling `rpc.request(methodName, params)` returns a `PendingRpcRequest` that encapsulates all the information needed to make the request without actually making it. The request is only triggered when you call `.send()`.

```dart
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

final rpc = createRpc(RpcConfig(api: myApi, transport: myTransport));

// Build the request without sending it.
final pending = rpc.request('getBalance', ['address123']);

// Send with optional abort signal.
final result = await pending.send(RpcSendOptions(
  abortSignal: Future.delayed(Duration(seconds: 10)),
));
```

### RpcTransport

An `RpcTransport` is a function that takes a `RpcTransportConfig` and returns a `Future<Object?>`. It is responsible for sending the request payload to the server and returning the raw response.

```dart
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

// A simple mock transport.
RpcTransport mockTransport = (RpcTransportConfig config) async {
  final payload = config.payload as Map<String, Object?>;
  final method = payload['method'] as String;

  if (method == 'getSlot') {
    return {
      'jsonrpc': '2.0',
      'result': BigInt.from(12345),
      'id': payload['id'],
    };
  }

  return {
    'jsonrpc': '2.0',
    'error': {'code': -32601, 'message': 'Method not found'},
    'id': payload['id'],
  };
};
```

### Checking JSON-RPC payloads

The `isJsonRpcPayload` function checks whether a value is a valid JSON-RPC 2.0 payload (has `jsonrpc: '2.0'`, a `method` string, and `params`).

```dart
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

final validPayload = {
  'jsonrpc': '2.0',
  'method': 'getSlot',
  'params': [],
  'id': '1',
};

print(isJsonRpcPayload(validPayload)); // true
print(isJsonRpcPayload({'not': 'valid'})); // false
print(isJsonRpcPayload(null)); // false
```

### JsonRpcApi

The `JsonRpcApi` class converts method calls into `RpcPlan` instances that create JSON-RPC 2.0 payloads. It supports optional request and response transformers.

```dart
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

// Create with custom transformers.
final api = createJsonRpcApi(
  config: RpcApiConfig(
    requestTransformer: (request) {
      // Log every request.
      print('Calling ${request.methodName} with ${request.params}');
      return request;
    },
    responseTransformer: (response, request) {
      // Extract the result from a JSON-RPC response.
      if (response is Map<String, Object?>) {
        return response['result'];
      }
      return response;
    },
  ),
);

// Call a method. Returns an RpcPlan.
final plan = api.call('getSlot', []);
```

### RpcApi implementations

There are multiple ways to create an `RpcApi`:

```dart
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

// 1. JsonRpcApiAdapter: wraps a JsonRpcApi for dynamic method dispatch.
final dynamicApi = JsonRpcApiAdapter(createJsonRpcApi());

// 2. MapRpcApi: define handlers for specific methods.
final mapApi = MapRpcApi({
  'getSlot': (params) => RpcPlan(
    execute: (config) async {
      final response = await config.transport(
        RpcTransportConfig(payload: {
          'jsonrpc': '2.0',
          'method': 'getSlot',
          'params': params,
          'id': '1',
        }),
      );
      return response;
    },
  ),
});

// Use either with createRpc.
final rpc = createRpc(RpcConfig(api: dynamicApi, transport: myTransport));
```

### Creating JSON-RPC messages

The `createRpcMessage` function (from `solana_kit_rpc_spec_types`) generates a spec-compliant JSON-RPC 2.0 message with an auto-incrementing ID.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

final message = createRpcMessage(RpcRequest(
  methodName: 'getBalance',
  params: ['address123'],
));

print(message);
// {id: '0', jsonrpc: '2.0', method: 'getBalance', params: ['address123']}
```

## API Reference

### Classes

- **`Rpc`** -- The main RPC client. Wraps an `RpcApi` and `RpcTransport` to create `PendingRpcRequest` instances. Call `request(methodName, [params])` to build a request and `.send()` to execute it.
- **`RpcConfig`** -- Configuration for `createRpc`: `api` (`RpcApi`) and `transport` (`RpcTransport`).
- **`PendingRpcRequest<T>`** -- A lazy RPC request. Call `.send([RpcSendOptions])` to trigger the network request.
- **`RpcSendOptions`** -- Options for sending a request, including an optional `abortSignal` (`Future<void>`).
- **`RpcApi`** -- Abstract base class for RPC APIs. Override `getPlan(methodName, params)` to return `RpcPlan` instances.
- **`JsonRpcApiAdapter`** -- An `RpcApi` backed by a `JsonRpcApi`.
- **`MapRpcApi`** -- An `RpcApi` backed by a map of method-name-to-handler functions.
- **`JsonRpcApi`** -- Converts method calls into `RpcPlan` instances with JSON-RPC 2.0 payloads.
- **`RpcApiConfig`** -- Configuration for `JsonRpcApi`: optional `requestTransformer` and `responseTransformer`.
- **`RpcPlan<T>`** -- Describes how a particular RPC request should be issued. Contains an `execute` function.
- **`RpcPlanExecuteConfig`** -- Passed to `RpcPlan.execute`: `transport` and optional `signal`.
- **`RpcTransportConfig`** -- Configuration for an `RpcTransport` call: `payload` and optional `signal`.

### Functions

- **`createRpc(RpcConfig config)`** -- Creates an `Rpc` instance from the given configuration.
- **`createJsonRpcApi({RpcApiConfig? config})`** -- Creates a `JsonRpcApi` with optional transformers.
- **`isJsonRpcPayload(Object? payload)`** -- Returns `true` if the payload is a valid JSON-RPC 2.0 message.

### Typedefs

- **`RpcTransport`** -- `Future<Object?> Function(RpcTransportConfig config)` -- A function that sends an RPC request.
- **`RpcApiMethod`** -- `RpcPlan<Object?> Function(String methodName, List<Object?> params)` -- A function that creates plans from method calls.
