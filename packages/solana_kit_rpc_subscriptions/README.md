# solana_kit_rpc_subscriptions

[![pub package](https://img.shields.io/pub/v/solana_kit_rpc_subscriptions.svg)](https://pub.dev/packages/solana_kit_rpc_subscriptions) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_rpc_subscriptions/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_subscriptions) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_rpc_subscriptions)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_rpc_subscriptions)

Subscription client for the Solana Kit Dart SDK. `createSolanaRpcSubscriptions` wires a WebSocket channel, the subscriptions API, JSON serialization, and error handling into a client that streams account, signature, log, slot, and program notifications.

<!-- {=packageInstallSection:"solana_kit_rpc_subscriptions"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_rpc_subscriptions": ^0.9.2
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_rpc_subscriptions"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_rpc_subscriptions
- API reference: https://pub.dev/documentation/solana_kit_rpc_subscriptions/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_subscriptions
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_rpc_subscriptions

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Subscribing to notifications

`createSolanaRpcSubscriptions` returns a client whose `request` method returns a `PendingRpcSubscriptionsRequest`. Call `.subscribe(...)` to send the JSON-RPC subscription request and await its server subscription ID. The returned stream emits only the matching notification result payloads; other requests and subscriptions on a shared channel are filtered out. Cancel with a `CancellationTokenSource` to unsubscribe and release listeners. Notifications that arrive during acquisition are retained until the first listener attaches, up to 1024 events; exceeding this bound ends the subscription with a `StateError`. Listen promptly after acquisition. Cancellation before acknowledgement still releases a late server subscription when its ID arrives.

```dart
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

Future<void> main() async {
  final subscriptions = createSolanaRpcSubscriptions(
    'wss://api.mainnet-beta.solana.com',
  );

  final controller = CancellationTokenSource();

  final pending = subscriptions.request('slotNotifications');
  final stream = await pending.subscribe(
    RpcSubscribeOptions(abortSignal: controller.token),
  );

  var count = 0;
  await for (final notification in stream) {
    print('Slot: $notification');
    count++;
    if (count >= 3) {
      controller.cancel();
    }
  }
}
```

### Typed subscription methods

The client exposes typed helpers for each subscription method, with parameter builders from `solana_kit_rpc_subscriptions_api`.

```dart
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

Future<void> main() async {
  final subscriptions = createSolanaRpcSubscriptions(
    'wss://api.mainnet-beta.solana.com',
  );

  final controller = CancellationTokenSource();
  final stream = await subscriptions
      .request('slotNotifications')
      .subscribe(RpcSubscribeOptions(abortSignal: controller.token));

  await for (final notification in stream) {
    print(notification);
    controller.cancel();
  }
}
```

## Key APIs

- `createSolanaRpcSubscriptions(url, [config])`: the standard client factory.
- `RpcSubscriptions` interface with `request(methodName, params)`.
- `PendingRpcSubscriptionsRequest.subscribe(options)` returning a `Stream`.
- `RpcSubscribeOptions` with `abortSignal` for cancellation.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_rpc_subscriptions"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_rpc_subscriptions`.

- Import path: `package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
