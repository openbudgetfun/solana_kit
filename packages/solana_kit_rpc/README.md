# solana_kit_rpc

[![pub package](https://img.shields.io/pub/v/solana_kit_rpc.svg)](https://pub.dev/packages/solana_kit_rpc)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_rpc/latest/)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Primary RPC client for the Solana Kit Dart SDK.

This is the Dart port of [`@solana/rpc`](https://github.com/anza-xyz/kit/tree/main/packages/rpc) from the Solana TypeScript SDK.

<!-- {=packageInstallSection:"solana_kit_rpc"} -->

## Installation

Install the package directly:

```bash
dart pub add solana_kit_rpc
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_rpc"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_rpc
- API reference: https://pub.dev/documentation/solana_kit_rpc/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_rpc

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Creating an RPC client

The simplest way to create an RPC client is with `createSolanaRpc`, which sets up a fully configured client with sensible defaults -- including request coalescing, BigInt handling, and a `solana-client` header.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';

final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');

// Make an RPC call.
final slot = await rpc.getSlot().send();
print('Current slot: $slot');

// Query an account balance.
final balance = await rpc.getBalance(
  const Address('83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK'),
).send();
print('Balance: $balance');
```

<!-- {=typedRpcMethodsSection|replace:"__RPC_IMPORT_PATH__":"package:solana_kit_rpc/solana_kit_rpc.dart"|replace:"__RPC_URL__":"https://api.mainnet-beta.solana.com"} -->

### Typed RPC methods

When you already have an `Rpc`, prefer typed convenience helpers over raw
method-name strings. They keep parameter builders and response models attached
to the method itself, which makes refactors and autocomplete significantly
safer.

```dart
import 'package:solana_kit_rpc/solana_kit_rpc.dart';

Future<void> main() async {
  final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');

  final slot = await rpc.getSlot().send();
  final epochInfo = await rpc.getEpochInfo().send();
  final latestBlockhash = await rpc.getLatestBlockhash().send();

  print('Slot: $slot');
  print('Epoch: ${epochInfo['epoch']}');
  print('Latest blockhash: ${latestBlockhash['blockhash']}');
}
```

These helpers forward to canonical request builders in `solana_kit_rpc_api`,
return lazy `PendingRpcRequest<T>` values, and make it clear which Solana RPC
shape each call expects.

<!-- {/typedRpcMethodsSection} -->

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

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_rpc"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_rpc/solana_kit_rpc.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_rpc`.

- Import path: `package:solana_kit_rpc/solana_kit_rpc.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
