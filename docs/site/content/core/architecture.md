---
title: Architecture
description: Understand the workspace structure and package boundaries.
---

The workspace is split into focused packages with explicit responsibilities.

## Primary Layers

| Layer                   | Core packages                                                                           | Responsibility                              |
| ----------------------- | --------------------------------------------------------------------------------------- | ------------------------------------------- |
| Core primitives         | `solana_kit_addresses`, `solana_kit_keys`, `solana_kit_signers`                         | Address/key/signature modeling              |
| Binary codecs           | `solana_kit_codecs*`                                                                    | Serialization primitives and composites     |
| Transaction stack       | `solana_kit_instructions`, `solana_kit_transaction_messages`, `solana_kit_transactions` | Message and transaction construction        |
| RPC stack               | `solana_kit_rpc*`                                                                       | Typed request/response and transport        |
| Program/account helpers | `solana_kit_accounts`, `solana_kit_program_client_core`, `solana_kit_programs`          | Account fetching and program error handling |
| Integration             | `solana_kit_mobile_wallet_adapter*`, `solana_kit_helius`                                | Platform and provider-specific integrations |

For a package-by-package breakdown, use [Package Index](../reference/package-index).
