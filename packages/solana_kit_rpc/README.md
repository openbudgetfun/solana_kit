# solana_kit_rpc

[![pub package](https://img.shields.io/pub/v/solana_kit_rpc.svg)](https://pub.dev/packages/solana_kit_rpc) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_rpc/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_rpc)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_rpc)

The primary RPC client for the Solana Kit Dart SDK. `createSolanaRpc` wires the HTTP transport, request transformers, and typed method builders into a single `Rpc` you can call directly.

Most applications should use this package (or the `solana_kit` umbrella) for JSON-RPC access to a Solana node.

<!-- {=packageInstallSection:"solana_kit_rpc"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_rpc": ^0.9.1
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

### Create a client

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';

Future<void> main() async {
  final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');

  final slot = await rpc.getSlot().send();
  print('Current slot: $slot');

  final balance = await rpc
      .getBalance(const Address('83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK'))
      .send();
  print('Balance: $balance');
}
```

`rpc.getSlot()` builds a typed request. The network call only happens when you call `.send()`, which keeps requests easy to inspect, compose, cache, batch, or wrap with middleware.

<!-- {=typedRpcMethodsSection|replace:"__RPC_IMPORT_PATH__":"package:solana_kit_rpc/solana_kit_rpc.dart"|replace:"__RPC_URL__":"https://api.mainnet-beta.solana.com"} -->

### Typed RPC methods

When you already have an `Rpc`, prefer typed convenience helpers over raw method-name strings. They keep parameter builders and response models attached to the method itself, which makes refactors and autocomplete significantly safer.

```dart
import 'package:solana_kit_rpc/solana_kit_rpc.dart';

Future<void> main() async {
  final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');

  final slot = await rpc.getSlot().send();
  final epochInfo = await rpc.getEpochInfo().send();
  final latestBlockhash = await rpc.getLatestBlockhashValue().send();

  print('Slot: $slot');
  print('Epoch: ${epochInfo['epoch']}');
  print('Latest blockhash: ${latestBlockhash.value.blockhash}');
}
```

These helpers forward to canonical request builders in `solana_kit_rpc_api`, return lazy `PendingRpcRequest<T>` values, and make it clear which Solana RPC shape each call expects.

<!-- {/typedRpcMethodsSection} -->

<!-- {=preferredDartPathCalloutSection|replace:"PREFERRED_PATH_TOKEN":"Start with `createSolanaRpc(...)` plus typed request helpers like `rpc.getSlot()` and `rpc.getLatestBlockhashValue()` before reaching for raw JSON-RPC method names."|replace:"ESCAPE_HATCH_GUIDANCE_TOKEN":"Use raw `rpc.request(...)` only when you need an upstream surface that has not yet been wrapped or when you are validating parity behavior."} -->

> **Preferred Dart path**
>
> Start with `createSolanaRpc(...)` plus typed request helpers like `rpc.getSlot()` and `rpc.getLatestBlockhashValue()` before reaching for raw JSON-RPC method names.
>
> Use raw `rpc.request(...)` only when you need an upstream surface that has not yet been wrapped or when you are validating parity behavior.

<!-- {/preferredDartPathCalloutSection} -->

### Raw requests

For methods without a typed helper, call `rpc.request(methodName, params)` directly.

```dart
import 'package:solana_kit_rpc/solana_kit_rpc.dart';

Future<void> main() async {
  final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');

  final result = await rpc
      .request<Object?>('getSlot', <Object?>[])
      .send();
  print('Raw result: $result');
}
```

### Custom transports

`createSolanaRpcFromTransport` builds a client over any transport, which is how tests inject mocks.

```dart
import 'package:solana_kit_rpc/solana_kit_rpc.dart';

Future<void> main() async {
  final rpc = createSolanaRpcFromTransport(
    (config) async => <String, Object?>{'result': 42},
  );

  final slot = await rpc.getSlot().send();
  print('Mock slot: $slot');
}
```

### Payload deduplication

`getSolanaRpcPayloadDeduplicationKey` produces a stable key for a request payload, useful for caching or batching identical calls.

```dart
import 'package:solana_kit_rpc/solana_kit_rpc.dart';

void main() {
  final payload = <String, Object?>{
    'id': '1',
    'jsonrpc': '2.0',
    'method': 'getBalance',
    'params': ['11111111111111111111111111111111'],
  };

  final dedupeKey = getSolanaRpcPayloadDeduplicationKey(payload);
  print('Deduplication key: $dedupeKey');
}
```

## Key APIs

- `createSolanaRpc({url, ...})`: the standard client factory.
- `createSolanaRpcFromTransport(transport)`: client over a custom transport.
- `Rpc` interface with typed method helpers and `request(...)`.
- `getSolanaRpcPayloadDeduplicationKey(payload)`.

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
