# solana_kit_rpc_subscriptions_channel_websocket

[![pub package](https://img.shields.io/pub/v/solana_kit_rpc_subscriptions_channel_websocket.svg)](https://pub.dev/packages/solana_kit_rpc_subscriptions_channel_websocket) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_rpc_subscriptions_channel_websocket/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_subscriptions_channel_websocket) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_rpc_subscriptions_channel_websocket)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_rpc_subscriptions_channel_websocket)

WebSocket channel transport for Solana RPC subscriptions in the Solana Kit Dart SDK.

Use this package when you need a raw WebSocket channel to feed `solana_kit_rpc_subscriptions`. Most applications call `createSolanaRpcSubscriptions` and never touch this layer directly.

By default, channel URLs must use `wss://` and may not target localhost or non-public IP literals. Alternate numeric IPv4 forms and IPv4-mapped private IPv6 literals are also rejected. This check does not resolve DNS names; do not accept arbitrary endpoint URLs from untrusted input. Controlled local tests must explicitly enable `allowPrivateHosts` (and `allowInsecureWs` for `ws://`).

<!-- {=packageInstallSection:"solana_kit_rpc_subscriptions_channel_websocket"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_rpc_subscriptions_channel_websocket": ^0.9.1
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_rpc_subscriptions_channel_websocket"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_rpc_subscriptions_channel_websocket
- API reference: https://pub.dev/documentation/solana_kit_rpc_subscriptions_channel_websocket/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_subscriptions_channel_websocket
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_rpc_subscriptions_channel_websocket

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Creating a channel

`createWebSocketChannel` opens a WebSocket and returns a channel with `send`, `streams.notifications`, and `close`.

```dart
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

Future<void> main() async {
  final source = CancellationTokenSource();
  final channel = await createWebSocketChannel(
    WebSocketChannelConfig(
      url: Uri.parse('wss://api.mainnet-beta.solana.com'),
      signal: source.token,
    ),
  );

  await channel.send('{"jsonrpc":"2.0","id":1,"method":"slotSubscribe"}');

  await for (final message in channel.streams.notifications) {
    print(message);
    source.cancel();
  }
}
```

### Local development

For local tests, allow `ws://` and private hosts explicitly.

```dart
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

Future<void> main() async {
  final source = CancellationTokenSource();
  final channel = await createWebSocketChannel(
    WebSocketChannelConfig(
      url: Uri.parse('ws://127.0.0.1:8900'),
      allowInsecureWs: true,
      allowPrivateHosts: true,
      signal: source.token,
    ),
  );

  print(channel);
  source.cancel();
}
```

## Key APIs

- `createWebSocketChannel(url, {allowInsecureWs, allowPrivateHosts})`.
- `WebSocketChannel` with `send`, `streams.notifications`, and `close`.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_rpc_subscriptions_channel_websocket"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_rpc_subscriptions_channel_websocket`.

- Import path: `package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
