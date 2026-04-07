---
title: Package Index
description: Category-level map of the Solana Kit workspace packages with guidance on where to start.
---

Use this page when you need to answer: **which package should I import?**

For full per-package rationale and package-by-package usage guidance, continue to [Complete Package Catalog](package-catalog).

## Start with the umbrella package unless you have a reason not to

If you're building an application and want the smoothest experience for the core SDK surface, start with:

- [`solana_kit`](https://pub.dev/packages/solana_kit)

Then move to smaller packages only when you want a narrower dependency surface or a stricter architectural boundary. Program-specific packages such as `solana_kit_system` and `solana_kit_token` should always be imported explicitly.

## Umbrella

- [`solana_kit`](https://pub.dev/packages/solana_kit)
- [`solana_kit_codecs`](https://pub.dev/packages/solana_kit_codecs)

## Core primitives

- [`solana_kit_addresses`](https://pub.dev/packages/solana_kit_addresses)
- [`solana_kit_keys`](https://pub.dev/packages/solana_kit_keys)
- [`solana_kit_signers`](https://pub.dev/packages/solana_kit_signers)
- [`solana_kit_errors`](https://pub.dev/packages/solana_kit_errors)

## Transaction stack

- [`solana_kit_instructions`](https://pub.dev/packages/solana_kit_instructions)
- [`solana_kit_transaction_messages`](https://pub.dev/packages/solana_kit_transaction_messages)
- [`solana_kit_transactions`](https://pub.dev/packages/solana_kit_transactions)
- [`solana_kit_transaction_confirmation`](https://pub.dev/packages/solana_kit_transaction_confirmation)
- [`solana_kit_instruction_plans`](https://pub.dev/packages/solana_kit_instruction_plans)

## RPC + subscriptions

- [`solana_kit_rpc`](https://pub.dev/packages/solana_kit_rpc)
- [`solana_kit_rpc_api`](https://pub.dev/packages/solana_kit_rpc_api)
- [`solana_kit_rpc_types`](https://pub.dev/packages/solana_kit_rpc_types)
- [`solana_kit_rpc_transport_http`](https://pub.dev/packages/solana_kit_rpc_transport_http)
- [`solana_kit_rpc_subscriptions`](https://pub.dev/packages/solana_kit_rpc_subscriptions)
- [`solana_kit_rpc_subscriptions_api`](https://pub.dev/packages/solana_kit_rpc_subscriptions_api)
- [`solana_kit_rpc_subscriptions_channel_websocket`](https://pub.dev/packages/solana_kit_rpc_subscriptions_channel_websocket)
- [`solana_kit_subscribable`](https://pub.dev/packages/solana_kit_subscribable)

## Accounts + programs

- [`solana_kit_accounts`](https://pub.dev/packages/solana_kit_accounts)
- [`solana_kit_programs`](https://pub.dev/packages/solana_kit_programs)
- [`solana_kit_program_client_core`](https://pub.dev/packages/solana_kit_program_client_core)
- [`solana_kit_sysvars`](https://pub.dev/packages/solana_kit_sysvars)
- [`solana_kit_rpc_parsed_types`](https://pub.dev/packages/solana_kit_rpc_parsed_types)

## Codecs + options

- [`solana_kit_codecs_core`](https://pub.dev/packages/solana_kit_codecs_core)
- [`solana_kit_codecs_numbers`](https://pub.dev/packages/solana_kit_codecs_numbers)
- [`solana_kit_codecs_strings`](https://pub.dev/packages/solana_kit_codecs_strings)
- [`solana_kit_codecs_data_structures`](https://pub.dev/packages/solana_kit_codecs_data_structures)
- [`solana_kit_options`](https://pub.dev/packages/solana_kit_options)

## Program clients

- [`solana_kit_system`](https://pub.dev/packages/solana_kit_system)
- [`solana_kit_token`](https://pub.dev/packages/solana_kit_token)
- [`solana_kit_token_2022`](https://pub.dev/packages/solana_kit_token_2022)
- [`solana_kit_associated_token_account`](https://pub.dev/packages/solana_kit_associated_token_account)
- [`solana_kit_compute_budget`](https://pub.dev/packages/solana_kit_compute_budget)

## Specialized integrations

- [`solana_kit_mobile_wallet_adapter`](https://pub.dev/packages/solana_kit_mobile_wallet_adapter)
- [`solana_kit_mobile_wallet_adapter_protocol`](https://pub.dev/packages/solana_kit_mobile_wallet_adapter_protocol)
- [`solana_kit_helius`](https://pub.dev/packages/solana_kit_helius)

## Utilities

- [`solana_kit_functional`](https://pub.dev/packages/solana_kit_functional)
- [`solana_kit_fast_stable_stringify`](https://pub.dev/packages/solana_kit_fast_stable_stringify)

## Helpful follow-ups

- [Quick Start](../getting-started/quick-start)
- [Accounts](../core/accounts)
- [Codecs](../core/codecs)
- [Transactions](../core/transactions)
- [Complete Package Catalog](package-catalog)
