<p align="center">
  <img src="./assets/solana-kit-icon.svg" alt="solana_kit logo" width="140" />
</p>

<h1 align="center">solana_kit</h1>

<p align="center">
  A modern Dart toolkit for building Solana applications with typed RPC, composable transactions, binary codecs, signers, subscriptions, and program clients.
</p>

<p align="center">
  <a href="https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml"><img src="https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="https://codecov.io/gh/openbudgetfun/solana_kit"><img src="https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg" alt="coverage" /></a>
  <a href="https://openbudgetfun.github.io/solana_kit/"><img src="https://img.shields.io/badge/docs-openbudgetfun.github.io-0A7EA4.svg" alt="documentation" /></a>
</p>

---

## What it is

`solana_kit` brings the ideas and API shape of [`@solana/kit`](https://github.com/anza-xyz/kit) to Dart while leaning into Dart's strengths: extension types, sealed classes, records, patterns, and fluent composition.

It is designed for apps, CLIs, servers, Flutter projects, tests, and tooling that need to speak Solana without hand-writing JSON-RPC payloads or byte layouts.

- **Typed RPC** — method helpers such as `rpc.getSlot()` and `rpc.getLatestBlockhashValue()` instead of raw method strings.
- **Composable transactions** — build, sign, size-check, serialize, send, and confirm transactions through small explicit steps.
- **Binary codecs** — encode and decode Solana data with reusable codecs for numbers, strings, structs, arrays, unions, options, and bytes.
- **Signer abstractions** — model local key pairs, partial signers, fee payers, sending signers, wallet signers, and no-op signers clearly.
- **Subscriptions** — consume account, signature, log, slot, and program notifications through WebSocket-backed clients.
- **Program tooling** — use generated and handwritten clients for core Solana programs and Metaplex/SPL surfaces.

## Upstream compatibility

- Latest supported `@solana/kit` version: `6.9.0`
- This Dart port tracks upstream APIs and behavior through `v6.9.0`.

> **Parity with intent**
>
> The project follows `@solana/kit` closely where parity matters: addresses, signatures, transaction compilation, serialization, RPC behavior, and selected error semantics.
>
> When Dart intentionally differs for safety or ergonomics, the difference should be documented instead of hidden behind a silent compatibility change.

## Quick start

### Add the package

```yaml
dependencies:
  solana_kit: ^0.4.0
```

Program packages can be added separately when you need a smaller dependency graph or a specific on-chain program. Browse the full package map on the [documentation website](https://openbudgetfun.github.io/solana_kit/).

### Create an RPC client

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');

  final slot = await rpc.getSlot().send();
  final blockhash = await rpc.getLatestBlockhashValue().send();

  print('Current slot: $slot');
  print('Latest blockhash: ${blockhash.value.blockhash}');
}
```

`rpc.getSlot()` creates a typed request. The network call only happens when you call `.send()`, which keeps requests easy to inspect, compose, cache, batch, or wrap with middleware.

### Generate a signer

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  final signer = generateKeyPairSigner();

  print('Address: ${signer.address}');
}
```

Use key-pair signers for tests, automation, server-side flows, and local scripts. Wallet-driven applications can use the signer interfaces to represent fee payers, partial signers, sending signers, and externally managed signatures.

### Build a transaction message

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
  final feePayer = generateKeyPairSigner();
  final latestBlockhash = await rpc.getLatestBlockhashValue().send();

  final message = createTransactionMessage(version: TransactionVersion.v0)
      .withFeePayer(feePayer.address)
      .withBlockhashLifetime(
        BlockhashLifetimeConstraint(
          blockhash: latestBlockhash.value.blockhash.value,
          lastValidBlockHeight: latestBlockhash.value.lastValidBlockHeight,
        ),
      );

  print(message);
}
```

Transaction construction is deliberately explicit: choose the version, set who pays, set how long the message is valid, then append instructions. That makes fee payment, expiry, and instruction ordering visible in code.

## Design principles

- **Dart-first ergonomics** — mirror Solana concepts without forcing TypeScript shapes where Dart has a clearer model.
- **Type safety at the boundary** — catch invalid addresses, malformed data, missing accounts, and impossible states before they become runtime surprises.
- **Small, composable pieces** — keep codecs, RPC, transactions, signers, accounts, and program clients useful independently.
- **Explicit over magical** — transaction building, signing, sending, and confirmation are separate steps that can be inspected and tested.
- **Parity where it matters** — match upstream behavior for wire formats and protocol semantics while documenting intentional Dart differences.
- **No hidden package maze** — use `solana_kit` for the common path, or import lower-level packages directly when you need tighter control.

## Learn more

- [Documentation website](https://openbudgetfun.github.io/solana_kit/)
- [Examples](./examples)
- [Security policy](./SECURITY.md)
- [`@solana/kit`](https://github.com/anza-xyz/kit)

<div hidden>

<!-- workspace-summary:start -->

This monorepo contains **48 packages** under `packages/`: **46 publishable** and **2 internal** (`solana_kit_lints`, `solana_kit_test_matchers`).

<!-- workspace-summary:end -->

<!-- workspace-dependency-graph:start -->

```text
solana_kit -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs, solana_kit_errors, solana_kit_fast_stable_stringify, solana_kit_functional, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_keys, solana_kit_offchain_messages, solana_kit_options, solana_kit_program_client_core, solana_kit_programs, solana_kit_rpc, solana_kit_rpc_parsed_types, solana_kit_rpc_spec_types, solana_kit_rpc_subscriptions, solana_kit_rpc_transport_http, solana_kit_rpc_types, solana_kit_signers, solana_kit_subscribable, solana_kit_sysvars, solana_kit_transaction_confirmation, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_accounts -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_strings, solana_kit_errors, solana_kit_rpc, solana_kit_rpc_api, solana_kit_rpc_spec, solana_kit_rpc_types
solana_kit_addresses -> solana_kit_codecs_core, solana_kit_codecs_strings, solana_kit_errors
solana_kit_associated_token_account -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_errors, solana_kit_instructions
solana_kit_codecs -> solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_fixed_points, solana_kit_options
solana_kit_codecs_core -> solana_kit_errors
solana_kit_codecs_data_structures -> solana_kit_codecs_core, solana_kit_codecs_numbers, solana_kit_errors
solana_kit_codecs_numbers -> solana_kit_codecs_core, solana_kit_errors
solana_kit_codecs_strings -> solana_kit_codecs_core, solana_kit_codecs_numbers, solana_kit_errors
solana_kit_compute_budget -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_instructions
solana_kit_errors -> (none)
solana_kit_fast_stable_stringify -> (none)
solana_kit_fixed_points -> (none)
solana_kit_functional -> (none)
solana_kit_helius -> solana_kit_errors
solana_kit_instruction_plans -> solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_signers, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_instructions -> solana_kit_addresses, solana_kit_errors
solana_kit_keys -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_strings, solana_kit_errors
solana_kit_lints -> (none)
solana_kit_mobile_wallet_adapter -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_mobile_wallet_adapter_protocol, solana_kit_transactions
solana_kit_mobile_wallet_adapter_protocol -> solana_kit_codecs_strings, solana_kit_errors
solana_kit_mpl_bubblegum -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_keys, solana_kit_spl_account_compression
solana_kit_offchain_messages -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_keys
solana_kit_options -> solana_kit_codecs_core, solana_kit_codecs_numbers, solana_kit_errors
solana_kit_program_client_core -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs_core, solana_kit_errors, solana_kit_instructions, solana_kit_rpc_spec, solana_kit_rpc_types, solana_kit_signers
solana_kit_programs -> solana_kit_addresses, solana_kit_errors
solana_kit_rpc -> solana_kit_addresses, solana_kit_errors, solana_kit_fast_stable_stringify, solana_kit_keys, solana_kit_rpc_api, solana_kit_rpc_spec, solana_kit_rpc_spec_types, solana_kit_rpc_transformers, solana_kit_rpc_transport_http, solana_kit_rpc_types
solana_kit_rpc_api -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_rpc_parsed_types, solana_kit_rpc_spec, solana_kit_rpc_spec_types, solana_kit_rpc_transformers, solana_kit_rpc_types, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_rpc_parsed_types -> solana_kit_addresses, solana_kit_errors, solana_kit_rpc_types
solana_kit_rpc_spec -> solana_kit_errors, solana_kit_rpc_spec_types
solana_kit_rpc_spec_types -> solana_kit_errors
solana_kit_rpc_subscriptions -> solana_kit_addresses, solana_kit_errors, solana_kit_fast_stable_stringify, solana_kit_keys, solana_kit_rpc_spec_types, solana_kit_rpc_subscriptions_api, solana_kit_rpc_subscriptions_channel_websocket, solana_kit_rpc_types, solana_kit_subscribable
solana_kit_rpc_subscriptions_api -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_rpc_types
solana_kit_rpc_subscriptions_channel_websocket -> solana_kit_errors, solana_kit_subscribable
solana_kit_rpc_transformers -> solana_kit_errors, solana_kit_rpc_spec_types, solana_kit_rpc_types
solana_kit_rpc_transport_http -> solana_kit_errors, solana_kit_rpc_spec, solana_kit_rpc_spec_types
solana_kit_rpc_types -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors
solana_kit_signers -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_spl_account_compression -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_keys
solana_kit_subscribable -> solana_kit_errors
solana_kit_system -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_instructions
solana_kit_sysvars -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_errors, solana_kit_rpc_spec, solana_kit_rpc_types
solana_kit_test_matchers -> solana_kit_accounts, solana_kit_addresses, solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_rpc, solana_kit_rpc_spec, solana_kit_rpc_subscriptions, solana_kit_rpc_types, solana_kit_signers, solana_kit_subscribable, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_token -> solana_kit_accounts, solana_kit_addresses, solana_kit_associated_token_account, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_system
solana_kit_token_2022 -> solana_kit_accounts, solana_kit_addresses, solana_kit_associated_token_account, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_options, solana_kit_signers, solana_kit_system
solana_kit_transaction_confirmation -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_rpc, solana_kit_rpc_api, solana_kit_rpc_spec, solana_kit_rpc_subscriptions_channel_websocket, solana_kit_rpc_types, solana_kit_subscribable, solana_kit_transactions
solana_kit_transaction_messages -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instructions
solana_kit_transactions -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_transaction_messages
```

<!-- workspace-dependency-graph:end -->

</div>
