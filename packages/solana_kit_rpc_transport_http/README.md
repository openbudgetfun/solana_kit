# solana_kit_rpc_transport_http

HTTP transport for the Solana Kit Dart SDK.

This is the Dart port of [`@solana/rpc-transport-http`](https://github.com/anza-xyz/kit/tree/main/packages/rpc-transport-http) from the Solana TypeScript SDK.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_rpc_transport_http:
```

If you are working within the `solana_kit` monorepo, the package resolves through the Dart workspace. Otherwise, specify a version or path as needed.

## Usage

This package provides HTTP transport implementations for sending JSON-RPC requests. It uses the `http` Dart package under the hood.

### Generic HTTP transport

The `createHttpTransport` function creates a generic JSON-RPC transport that sends POST requests with JSON payloads.

```dart
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

final transport = createHttpTransport(
  HttpTransportConfig(url: 'https://api.mainnet-beta.solana.com'),
);

final response = await transport(
  RpcTransportConfig(
    payload: {
      'id': '1',
      'jsonrpc': '2.0',
      'method': 'getSlot',
      'params': [],
    },
  ),
);

print(response);
// {'jsonrpc': '2.0', 'result': 250000000, 'id': '1'}
```

### Custom headers

Pass custom headers through the `HttpTransportConfig`. Note that `accept`, `content-length`, and `content-type` are set automatically and cannot be overridden. Forbidden headers (per the MDN specification) are also rejected.

```dart
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

final transport = createHttpTransport(
  HttpTransportConfig(
    url: 'https://api.mainnet-beta.solana.com',
    headers: {
      'x-api-key': 'my-secret-key',
      'authorization': 'Bearer my-token',
    },
  ),
);
```

### Custom JSON serialization

You can provide custom `toJson` and `fromJson` functions to control how request payloads are serialized and response bodies are deserialized.

```dart
import 'dart:convert';
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

final transport = createHttpTransport(
  HttpTransportConfig(
    url: 'https://api.mainnet-beta.solana.com',
    toJson: (payload) {
      // Custom serialization.
      return jsonEncode(payload);
    },
    fromJson: (rawResponse, payload) {
      // Custom deserialization.
      return jsonDecode(rawResponse);
    },
  ),
);
```

### Solana-specific HTTP transport

The `createHttpTransportForSolanaRpc` function creates a transport with BigInt-aware JSON handling. It uses `parseJsonWithBigInts` and `stringifyJsonWithBigInts` for Solana RPC requests, and standard `jsonEncode`/`jsonDecode` for other requests.

```dart
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

final transport = createHttpTransportForSolanaRpc(
  url: 'https://api.mainnet-beta.solana.com',
);

final response = await transport(
  RpcTransportConfig(
    payload: {
      'id': '1',
      'jsonrpc': '2.0',
      'method': 'getBalance',
      'params': ['83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK'],
    },
  ),
);

// The response will have BigInt values for large integers.
final result = response as Map<String, Object?>;
final value = result['result'] as Map<String, Object?>;
print(value['value'] is BigInt); // true
```

Pass custom headers and an `http.Client` for testing:

```dart
import 'package:http/http.dart' as http;
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

final transport = createHttpTransportForSolanaRpc(
  url: 'https://api.devnet.solana.com',
  headers: {'x-api-key': 'my-key'},
  client: http.Client(), // or a mock client for testing
);
```

### Checking for Solana requests

The `isSolanaRequest` function checks whether a payload is a JSON-RPC 2.0 request for a known Solana RPC method. This is used internally to decide whether to apply BigInt-aware JSON handling.

```dart
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

final payload = {
  'jsonrpc': '2.0',
  'method': 'getBalance',
  'params': ['address123'],
  'id': '1',
};

print(isSolanaRequest(payload)); // true

final nonSolanaPayload = {
  'jsonrpc': '2.0',
  'method': 'custom_method',
  'params': [],
  'id': '1',
};

print(isSolanaRequest(nonSolanaPayload)); // false
```

### Header validation

The `assertIsAllowedHttpRequestHeaders` function validates that no forbidden or protocol-reserved headers are included. It is called automatically in debug mode by `createHttpTransport`.

```dart
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

// These are fine.
assertIsAllowedHttpRequestHeaders({
  'x-api-key': 'my-key',
  'authorization': 'Bearer token',
});

// These will throw (forbidden/disallowed headers).
// assertIsAllowedHttpRequestHeaders({'content-type': 'text/plain'}); // throws
// assertIsAllowedHttpRequestHeaders({'host': 'example.com'}); // throws
// assertIsAllowedHttpRequestHeaders({'sec-fetch-mode': 'cors'}); // throws
```

### Using a mock client for testing

Both `createHttpTransport` and `createHttpTransportForSolanaRpc` accept an optional `http.Client` parameter, making it straightforward to inject a mock for testing.

```dart
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

final mockClient = MockClient((request) async {
  return http.Response(
    '{"jsonrpc":"2.0","result":42,"id":"1"}',
    200,
    headers: {'content-type': 'application/json'},
  );
});

final transport = createHttpTransport(
  HttpTransportConfig(url: 'https://api.mainnet-beta.solana.com'),
  client: mockClient,
);

final response = await transport(
  RpcTransportConfig(
    payload: {'id': '1', 'jsonrpc': '2.0', 'method': 'getSlot', 'params': []},
  ),
);
print(response); // {jsonrpc: 2.0, result: 42, id: 1}
```

## API Reference

### Functions

- **`createHttpTransport(HttpTransportConfig config, {http.Client? client})`** -- Creates a generic `RpcTransport` that sends JSON-RPC requests over HTTP POST. Returns a function matching the `RpcTransport` typedef.
- **`createHttpTransportForSolanaRpc({required String url, Map<String, String>? headers, http.Client? client})`** -- Creates an `RpcTransport` with BigInt-aware JSON serialization for Solana RPC requests. Uses `parseJsonWithBigInts`/`stringifyJsonWithBigInts` for known Solana methods.
- **`isSolanaRequest(Object? payload)`** -- Returns `true` if the payload is a JSON-RPC 2.0 request for a known Solana RPC method.
- **`assertIsAllowedHttpRequestHeaders(Map<String, String> headers)`** -- Throws a `SolanaError` if any headers are forbidden or protocol-reserved.
- **`normalizeHeaders(Map<String, String> headers)`** -- Returns a new map with all header names lowercased.

### Classes

- **`HttpTransportConfig`** -- Configuration for `createHttpTransport`:
  - `url` (`String`, required) -- The target endpoint URL.
  - `headers` (`Map<String, String>?`) -- Optional custom headers.
  - `toJson` (`String Function(Object?)?`) -- Optional custom JSON serializer.
  - `fromJson` (`Object? Function(String, Object?)?`) -- Optional custom JSON deserializer (receives raw response and request payload).
