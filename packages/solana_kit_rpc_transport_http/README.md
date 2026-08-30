# solana_kit_rpc_transport_http

[![pub package](https://img.shields.io/pub/v/solana_kit_rpc_transport_http.svg)](https://pub.dev/packages/solana_kit_rpc_transport_http) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_rpc_transport_http/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_transport_http) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_rpc_transport_http)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_rpc_transport_http)

HTTP transport for sending JSON-RPC requests to Solana nodes. Ships two factory functions: `createHttpTransport` for generic JSON-RPC over HTTP, and `createHttpTransportForSolanaRpc` for Solana-specific BigInt-aware JSON handling. Most apps use `createSolanaRpc` from `solana_kit_rpc` instead of calling these directly.

<!-- {=packageInstallSection:"solana_kit_rpc_transport_http"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_rpc_transport_http": ^0.9.0
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_rpc_transport_http"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_rpc_transport_http
- API reference: https://pub.dev/documentation/solana_kit_rpc_transport_http/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_transport_http
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_rpc_transport_http

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Generic HTTP transport

`createHttpTransport` creates a generic JSON-RPC transport that sends POST requests with JSON payloads.

```dart
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

Future<void> main() async {
  final transport = createHttpTransport(
    HttpTransportConfig(url: 'https://api.mainnet-beta.solana.com'),
  );

  final response = await transport(
    RpcTransportConfig(
      payload: {
        'id': '1',
        'jsonrpc': '2.0',
        'method': 'getSlot',
        'params': <Object?>[],
      },
    ),
  );
  print(response);
}
```

### Custom headers

Pass custom headers through `HttpTransportConfig`. The `accept`, `content-length`, and `content-type` headers are set automatically and cannot be overridden. Forbidden headers (per the MDN specification) are rejected.

```dart
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

void main() {
  final transport = createHttpTransport(
    HttpTransportConfig(
      url: 'https://api.mainnet-beta.solana.com',
      headers: {
        'x-api-key': 'my-secret-key',
        'authorization': 'Bearer my-token',
      },
    ),
  );
  print(transport);
}
```

### Custom JSON serialization

Provide `toJson` and `fromJson` functions to control how payloads are serialized and responses are deserialized.

```dart
import 'dart:convert';
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

void main() {
  final transport = createHttpTransport(
    HttpTransportConfig(
      url: 'https://api.mainnet-beta.solana.com',
      toJson: (payload) => jsonEncode(payload),
      fromJson: (rawResponse, payload) => jsonDecode(rawResponse),
    ),
  );
  print(transport);
}
```

### Solana-specific HTTP transport

`createHttpTransportForSolanaRpc` creates a transport with BigInt-aware JSON handling. It uses `parseJsonWithBigInts` and `stringifyJsonWithBigInts` for Solana RPC requests and standard `jsonEncode`/`jsonDecode` for other requests.

```dart
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

Future<void> main() async {
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
  // Response has BigInt values for large integers.
  final result = response as Map<String, Object?>;
  final value = result['result'] as Map<String, Object?>;
  print(value['value'] is BigInt); // true
}
```

Pass custom headers and an `http.Client` for testing:

```dart
import 'package:http/http.dart' as http;
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

void main() {
  final transport = createHttpTransportForSolanaRpc(
    url: 'https://api.devnet.solana.com',
    headers: {'x-api-key': 'my-key'},
    client: http.Client(),
  );
  print(transport);
}
```

### Checking for Solana requests

`isSolanaRequest` checks whether a payload is a JSON-RPC 2.0 request for a known Solana RPC method. The transport uses this internally to decide whether to apply BigInt-aware JSON handling.

```dart
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

void main() {
  final payload = {
    'jsonrpc': '2.0',
    'method': 'getBalance',
    'params': ['address123'],
    'id': '1',
  };
  print(isSolanaRequest(payload)); // true

  final nonSolana = {
    'jsonrpc': '2.0',
    'method': 'custom_method',
    'params': <Object?>[],
    'id': '1',
  };
  print(isSolanaRequest(nonSolana)); // false
}
```

### Header validation

`assertIsAllowedHttpRequestHeaders` validates that no forbidden or protocol-reserved headers are included. It is called automatically in debug mode by `createHttpTransport`.

```dart
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

void main() {
  // These are fine.
  assertIsAllowedHttpRequestHeaders({
    'x-api-key': 'my-key',
    'authorization': 'Bearer token',
  });

  // These throw (forbidden/disallowed headers).
  // assertIsAllowedHttpRequestHeaders({'content-type': 'text/plain'}); // throws
  // assertIsAllowedHttpRequestHeaders({'host': 'example.com'}); // throws
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

- `createHttpTransport(HttpTransportConfig, {http.Client?})`: creates a generic `RpcTransport` that sends JSON-RPC requests over HTTP POST.
- `createHttpTransportForSolanaRpc({required String url, ...})`: creates an `RpcTransport` with BigInt-aware JSON serialization for Solana RPC.
- `isSolanaRequest(Object?)`: returns `true` if the payload is a JSON-RPC 2.0 request for a known Solana method.
- `assertIsAllowedHttpRequestHeaders(Map<String, String>)`: throws if any forbidden or protocol-reserved headers are present.
- `normalizeHeaders(Map<String, String>)`: lowercases all header names.
- `HttpTransportConfig`: `url`, `headers`, `toJson`, `fromJson`.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_rpc_transport_http"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_rpc_transport_http`.

- Import path: `package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
