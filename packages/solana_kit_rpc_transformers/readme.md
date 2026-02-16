# solana_kit_rpc_transformers

Request and response transformers for the Solana Kit Dart SDK.

This is the Dart port of [`@solana/rpc-transformers`](https://github.com/anza-xyz/kit/tree/main/packages/rpc-transformers) from the Solana TypeScript SDK.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_rpc_transformers:
```

If you are working within the `solana_kit` monorepo, the package resolves through the Dart workspace. Otherwise, specify a version or path as needed.

## Usage

This package provides helpers for transforming Solana JSON-RPC requests and responses in various ways. The default transformers handle BigInt conversion, integer overflow detection, default commitment injection, error throwing, and result extraction.

### Default request transformer

The `getDefaultRequestTransformerForSolanaRpc` function composes three request transformers into one:

1. **Integer overflow check** -- Detects BigInt values that exceed the safe JavaScript integer range.
2. **BigInt downcast** -- Converts all BigInt values to int for JSON encoding compatibility.
3. **Default commitment** -- Injects a default commitment level when none is provided.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

final transformer = getDefaultRequestTransformerForSolanaRpc(
  RequestTransformerConfig(
    defaultCommitment: Commitment.confirmed,
    onIntegerOverflow: (request, keyPath, value) {
      print('Overflow in ${request.methodName} at $keyPath: $value');
    },
  ),
);

final request = RpcRequest<Object?>(
  methodName: 'getBalance',
  params: ['address123', {'commitment': null}],
);

final transformed = transformer(request);
// The commitment will be set to 'confirmed' and BigInt values downcast.
```

### Default response transformer

The `getDefaultResponseTransformerForSolanaRpc` function composes three response transformers:

1. **Throw on error** -- Throws a `SolanaError` if the response body contains an error.
2. **Result extraction** -- Extracts the `result` field from the JSON-RPC response.
3. **BigInt upcast** -- Converts integer values to BigInt (except those in allowed numeric key paths).

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';

final transformer = getDefaultResponseTransformerForSolanaRpc(
  ResponseTransformerConfig(
    allowedNumericKeyPaths: {
      'getAccountInfo': [
        ['value', 'data', 'parsed', 'info', 'tokenAmount', 'decimals'],
      ],
    },
  ),
);

// Successful response.
final response = {
  'jsonrpc': '2.0',
  'result': {
    'context': {'slot': BigInt.from(12345)},
    'value': BigInt.from(1000000),
  },
  'id': '1',
};

final request = RpcRequest<Object?>(
  methodName: 'getBalance',
  params: ['address123'],
);

final result = transformer(response, request);
// Returns {'context': {'slot': BigInt(12345)}, 'value': BigInt(1000000)}
```

### BigInt downcast request transformer

Converts all `BigInt` values in request parameters to `int`, since JSON encoding does not support `BigInt` directly.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';

final transformer = getBigIntDowncastRequestTransformer();

final request = RpcRequest<Object?>(
  methodName: 'getBalance',
  params: ['address', {'minContextSlot': BigInt.from(100)}],
);

final result = transformer(request);
// params now contain int(100) instead of BigInt(100)
```

### Integer overflow request transformer

Walks the request parameter tree and invokes the provided handler whenever a `BigInt` value exceeds the safe JavaScript integer range (2^53 - 1).

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';

final transformer = getIntegerOverflowRequestTransformer(
  (request, keyPath, value) {
    throw Exception(
      'Value $value at path $keyPath in ${request.methodName} exceeds safe range',
    );
  },
);

final request = RpcRequest<Object?>(
  methodName: 'sendTransaction',
  params: [BigInt.parse('9007199254740993')], // MAX_SAFE_INTEGER + 1
);

// This will invoke the handler and throw.
// transformer(request);
```

### Default commitment request transformer

Injects a default commitment level into the options object of RPC methods that accept one, but only when the caller has not already specified a commitment.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

final transformer = getDefaultCommitmentRequestTransformer(
  optionsObjectPositionByMethod: OPTIONS_OBJECT_POSITION_BY_METHOD,
  defaultCommitment: Commitment.confirmed,
);

// Request without commitment -> gets 'confirmed' injected.
final request = RpcRequest<Object?>(
  methodName: 'getBalance',
  params: ['address123'],
);
final result = transformer(request);
// params: ['address123', {'commitment': 'confirmed'}]
```

### BigInt upcast response transformer

Converts all integer values in a response to `BigInt`, except for values at specified key paths which remain as `int`.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';

// Keep 'decimals' as int, upcast everything else to BigInt.
final transformer = getBigIntUpcastResponseTransformer([
  ['value', 'data', 'parsed', 'info', 'tokenAmount', 'decimals'],
]);

final request = RpcRequest<Object?>(
  methodName: 'getAccountInfo',
  params: ['address123'],
);

final response = {
  'value': {
    'lamports': 1000000,
    'data': {
      'parsed': {
        'info': {
          'tokenAmount': {'amount': '1000000', 'decimals': 6},
        },
      },
    },
  },
};

final result = transformer(response, request);
// 'lamports' -> BigInt(1000000), 'decimals' -> int(6)
```

### Result response transformer

Extracts the `result` field from a JSON-RPC 2.0 response envelope.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';

final transformer = getResultResponseTransformer();
final request = RpcRequest<Object?>(methodName: 'getSlot', params: []);

final result = transformer(
  {'jsonrpc': '2.0', 'result': BigInt.from(12345), 'id': '1'},
  request,
);
print(result); // BigInt(12345)
```

### Throw Solana error response transformer

Inspects the response for a JSON-RPC error field and throws a `SolanaError` if one is found.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';

final transformer = getThrowSolanaErrorResponseTransformer();
final request = RpcRequest<Object?>(methodName: 'getSlot', params: []);

try {
  transformer(
    {
      'jsonrpc': '2.0',
      'error': {'code': -32005, 'message': 'Node is unhealthy'},
      'id': '1',
    },
    request,
  );
} on SolanaError catch (e) {
  print(e.code); // SolanaErrorCode.jsonRpcServerErrorNodeUnhealthy
}
```

### Tree traversal

The `getTreeWalkerRequestTransformer` and `getTreeWalkerResponseTransformer` functions create transformers that recursively traverse data structures and apply visitor functions at each leaf node.

```dart
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';

// A visitor that converts all strings to uppercase.
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
// params: ['HELLO', {'name': 'WORLD'}]
```

You can use `KEYPATH_WILDCARD` to match any key at a given position in a key path:

```dart
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';

// Match any element in an array.
final keyPath = ['accounts', KEYPATH_WILDCARD, 'balance'];
// Matches: accounts[0].balance, accounts[1].balance, etc.
```

## API Reference

### Request Transformers

- **`getDefaultRequestTransformerForSolanaRpc([RequestTransformerConfig?])`** -- Composes the integer overflow, BigInt downcast, and default commitment transformers.
- **`getBigIntDowncastRequestTransformer()`** -- Downcasts all `BigInt` values to `int`.
- **`getIntegerOverflowRequestTransformer(IntegerOverflowHandler)`** -- Detects BigInt values that exceed the safe integer range.
- **`getDefaultCommitmentRequestTransformer({required Map optionsObjectPositionByMethod, Commitment? defaultCommitment})`** -- Injects a default commitment into RPC method options.
- **`getTreeWalkerRequestTransformer(List<NodeVisitor>, TraversalState)`** -- Creates a request transformer from a list of tree-walking visitors.

### Response Transformers

- **`getDefaultResponseTransformerForSolanaRpc([ResponseTransformerConfig?])`** -- Composes error throwing, result extraction, and BigInt upcast transformers.
- **`getDefaultResponseTransformerForSolanaRpcSubscriptions([ResponseTransformerConfig?])`** -- BigInt upcast transformer only (for WebSocket subscriptions).
- **`getBigIntUpcastResponseTransformer(List<KeyPath>)`** -- Upcasts integers to `BigInt`, except at the specified key paths.
- **`getResultResponseTransformer()`** -- Extracts the `result` field from a JSON-RPC response.
- **`getThrowSolanaErrorResponseTransformer()`** -- Throws a `SolanaError` if the response contains an error.
- **`getTreeWalkerResponseTransformer(List<NodeVisitor>, TraversalState)`** -- Creates a response transformer from a list of tree-walking visitors.

### Configuration Classes

- **`RequestTransformerConfig`** -- Configuration with optional `defaultCommitment` and `onIntegerOverflow`.
- **`ResponseTransformerConfig`** -- Configuration with optional `allowedNumericKeyPaths`.

### Tree Traversal

- **`TraversalState`** -- Holds the current `keyPath` during tree traversal.
- **`KeyPath`** -- `List<Object>` representing a path through a nested data structure.
- **`KEYPATH_WILDCARD`** -- Sentinel value that matches any key at a given level.
- **`NodeVisitor`** -- `Object? Function(Object? value, TraversalState state)` -- A function applied at each leaf node.

### Typedefs

- **`IntegerOverflowHandler`** -- `void Function(RpcRequest<Object?>, KeyPath, BigInt)` -- Called when a BigInt exceeds safe range.
- **`AllowedNumericKeypaths`** -- `Map<String, List<KeyPath>>` -- Maps method names to key paths that should remain as `int`.

### Constants

- **`OPTIONS_OBJECT_POSITION_BY_METHOD`** -- Maps each Solana RPC method name to the index of its options object in the params array.
- **`jsonParsedTokenAccountsConfigs`** -- Key paths for numeric values in parsed token accounts.
- **`jsonParsedAccountsConfigs`** -- Key paths for numeric values in all parsed accounts.
- **`innerInstructionsConfigs`** -- Key paths for numeric values in inner instructions.
- **`messageConfig`** -- Key paths for numeric values in transaction messages.
