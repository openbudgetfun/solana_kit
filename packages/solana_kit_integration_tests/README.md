# solana_kit_integration_tests

[![pub package](https://img.shields.io/pub/v/solana_kit_integration_tests.svg)](https://pub.dev/packages/solana_kit_integration_tests)

On-chain compatibility tests for Solana Kit against an isolated local [Surfpool](https://github.com/solana-foundation/surfpool) validator.

This is an internal, non-published workspace package. It exercises the SDK's complete transaction path, Solana's official programs, Anchor programs, WebSocket subscriptions, and pinned ecosystem programs from Metaplex and Squads. Each suite asserts an observable on-chain outcome after using the public Dart builders, signers, transports, confirmation helpers, introspection helpers, and account decoders.

## Running

The `test:integration` workspace script discovers every `test/integration/**` directory tagged `integration`. Each test file starts its own Surfpool process on auto-allocated HTTP and WebSocket ports, so files remain isolated and can run concurrently:

```bash
devenv shell -- test:integration
```

To run one suite with its own Surfpool process:

```bash
devenv shell -- bash -lc \
  'fvm dart test packages/solana_kit_integration_tests/test/integration/anchor_compatibility_test.dart'
```

## Compatibility contracts

| Suite                                                                                                                                          | Expected on-chain outcome                                                                                                                                                                                                                                                                                                 |
| ---------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `core_sdk_compatibility_test.dart`                                                                                                             | Immutable signed bytes remain valid; RPC wire data introspects into the original instruction; ALT-loaded accounts retain identity and roles; mutable batch inputs cannot relabel responses; mint allocation and initialization remain atomic; packed instructions all execute; priority fees retain their unsigned value. |
| `anchor_compatibility_test.dart`                                                                                                               | An Anchor 0.31 program accepts IDL-encoded instructions, creates and mutates accounts decoded by `AnchorCoder`, emits attributable events, enforces signer and `has_one` constraints, returns canonical standard/custom errors, and rolls failed transactions back.                                                       |
| `rpc_subscriptions_compatibility_test.dart`                                                                                                    | Standard `accountSubscribe` and `signatureSubscribe` requests deliver confirmed notifications and cancellation closes the streams through the matching unsubscribe protocol.                                                                                                                                              |
| `upstream_program_compatibility_test.dart`                                                                                                     | Pinned MPL Core, Token Metadata, and Squads V4 programs accept their generated Dart instructions; create/update/transfer/reallocation outcomes decode through the generated account codecs.                                                                                                                               |
| `system`, `token`, `token_2022`, `associated_token_account`, `address_lookup_table`, `compute_budget`, `config`, `loader`, `memo`, and `stake` | Official program builders produce accepted instructions and the resulting balances, owners, authorities, data, and lifecycle states match the requested operations.                                                                                                                                                       |
| `subscriptions_test.dart`                                                                                                                      | The pinned Subscriptions program completes authority, plan, subscription, delegation, and cancellation flows at its canonical PDAs.                                                                                                                                                                                       |
| `mpl_bubblegum_test.dart`                                                                                                                      | The pinned Bubblegum and Account Compression programs create a tree and complete compressed NFT mint, transfer, and burn flows with valid proofs.                                                                                                                                                                         |
| `pyth_test.dart` and `error_paths_test.dart`                                                                                                   | Runtime signature, insufficient-funds, and compute-limit failures surface through the documented SDK error path without appearing successful.                                                                                                                                                                             |

The workspace-wide validation lanes and the expected outcome for every Dart package are recorded in [`config/surfpool-compatibility.json`](../../config/surfpool-compatibility.json). A root test requires every package to belong to exactly one lane and rejects missing evidence paths. Hosted APIs, device wallets, browser adapters, and pure offline formats use contract or platform tests because a local validator cannot emulate those boundaries.

## Shared harness

[`IntegrationTestEnv`](lib/src/integration_test_env.dart) starts an isolated Surfpool process, funds a payer, and exposes `sendInstructions(...)`, which builds, signs, sends, and confirms a transaction from any program-client instruction. It can also deploy committed binaries compiled from pinned upstream source.

```dart
import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_memo/solana_kit_memo.dart';

Future<void> main() async {
  final env = await IntegrationTestEnv.create();
  await env.sendInstructions([
    getAddMemoInstruction(programAddress: memoProgramAddress, memo: 'hi'),
  ]);
}
```
