---
title: Build a Token Transfer Flow
description: Step-by-step guide for assembling and sending a transfer transaction.
---

This guide shows a robust transfer flow from message creation to confirmation.

## Why This Flow Exists

A transfer is not a single API call. It is a sequence: fetch state, build message, sign, send, confirm.

## Step 1: Gather Inputs

- sender keypair/signer
- recipient address
- amount
- latest blockhash

Reason: transaction assembly requires all of these before signing.

## Step 2: Build the Message

```dart
final message = createTransactionMessage()
    .pipe(setTransactionMessageFeePayer(sender.address))
    .pipe(setTransactionMessageLifetimeUsingBlockhash(blockhash));
```

Reason: fee payer and lifetime are mandatory correctness constraints.

## Step 3: Append Transfer Instructions

- build instruction(s) for SOL or SPL transfer.
- append with `appendTransactionMessageInstruction(...)`.

Reason: message mutations remain explicit and auditable.

## Step 4: Compile and Sign

- compile to transaction bytes.
- sign with required signers (`solana_kit_signers`).

Reason: compile/sign boundaries make partial and multi-signer flows manageable.

## Step 5: Send and Confirm Strategically

- send via RPC.
- confirm using `solana_kit_transaction_confirmation` strategy.

Reason: confirmation behavior should match UX and risk tolerance.

## Step 6: Handle Failures by Domain

- RPC domain: transport/server issues.
- instruction/program domain: semantic failures.
- transaction domain: signature/lifetime issues.

Reason: domain-specific recovery paths improve reliability.
