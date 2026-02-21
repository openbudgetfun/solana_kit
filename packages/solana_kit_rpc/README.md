# solana_kit_rpc

Primary RPC client for the Solana Kit Dart SDK.

This is the Dart port of [`@solana/rpc`](https://github.com/anza-xyz/kit/tree/main/packages/rpc) from the Solana TypeScript SDK.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_rpc:
```

If you are working within the `solana_kit` monorepo, the package resolves through the Dart workspace. Otherwise, specify a version or path as needed.

## Usage

### Creating an RPC client

The simplest way to create an RPC client is with `createSolanaRpc`, which sets up a fully configured client with sensible defaults -- including request coalescing, BigInt handling, and a `solana-client` header.

```dart
import 'package:solana_kit_rpc/solana_kit_rpc.dart';

final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');

// Make an RPC call.
final slot = await rpc.request('getSlot').send();
print('Current slot: $slot');

// Query an account balance.
final balance = await rpc.request('getBalance', [
  '83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK',
]).send();
print('Balance: $balance');
```

You can pass custom headers and an `http.Client` instance:

```dart
import 'package:http/http.dart' as http;
import 'package:solana_kit_rpc/solana_kit_rpc.dart';

final rpc = createSolanaRpc(
  url: 'https://api.devnet.solana.com',
  headers: {'x-api-key': 'my-api-key'},
  client: http.Client(),
);
```

### Creating an RPC client from a custom transport

When you need full control over how requests are sent (for example, during testing or with a custom HTTP stack), use `createSolanaRpcFromTransport`:

```dart
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

// A mock transport for testing.
RpcTransport myMockTransport = (RpcTransportConfig config) async {
  return {
    'jsonrpc': '2.0',
    'result': BigInt.from(42),
    'id': '0',
  };
};

final rpc = createSolanaRpcFromTransport(myMockTransport);
final slot = await rpc.request('getSlot').send();
print(slot); // 42
```

### Default RPC transport

The `createDefaultRpcTransport` function creates a transport with the standard Solana RPC behaviours applied:

- An automatically-set `solana-client` request header containing the SDK version (cannot be overridden).
- Request coalescing that deduplicates identical calls made within the same microtask.

```dart
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

final transport = createDefaultRpcTransport(
  url: 'https://api.mainnet-beta.solana.com',
);

// Use the transport directly.
final response = await transport(
  RpcTransportConfig(
    payload: {
      'id': '0',
      'jsonrpc': '2.0',
      'method': 'getSlot',
      'params': [],
    },
  ),
);
```

### Request coalescing

When multiple identical requests (same method and params) are made within the same microtask, they are coalesced into a single network request. All callers receive the same response.

```dart
import 'package:solana_kit_rpc/solana_kit_rpc.dart';

final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');

// These two calls happen in the same microtask, so only one
// network request is sent. Both futures resolve with the same result.
final future1 = rpc.request('getSlot').send();
final future2 = rpc.request('getSlot').send();

final results = await Future.wait([future1, future2]);
print(results[0] == results[1]); // true
```

The coalescing key is computed by `getSolanaRpcPayloadDeduplicationKey`, which produces a stable, deterministic key from the method name and params (ignoring `id` and key ordering).

### Integer overflow error

When a `BigInt` value in request parameters exceeds the safe JavaScript integer range, the default configuration throws a `SolanaError`. You can access this factory directly:

```dart
import 'package:solana_kit_rpc/solana_kit_rpc.dart';

try {
  throw createSolanaJsonRpcIntegerOverflowError(
    'getBalance',
    [0, 'lamports'],
    BigInt.parse('9007199254740992'), // Number.MAX_SAFE_INTEGER + 1
  );
} on Exception catch (e) {
  print(e);
  // SolanaError describing the overflow in the 1st argument at path `lamports`
}
```

### Using the default configuration

The `defaultRpcConfig` provides the standard `SolanaRpcApiConfig` used by `createSolanaRpc`. It sets the default commitment to `confirmed` and configures an integer overflow handler that throws.

```dart
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

// Build a custom RPC using the default config with your own transport.
final myCustomRpc = createRpc(
  RpcConfig(
    api: createSolanaRpcApiAdapter(defaultRpcConfig),
    transport: myCustomTransport,
  ),
);
```

## API Reference

### Functions

- **`createSolanaRpc({required String url, Map<String, String>? headers, http.Client? client})`** -- Creates an `Rpc` instance with the standard Solana JSON RPC API given a cluster URL and optional transport configuration.
- **`createSolanaRpcFromTransport(RpcTransport transport)`** -- Creates an `Rpc` instance from a custom `RpcTransport`, applying the standard Solana RPC API and default transformers.
- **`createDefaultRpcTransport({required String url, Map<String, String>? headers, http.Client? client})`** -- Creates the default `RpcTransport` with request coalescing and a `solana-client` header.
- **`getRpcTransportWithRequestCoalescing(RpcTransport transport, GetDeduplicationKeyFn getDeduplicationKey)`** -- Wraps a transport with request coalescing logic that deduplicates identical in-flight requests within the same microtask.
- **`getSolanaRpcPayloadDeduplicationKey(Object? payload)`** -- Returns a stable deduplication key for a JSON-RPC 2.0 payload, or `null` if the payload is not valid.
- **`createSolanaJsonRpcIntegerOverflowError(String methodName, KeyPath keyPath, BigInt value)`** -- Creates a `SolanaError` describing an integer overflow in an RPC request.

### Constants

- **`defaultRpcConfig`** -- The default `SolanaRpcApiConfig` used by `createSolanaRpc`, with `Commitment.confirmed` and an integer overflow handler.

### Typedefs

- **`GetDeduplicationKeyFn`** -- `String? Function(Object? payload)` -- Produces a deduplication key for coalescing, or `null` to skip.
