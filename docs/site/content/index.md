---
title: Solana Kit for Dart
description: Comprehensive, example-driven documentation for the Solana Kit Dart workspace.
---

A Dart-first Solana SDK workspace modeled after `@solana/kit`, with strongly typed APIs for addresses, instructions, transactions, RPC, subscriptions, account decoding, and Mobile Wallet Adapter integrations.

<!-- {=docsUpstreamCompatibilitySection} -->

## Upstream Compatibility

- Latest supported `@solana/kit` version: `6.5.0`
- This Dart port tracks upstream APIs and behavior through `v6.5.0`.

<!-- {/docsUpstreamCompatibilitySection} -->

<!-- {=preferredDartPathCalloutSection|replace:"PREFERRED_PATH_TOKEN":"Start with typed RPC clients, typed account helpers, and explicit transaction/signer models. The workspace teaches those Dart-first surfaces before lower-level compatibility seams."|replace:"ESCAPE_HATCH_GUIDANCE_TOKEN":"Use raw JSON-RPC requests, manual map peeling, or compatibility-only paths when you need to match upstream behavior exactly or reach a surface that has not been wrapped yet."} -->

> **Preferred Dart path**
>
> Start with typed RPC clients, typed account helpers, and explicit transaction/signer models. The workspace teaches those Dart-first surfaces before lower-level compatibility seams.
>
> Use raw JSON-RPC requests, manual map peeling, or compatibility-only paths when you need to match upstream behavior exactly or reach a surface that has not been wrapped yet.

<!-- {/preferredDartPathCalloutSection} -->

<!-- {=parityStatusCalloutSection|replace:"PARITY_STATUS_TOKEN":"Executable parity checks already cover selected `@solana/kit` behaviors for validation, derivation, transaction compilation, serialization, and targeted error semantics."|replace:"PARITY_NEXT_TOKEN":"Additional parity areas are tracked explicitly in the roadmap; absence from the harness should be read as out of scope today, not silently compatible."} -->

> **Parity status**
>
> Executable parity checks already cover selected `@solana/kit` behaviors for validation, derivation, transaction compilation, serialization, and targeted error semantics.
>
> Additional parity areas are tracked explicitly in the roadmap; absence from the harness should be read as out of scope today, not silently compatible.

<!-- {/parityStatusCalloutSection} -->

## What makes Solana Kit different?

- **Typed end to end** — addresses, RPC requests, subscriptions, transactions, and account models are all expressed with explicit Dart types.
- **Modular by default** — import the umbrella package for convenience, or pull in only the packages you need.
- **Composable primitives** — build transaction messages, codecs, program clients, and confirmation strategies from smaller reusable pieces.
- **Dart-native ergonomics** — modern Dart 3 features like records, patterns, extension types, and sealed classes are used throughout the workspace.
- **Upstream-aware** — the repo tracks `@solana/kit` compatibility and documents sync status explicitly.

## Start here

If you're new to the workspace, follow this path:

1. [Installation](getting-started/installation)
2. [Quick Start](getting-started/quick-start)
3. [Generate a Signer](getting-started/generate-a-signer)
4. [Fetch an Account](getting-started/fetch-an-account)
5. [First Transaction](getting-started/first-transaction)
6. [Transactions](core/transactions)
7. [RPC and Subscriptions](core/rpc-and-subscriptions)

## Common workflows

### Read chain state

- [Fetch an Account](getting-started/fetch-an-account)
- [Accounts](core/accounts)
- [RPC and Subscriptions](core/rpc-and-subscriptions)

### Build and submit transactions

- [Create Instructions](getting-started/create-instructions)
- [Build a Transaction](getting-started/build-a-transaction)
- [First Transaction](getting-started/first-transaction)
- [Transactions](core/transactions)
- [Signers](core/signers)

### Work with binary layouts and account schemas

- [Codecs](core/codecs)
- [Build a Program Client](guides/build-program-client)

### Build production integrations

- [Build an RPC Service](guides/build-rpc-service)
- [Build a Realtime Observer](guides/build-realtime-observer)
- [Mobile Wallet Adapter](guides/mobile-wallet-adapter)
- [Helius package](https://pub.dev/packages/solana_kit_helius)

<Info>
Use the package catalog when you want to know which package to import. Use the core concept pages when you want to understand how the pieces fit together.
</Info>

## Package map

- [Package Index](reference/package-index)
- [Complete Package Catalog](reference/package-catalog)
- [Upstream Compatibility](reference/upstream-compatibility)

## Contributor resources

- [Contributing](contributing)
- [Release Process](guides/release-process)
- [Benchmarking](guides/benchmarking)
