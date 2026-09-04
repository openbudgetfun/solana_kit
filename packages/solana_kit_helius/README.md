# solana_kit_helius

[![pub package](https://img.shields.io/pub/v/solana_kit_helius.svg)](https://pub.dev/packages/solana_kit_helius) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_helius/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_helius) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_helius)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_helius)

A Dart client for the [Helius API](https://github.com/helius-labs/helius-sdk), covering the DAS API, enhanced transactions, webhooks, smart transactions, ZK compression, staking, the wallet API, WebSocket subscriptions, and auth.

## What you get

- **DAS API**: query assets, proofs, and metadata
- **Enhanced transactions**: parsed transaction history with human-readable types
- **Webhooks**: create, manage, and delete webhook subscriptions
- **Transaction utilities**: priority fee policies, signed transaction broadcasting, and confirmation polling
- **ZK compression**: compressed account and token operations via Light Protocol
- **Staking**: create stake, unstake, and withdraw transactions via Helius validators
- **Wallet API**: identity resolution, balances, history, and transfers
- **WebSockets**: real-time subscription support
- **Auth**: project and API key management
- **Priority fees**: estimate priority fees for transactions
- **RPC V2**: enhanced RPC methods with pagination

## Upstream compatibility

This package was audited against `helius-labs/helius-sdk` v3.0.0 at commit [`4c0c55b86eab0e3abde7896c0aa23c4b6515e9b0`](https://github.com/helius-labs/helius-sdk/commit/4c0c55b86eab0e3abde7896c0aa23c4b6515e9b0) (`chore(release): Update CHANGELOG (#330)`, 2026-05-30). Helius has not published a Git tag for that release, so this commit is the comparison baseline.

The package covers the broad v3 surface: DAS, priority fees, RPC v2 including `getTransfersByAddress`, enhanced transactions, webhook CRUD/toggle, ZK compression, staking, wallet operations, Sender, the v3 JWT-based signup/checkout/payment flow, Admin project usage, and WebSocket subscriptions. The mainnet REST default follows v3's `https://api-mainnet.helius-rpc.com/v0` host, while devnet enhanced REST continues to use `https://api-devnet.helius.xyz/v0`.

The legacy smart-transaction facade does not yet implement the v3 transaction-building contract: `createSmartTransaction` only fetches a blockhash, `sendSmartTransaction` does not compile or sign instructions, and `getComputeUnits` does not serialize a transaction for simulation. These three helpers cannot complete their advertised transaction flows. Prefer Solana Kit's transaction-message, signer, and Sender APIs until that surface is replaced. Remaining v3 gaps also include smart-transaction tip helpers and enhanced WebSocket account/transaction subscriptions.

`pollTransactionConfirmation` and `sendBundleWithSender` check on-chain execution errors before accepting confirmation. A failed transaction throws its corresponding `SolanaError`, even when its signature is confirmed or finalized. A higher commitment satisfies a lower requested commitment; confirmation alone never establishes that the intended transfer executed successfully.

The JSON-RPC and REST transports sanitize connection exceptions so API keys and URL user credentials are omitted from their messages. WebSocket connection errors also omit URL user credentials.

Preconfirmation subscriptions wait for WebSocket readiness. Connection failure or closure rejects pending requests and closes notification streams without exposing endpoint credentials. `PreconfWsClient` accepts `channelFactory` for custom connectors; `close()` is safe to repeat, including before connection readiness.

<!-- {=packageInstallSection:"solana_kit_helius"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_helius": ^0.6.1
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_helius"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_helius
- API reference: https://pub.dev/documentation/solana_kit_helius/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_helius
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_helius

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

Create a client with your API key, then call the sub-clients:

```dart
import 'package:solana_kit_helius/solana_kit_helius.dart';

Future<void> main() async {
  final helius = createHelius(HeliusConfig(apiKey: 'your-api-key'));

  // DAS API
  final asset = await helius.das.getAsset(
    GetAssetRequest(id: 'asset-id'),
  );

  // Priority fees
  final fees = await helius.priorityFee.getPriorityFeeEstimate(
    GetPriorityFeeEstimateRequest(
      accountKeys: ['account-key'],
    ),
  );

  // Enhanced transactions
  final txns = await helius.enhanced.getTransactions(
    GetTransactionsRequest(transactions: ['tx-sig']),
  );

  print(asset);
  print(fees);
  print(txns);
}
```

### Authenticated signup

`signup` uses the developer API's wallet-signup response as a bearer JWT, then uses that JWT for project and checkout calls. Project API keys are only returned after subscription provisioning and are never reused as bearer tokens.

```dart
import 'package:solana_kit_helius/solana_kit_helius.dart';

Future<void> main() async {
  final helius = createHelius(HeliusConfig(apiKey: 'your-api-key'));

  final base64EncodedSolanaCliKeypair = 'base64-encoded-keypair';
  final result = await helius.auth.signup(
    SignupRequest.secretKey(
      secretKey: base64EncodedSolanaCliKeypair,
      plan: 'developer',
      email: 'ada@example.com',
      firstName: 'Ada',
      lastName: 'Lovelace',
    ),
  );

  print(result);
}
```

Only pay `PaymentLink` values received from a trusted Helius developer API. The payment helper rejects non-positive amounts, mismatched memo/intent IDs, and non-payment link kinds before constructing a transfer.

## Configuration

```dart
import 'package:http/http.dart' as http;
import 'package:solana_kit_helius/solana_kit_helius.dart';

void main() {
  // Mainnet (default)
  final mainnet = createHelius(HeliusConfig(apiKey: 'your-api-key'));

  // Devnet
  final devnet = createHelius(
    HeliusConfig(
      apiKey: 'your-api-key',
      cluster: HeliusCluster.devnet,
    ),
  );

  // Custom HTTP client (useful for testing)
  final withClient = createHelius(
    HeliusConfig(apiKey: 'your-api-key'),
    client: http.Client(),
  );

  print(mainnet);
  print(devnet);
  print(withClient);
}
```

## WebSocket security defaults

`HeliusWebSocket` enforces `wss://` URLs and rejects localhost plus non-public IP literals by default. Use `allowInsecureWs: true` and `allowPrivateHosts: true` only for local development and controlled tests. The private-host check does not resolve DNS names, so do not accept arbitrary WebSocket URLs from untrusted input.

## Testing strategy

The Helius package keeps DTO smoke coverage, but long-term confidence should come from higher-level contracts:

- shared REST and JSON-RPC client contract tests cover request shaping, headers, query merging, and error mapping
- endpoint tests focus on user-facing request/response behavior
- websocket session tests cover subscribe, notification routing, unsubscribe, and close boundaries across concurrent subscriptions

When adding a new Helius surface, prefer extending one of these boundaries before adding large amounts of DTO-only roundtrip coverage.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_helius"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_helius/solana_kit_helius.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_helius`.

- Import path: `package:solana_kit_helius/solana_kit_helius.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
