---
title: Complete Package Catalog
description: Every Solana Kit package, why it exists, what it does, and when to use it.
---

Each subsection below maps one package to its role in the Solana ecosystem and this workspace.

## Umbrella Packages

### solana_kit

- Pub.dev: [solana_kit](https://pub.dev/packages/solana_kit)
- Why it exists: most app teams need one import surface, not dozens of package imports.
- What it does: re-exports the public SDK package set behind one stable entrypoint.
- Use it when: building application code that uses multiple Solana features.

### solana_kit_codecs

- Pub.dev: [solana_kit_codecs](https://pub.dev/packages/solana_kit_codecs)
- Why it exists: codec-heavy apps need one import for all binary serialization helpers.
- What it does: re-exports codec core, number, string, and data-structure codecs.
- Use it when: writing account/program serializers or data ingestion pipelines.

## Error and Domain Foundations

### solana_kit_errors

- Pub.dev: [solana_kit_errors](https://pub.dev/packages/solana_kit_errors)
- Why it exists: Solana failures are domain-specific and should be machine-handleable.
- What it does: provides `SolanaError`, domain helpers, and numeric error codes.
- Use it when: mapping low-level failures to recoverable app behavior.

## Address, Keys, and Signers

### solana_kit_addresses

- Pub.dev: [solana_kit_addresses](https://pub.dev/packages/solana_kit_addresses)
- Why it exists: addresses are core Solana identity primitives and need strict validation.
- What it does: validates addresses, supports encoding/decoding, and derives PDAs.
- Use it when: creating account references, PDAs, and address comparisons.

### solana_kit_keys

- Pub.dev: [solana_kit_keys](https://pub.dev/packages/solana_kit_keys)
- Why it exists: signing and key generation should be typed and standardized across apps.
- What it does: generates key pairs and exposes Solana-compatible key utilities.
- Use it when: generating wallets, deriving public keys, or signing messages.

### solana_kit_signers

- Pub.dev: [solana_kit_signers](https://pub.dev/packages/solana_kit_signers)
- Why it exists: signing flows vary (fee payer, partial signer, delegated signer).
- What it does: defines signer contracts used by transaction and message pipelines.
- Use it when: coordinating multi-signer transaction workflows.

## Codec Layer

### solana_kit_codecs_core

- Pub.dev: [solana_kit_codecs_core](https://pub.dev/packages/solana_kit_codecs_core)
- Why it exists: protocol encoding primitives should stay framework-agnostic.
- What it does: provides foundational `Codec`, `Encoder`, and `Decoder` abstractions.
- Use it when: implementing reusable encoding logic across programs.

### solana_kit_codecs_numbers

- Pub.dev: [solana_kit_codecs_numbers](https://pub.dev/packages/solana_kit_codecs_numbers)
- Why it exists: Solana wire formats are numeric-heavy and endian-sensitive.
- What it does: offers numeric codecs like `u8`, `u64`, `i128`, and float codecs.
- Use it when: encoding instruction data and account binary payloads.

### solana_kit_codecs_strings

- Pub.dev: [solana_kit_codecs_strings](https://pub.dev/packages/solana_kit_codecs_strings)
- Why it exists: common Solana encodings (base58/base64/utf8) should be consistent.
- What it does: provides codecs for textual and base-encoded representations.
- Use it when: handling wallet addresses, memo strings, and encoded blobs.

### solana_kit_codecs_data_structures

- Pub.dev: [solana_kit_codecs_data_structures](https://pub.dev/packages/solana_kit_codecs_data_structures)
- Why it exists: Solana program data is often nested and variant-rich.
- What it does: builds composite codecs for structs, unions, tuples, arrays, and maps.
- Use it when: modeling complex account/program data layouts.

### solana_kit_options

- Pub.dev: [solana_kit_options](https://pub.dev/packages/solana_kit_options)
- Why it exists: many Solana structures use optional values with Rust-like semantics.
- What it does: offers typed option variants and optional-value codec support.
- Use it when: serializing optional account fields or params.

## Instructions and Transactions

### solana_kit_instructions

- Pub.dev: [solana_kit_instructions](https://pub.dev/packages/solana_kit_instructions)
- Why it exists: instructions are the core unit of Solana program interaction.
- What it does: models instruction payloads and account metadata roles.
- Use it when: building program invocations at a typed boundary.

### solana_kit_transaction_messages

- Pub.dev: [solana_kit_transaction_messages](https://pub.dev/packages/solana_kit_transaction_messages)
- Why it exists: message assembly has protocol-specific lifetime and payer constraints.
- What it does: constructs and mutates transaction messages before signing.
- Use it when: composing transaction intent prior to wire encoding.

### solana_kit_transactions

- Pub.dev: [solana_kit_transactions](https://pub.dev/packages/solana_kit_transactions)
- Why it exists: finalized transaction wire objects need deterministic serialization.
- What it does: compiles messages into signed transactions and wire bytes.
- Use it when: sending transactions to Solana RPC endpoints.

### solana_kit_offchain_messages

- Pub.dev: [solana_kit_offchain_messages](https://pub.dev/packages/solana_kit_offchain_messages)
- Why it exists: off-chain signatures need typed envelopes and replay-safe structure.
- What it does: builds/signs off-chain message formats.
- Use it when: signing auth payloads or attestations outside chain execution.

### solana_kit_instruction_plans

- Pub.dev: [solana_kit_instruction_plans](https://pub.dev/packages/solana_kit_instruction_plans)
- Why it exists: many dApp operations need multi-step transaction orchestration.
- What it does: models sequential/parallel instruction planning utilities.
- Use it when: composing larger workflows across multiple instructions.

### solana_kit_transaction_confirmation

- Pub.dev: [solana_kit_transaction_confirmation](https://pub.dev/packages/solana_kit_transaction_confirmation)
- Why it exists: confirmation strategy varies by risk tolerance and latency goals.
- What it does: provides confirmation strategies and racing behavior.
- Use it when: handling production-grade send-and-confirm flows.

## RPC and Protocol Types

### solana_kit_rpc

- Pub.dev: [solana_kit_rpc](https://pub.dev/packages/solana_kit_rpc)
- Why it exists: apps need a high-level, typed RPC entrypoint.
- What it does: exposes client factories and common RPC sending workflows.
- Use it when: issuing JSON-RPC requests from app/business logic.

### solana_kit_rpc_api

- Pub.dev: [solana_kit_rpc_api](https://pub.dev/packages/solana_kit_rpc_api)
- Why it exists: method signatures should be typed, not stringly.
- What it does: defines strongly typed RPC method builders and params.
- Use it when: authoring method-specific request code.

### solana_kit_rpc_types

- Pub.dev: [solana_kit_rpc_types](https://pub.dev/packages/solana_kit_rpc_types)
- Why it exists: typed response models reduce runtime parsing bugs.
- What it does: defines shared RPC response/parameter type models.
- Use it when: handling typed account, balance, block, and signature data.

### solana_kit_rpc_spec

- Pub.dev: [solana_kit_rpc_spec](https://pub.dev/packages/solana_kit_rpc_spec)
- Why it exists: transport-agnostic RPC contracts improve composability.
- What it does: defines core JSON-RPC interfaces and abstractions.
- Use it when: building custom transports or API adapters.

### solana_kit_rpc_spec_types

- Pub.dev: [solana_kit_rpc_spec_types](https://pub.dev/packages/solana_kit_rpc_spec_types)
- Why it exists: low-level protocol frames need reusable typed definitions.
- What it does: defines low-level request/response protocol value types.
- Use it when: interfacing with transport internals or middleware.

### solana_kit_rpc_parsed_types

- Pub.dev: [solana_kit_rpc_parsed_types](https://pub.dev/packages/solana_kit_rpc_parsed_types)
- Why it exists: parsed account data should be typed across known programs.
- What it does: models parsed token/stake/system/etc. account responses.
- Use it when: consuming parsed account RPC responses.

### solana_kit_rpc_transformers

- Pub.dev: [solana_kit_rpc_transformers](https://pub.dev/packages/solana_kit_rpc_transformers)
- Why it exists: response normalization and error transformation should be reusable.
- What it does: transforms RPC payloads, errors, and bigint values.
- Use it when: centralizing transport and payload policy.

### solana_kit_rpc_transport_http

- Pub.dev: [solana_kit_rpc_transport_http](https://pub.dev/packages/solana_kit_rpc_transport_http)
- Why it exists: HTTP transport concerns should be isolated from business logic.
- What it does: provides HTTP transport implementations for RPC.
- Use it when: connecting to hosted or self-managed RPC endpoints.

## Subscriptions and Streaming

### solana_kit_rpc_subscriptions

- Pub.dev: [solana_kit_rpc_subscriptions](https://pub.dev/packages/solana_kit_rpc_subscriptions)
- Why it exists: realtime apps need managed subscription clients.
- What it does: exposes high-level subscription orchestration APIs.
- Use it when: building live updates for account/slot/log changes.

### solana_kit_rpc_subscriptions_api

- Pub.dev: [solana_kit_rpc_subscriptions_api](https://pub.dev/packages/solana_kit_rpc_subscriptions_api)
- Why it exists: websocket subscription methods should be type-safe.
- What it does: defines typed subscription method builders.
- Use it when: wiring notification pipelines with compile-time method checks.

### solana_kit_rpc_subscriptions_channel_websocket

- Pub.dev: [solana_kit_rpc_subscriptions_channel_websocket](https://pub.dev/packages/solana_kit_rpc_subscriptions_channel_websocket)
- Why it exists: websocket channel behavior should be encapsulated.
- What it does: provides a websocket channel implementation for subscriptions.
- Use it when: customizing socket lifecycle and reconnection behavior.

### solana_kit_subscribable

- Pub.dev: [solana_kit_subscribable](https://pub.dev/packages/solana_kit_subscribable)
- Why it exists: subscription sources should map cleanly to streams/iterables.
- What it does: wraps subscribable patterns and stream adapters.
- Use it when: bridging subscription APIs to Dart stream consumers.

## Accounts and Programs

### solana_kit_accounts

- Pub.dev: [solana_kit_accounts](https://pub.dev/packages/solana_kit_accounts)
- Why it exists: account fetch/decode logic should be standardized.
- What it does: fetches and decodes account payloads into typed wrappers.
- Use it when: reading on-chain state safely and repeatedly.

### solana_kit_programs

- Pub.dev: [solana_kit_programs](https://pub.dev/packages/solana_kit_programs)
- Why it exists: program error handling is nuanced and repetitive.
- What it does: provides helpers for program-focused error interpretation.
- Use it when: handling custom program-specific failures.

### solana_kit_program_client_core

- Pub.dev: [solana_kit_program_client_core](https://pub.dev/packages/solana_kit_program_client_core)
- Why it exists: program clients need common reusable foundations.
- What it does: exposes shared utilities for building typed program clients.
- Use it when: generating or hand-writing client SDK wrappers.

### solana_kit_sysvars

- Pub.dev: [solana_kit_sysvars](https://pub.dev/packages/solana_kit_sysvars)
- Why it exists: sysvar account schemas are common and should stay typed.
- What it does: provides typed sysvar representations and helpers.
- Use it when: reading clock/rent/epoch or related sysvar values.

## Utilities and Ecosystem Integrations

### solana_kit_functional

- Pub.dev: [solana_kit_functional](https://pub.dev/packages/solana_kit_functional)
- Why it exists: transaction and instruction composition benefits from pipelines.
- What it does: exposes functional helper APIs like `.pipe()`.
- Use it when: writing readable chained builder flows.

### solana_kit_fast_stable_stringify

- Pub.dev: [solana_kit_fast_stable_stringify](https://pub.dev/packages/solana_kit_fast_stable_stringify)
- Why it exists: deterministic serialization is required for hashing/deduping.
- What it does: provides stable key-order JSON stringification.
- Use it when: generating deterministic signatures, caches, or request keys.

### solana_kit_mobile_wallet_adapter_protocol

- Pub.dev: [solana_kit_mobile_wallet_adapter_protocol](https://pub.dev/packages/solana_kit_mobile_wallet_adapter_protocol)
- Why it exists: MWA protocol logic should remain portable and testable.
- What it does: implements protocol-level handshake and messaging behavior.
- Use it when: implementing wallet/dApp protocol compatibility.

### solana_kit_mobile_wallet_adapter

- Pub.dev: [solana_kit_mobile_wallet_adapter](https://pub.dev/packages/solana_kit_mobile_wallet_adapter)
- Why it exists: Flutter apps need platform integration for wallet handoff.
- What it does: offers Flutter-facing MWA integration (Android-centric).
- Use it when: integrating wallet connectivity into mobile Flutter clients.

### solana_kit_helius

- Pub.dev: [solana_kit_helius](https://pub.dev/packages/solana_kit_helius)
- Why it exists: provider-specific RPC patterns should not leak into core packages.
- What it does: adds Helius-specific API ergonomics and models.
- Use it when: your infra depends on Helius endpoints and features.

## Internal and Workspace Support Packages

### solana_kit_lints

- Pub.dev: [solana_kit_lints](https://pub.dev/packages/solana_kit_lints)
- Why it exists: workspace-wide coding standards must be centralized.
- What it does: provides lint profiles used by packages in this monorepo.
- Use it when: maintaining or extending package authoring conventions.

### solana_kit_test_matchers

- Pub.dev: [solana_kit_test_matchers](https://pub.dev/packages/solana_kit_test_matchers)
- Why it exists: repeated assertion patterns should be standardized.
- What it does: defines reusable test matchers used in workspace tests.
- Use it when: writing package-level tests for consistent diagnostics.

### codama-renderers-dart/test-generated

- Pub.dev: [codama_renderers_dart_test_generated](https://pub.dev/packages/codama_renderers_dart_test_generated)
- Why it exists: generated renderer fixtures validate codegen correctness.
- What it does: stores generated test package assets for codama renderer tests.
- Use it when: working on codama renderer generation behavior.
