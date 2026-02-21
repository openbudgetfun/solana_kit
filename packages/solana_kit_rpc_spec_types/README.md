# solana_kit_rpc_spec_types

RPC spec type definitions for the Solana Kit Dart SDK.

This is the Dart port of [`@solana/rpc-spec-types`](https://github.com/anza-xyz/kit/tree/main/packages/rpc-spec-types) from the Solana TypeScript SDK.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_rpc_spec_types:
```

If you are working within the `solana_kit` monorepo, the package resolves through the Dart workspace. Otherwise, specify a version or path as needed.

## Usage

### RpcRequest

The `RpcRequest` class describes an RPC request with a method name and parameters.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

final request = RpcRequest<List<Object?>>(
  methodName: 'getBalance',
  params: ['83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK'],
);

print(request.methodName); // 'getBalance'
print(request.params); // ['83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK']
```

### Request transformers

An `RpcRequestTransformer` is a function that transforms an `RpcRequest` before it is sent. This enables patterns like applying defaults, renaming methods, or serializing values.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

// A transformer that prefixes all method names.
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
print(transformed.methodName); // 'custom_getSlot'
```

### RPC response types

The `RpcResponseData` sealed class represents the data in an RPC response, which is either a successful result or an error.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

// A successful response.
const success = RpcResponseResult<int>(id: '1', result: 42);
print(success.result); // 42

// An error response.
const error = RpcResponseError<int>(
  id: '1',
  error: RpcErrorResponsePayload(
    code: -32601,
    message: 'Method not found',
  ),
);
print(error.error.code); // -32601
print(error.error.message); // 'Method not found'

// Pattern matching on sealed types.
void handleResponse(RpcResponseData<int> data) {
  switch (data) {
    case RpcResponseResult<int>(:final result):
      print('Got result: $result');
    case RpcResponseError<int>(:final error):
      print('Got error: ${error.message}');
  }
}
```

### Response transformers

An `RpcResponseTransformer` transforms a raw response before returning it to the caller. It receives both the response and the original request for context.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

// A transformer that doubles numeric results.
RpcResponseTransformer<Object?> doubleTransformer = (response, request) {
  if (response is int) {
    return response * 2;
  }
  return response;
};
```

### Creating JSON-RPC messages

The `createRpcMessage` function builds a spec-compliant JSON-RPC 2.0 message with an auto-incrementing string ID.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

final message = createRpcMessage(RpcRequest(
  methodName: 'getSlot',
  params: [],
));
print(message);
// {id: '0', jsonrpc: '2.0', method: 'getSlot', params: []}

// Each call gets a new ID.
final message2 = createRpcMessage(RpcRequest(
  methodName: 'getBalance',
  params: ['address123'],
));
print(message2['id']); // '1'
```

### BigInt-aware JSON parsing

The `parseJsonWithBigInts` and `stringifyJsonWithBigInts` functions handle the fact that Solana RPC responses can contain integers larger than what IEEE 754 doubles can represent. All non-floating-point numbers are parsed as `BigInt`.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

// Parse JSON with BigInt support.
final parsed = parseJsonWithBigInts('{"balance": 9007199254740993, "rate": 1.5}');
final map = parsed as Map<String, Object?>;
print(map['balance'] is BigInt); // true
print(map['balance']); // 9007199254740993 (as BigInt, no precision loss)
print(map['rate'] is double); // true (floating-point preserved as double)

// Stringify with BigInt support.
final json = stringifyJsonWithBigInts({
  'balance': BigInt.parse('9007199254740993'),
  'rate': 1.5,
});
print(json); // {"balance":9007199254740993,"rate":1.5}
// Note: BigInt values are rendered as raw integers, not quoted strings.
```

## API Reference

### Classes

- **`RpcRequest<TParams>`** -- Describes an RPC request with `methodName` (`String`) and `params` (`TParams`).
- **`RpcResponseData<T>`** -- Sealed class representing an RPC response: either `RpcResponseResult<T>` or `RpcResponseError<T>`.
- **`RpcResponseResult<T>`** -- A successful RPC response with `id` and `result`.
- **`RpcResponseError<T>`** -- An error RPC response with `id` and `error`.
- **`RpcErrorResponsePayload`** -- Error payload with `code` (`int`), `message` (`String`), and optional `data`.

### Functions

- **`createRpcMessage<TParams>(RpcRequest<TParams> request)`** -- Creates a JSON-RPC 2.0 message map with auto-incrementing ID.
- **`parseJsonWithBigInts(String json)`** -- Parses JSON, converting all integer values to `BigInt` while preserving floating-point numbers as `double`.
- **`stringifyJsonWithBigInts(Object? value)`** -- Converts a value to JSON, rendering `BigInt` values as unquoted large integers.

### Typedefs

- **`RpcRequestTransformer`** -- `RpcRequest<Object?> Function(RpcRequest<Object?> request)` -- Transforms an RPC request before sending.
- **`RpcResponseTransformer<T>`** -- `T Function(Object? response, RpcRequest<Object?> request)` -- Transforms an RPC response before returning.
