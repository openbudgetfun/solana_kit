---
title: Solana Kit docs
description: Everything you need to build Solana apps and services in Dart and Flutter, from your first RPC call to production program clients.
---

A Dart-first Solana SDK workspace modeled after `@solana/kit`, with strongly typed APIs for addresses, instructions, transactions, RPC, subscriptions, account decoding, and Mobile Wallet Adapter integrations.

<!-- {=docsUpstreamCompatibilitySection} -->

## Upstream Compatibility

- Latest supported `@solana/kit` version: `8.6.0`
- This Dart port tracks upstream APIs and behavior through `v8.6.0`.

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

## How these docs are organized

| Section                                               | What you will find                                                                                                           |
| ----------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| [Get started](docs/getting-started/installation)      | Install the SDK, create a signer, read an account, and send a first transaction. Read these in order.                        |
| [Core concepts](docs/core/architecture)               | How addresses, codecs, accounts, signers, transactions, and RPC fit together, and why the APIs look the way they do.         |
| [Guides](docs/guides/build-rpc-service)               | End-to-end walkthroughs for production integrations: RPC services, token transfers, program clients, and realtime observers. |
| [Flutter & mobile](docs/guides/mobile-wallet-adapter) | Mobile Wallet Adapter, the wallet UI kit, and publishing to the Solana Mobile dApp Store.                                    |
| [Programs](docs/programs/subscriptions-overview)      | Task-focused guides for program clients such as Subscriptions and the Solana Attestation Service.                            |
| [Reference](docs/reference/package-catalog)           | Every package, what it is for, and which `@solana/kit` release it tracks.                                                    |

## Start here

New to the workspace? Follow this path from an empty project to a confirmed transaction:

1. [Installation](docs/getting-started/installation)
2. [Quick Start](docs/getting-started/quick-start)
3. [Generate a Signer](docs/getting-started/generate-a-signer)
4. [Fetch an Account](docs/getting-started/fetch-an-account)
5. [Create Instructions](docs/getting-started/create-instructions)
6. [Build a Transaction](docs/getting-started/build-a-transaction)
7. [First Transaction](docs/getting-started/first-transaction)

## Find it by task

### Read chain state

- [Fetch an Account](docs/getting-started/fetch-an-account)
- [Accounts](docs/core/accounts)
- [RPC and Subscriptions](docs/core/rpc-and-subscriptions)

### Build and submit transactions

- [Transactions](docs/core/transactions)
- [Signers](docs/core/signers)
- [Build a Token Transfer Flow](docs/guides/build-token-transfer-flow)

### Work with binary layouts and account schemas

- [Codecs](docs/core/codecs)
- [Build a Program Client](docs/guides/build-program-client)

### Build production integrations

- [Build an RPC Service](docs/guides/build-rpc-service)
- [Build a Realtime Observer](docs/guides/build-realtime-observer)
- [Errors and Diagnostics](docs/core/errors-and-diagnostics)
- [Helius package](https://pub.dev/packages/solana_kit_helius)

<Info>
Use the package catalog when you want to know which package to import. Use the core concept pages when you want to understand how the pieces fit together.
</Info>

## Contributing

Working on the SDK itself? Start with [Contributing](docs/contributing), then see the [Release Process](docs/contributing/release-process) and [Benchmarking](docs/contributing/benchmarking).
