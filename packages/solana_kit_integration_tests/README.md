# solana_kit_integration_tests

On-chain integration tests for Solana Kit program clients against a local
[SurfPool](https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_surfpool)
validator.

[![pub package](https://img.shields.io/pub/v/solana_kit_integration_tests.svg)](https://pub.dev/packages/solana_kit_integration_tests)

This is an internal, non-published workspace package. It depends on every
generated program client (system, token, token-2022, memo, compute-budget,
stake, loader, address-lookup-table, associated-token-account, subscriptions,
mpl-bubblegum) and exercises their instruction builders end-to-end against a
real SurfPool Surfnet instance.

## Running

The `test:integration` workspace script starts a SurfPool instance on
`localhost:8899` and runs every `test/integration/**` directory tagged
`integration`:

```bash
devenv shell -- test:integration
```

To run a single suite against an already-running SurfPool:

```bash
devenv shell -- surfpool start   # in another terminal
dart test packages/solana_kit_integration_tests/test/integration/memo_test.dart --tags integration
```

## Shared harness

[`IntegrationTestEnv`](lib/src/integration_test_env.dart) connects to a running
SurfPool, funds a payer, and exposes `sendInstructions(...)` which builds,
signs, sends, and confirms a transaction from any program-client instruction.

```dart
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';

final env = await IntegrationTestEnv.connect();
await env.sendInstructions([
  getAddMemoInstruction(programAddress: memoProgramAddress, memo: 'hi'),
]);
```
