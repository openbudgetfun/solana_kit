---
title: Build a Realtime Observer
description: Step-by-step guide for account/log subscriptions and stream fanout.
---

Realtime dApps depend on reliable subscription pipelines.

## Why a Dedicated Observer Layer

- websocket lifecycle handling is non-trivial.
- reconnection/fanout behavior should be centralized.
- UI components should consume clean streams, not sockets.

## Step 1: Initialize Subscription Client

- create client with `solana_kit_rpc_subscriptions`.
- configure channel transport from websocket package.

Reason: keep transport details out of feature modules.

## Step 2: Register Typed Subscriptions

- account notifications
- slot notifications
- logs notifications

Reason: typed methods prevent payload mismatch bugs.

## Step 3: Convert to Stream Abstractions

- use `solana_kit_subscribable` adapters.
- expose stream interfaces to application consumers.

Reason: stream contracts decouple UI from transport protocol.

## Step 4: Add Backpressure Strategy

- debounce noisy update types.
- batch updates where downstream permits.

Reason: high-frequency Solana events can overwhelm app state layers.

## Step 5: Reconnect and Replay

- reconnect with jittered backoff.
- re-register subscriptions after reconnect.

Reason: websocket sessions can drop under network/provider churn.
