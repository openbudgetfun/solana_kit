---
title: Build a Program Client
description: Step-by-step guide for creating a typed Solana program client in Dart.
---

Typed program clients reduce repeated boilerplate and make on-chain interactions safer.

## Why Program Clients Matter

- instruction payloads become typed inputs.
- account parsing becomes centralized and reusable.
- teams avoid duplicating protocol assumptions.

## Step 1: Define Domain Types

- model instruction inputs.
- model decoded account state.

Reason: typed models provide compile-time guarantees.

## Step 2: Build Codecs for Program Data

- use `solana_kit_codecs_core` and `solana_kit_codecs_data_structures`.
- encode instruction data and decode account state.

Reason: on-chain bytes must round-trip predictably.

## Step 3: Build Instruction Factories

- use `solana_kit_instructions` types.
- return typed instruction builders.

Reason: keep account-role correctness in one place.

## Step 4: Add Account Fetch Helpers

- leverage `solana_kit_accounts` for typed fetch/decode wrappers.
- add convenience helpers for key account types.

Reason: data access consistency prevents decoder drift.

## Step 5: Add Error Mapping

- map `ProgramError` and `SolanaError` to domain-level app errors.

Reason: protocol errors should remain actionable at product boundaries.

## Step 6: Package and Reuse

- publish as an internal package or module.
- expose a narrow public API.

Reason: program upgrades then require changes in one location.
