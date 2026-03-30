---
title: Mobile Wallet Adapter
description: Step-by-step guide for integrating Solana Mobile Wallet Adapter flows.
---

## Why MWA Exists in This Workspace

`solana_kit_mobile_wallet_adapter_protocol` and `solana_kit_mobile_wallet_adapter` separate protocol behavior from Flutter platform wiring.

- protocol package: portable cryptography/session handshake logic.
- flutter package: Android integration with wallet sessions.

## Platform Support

### Android

Android is the only fully supported platform for Solana Mobile Wallet Adapter flows in this workspace.

### iOS

iOS is intentionally shipped as a safe stub/no-op layer for mixed-platform Flutter apps.

This is not because this workspace does not want to support iOS. The current limitation comes from the Solana Mobile Wallet Adapter ecosystem itself: the wallet handoff model and supporting wallet infrastructure are Android-based today, so there is no equivalent iOS MWA target for this package to integrate with.

That means:

- apps can still compile and ship shared Flutter code to iOS.
- `solana_kit_mobile_wallet_adapter` should be treated as unavailable on iOS.
- iOS code paths should provide an alternate wallet strategy or a clear unsupported-platform UX.

Use `isMwaSupported()` / `assertMwaSupported()` to gate platform behavior explicitly.

## Step-by-Step Integration

### Step 1: Choose Your Layer

- Use protocol-only package for pure Dart flows.
- Use Flutter package for Android app integrations.

Reason: keeps platform code isolated from protocol contracts.

### Step 2: Configure Session Lifecycle

- establish association URI flow.
- start and manage wallet sessions.
- enforce session timeout/cleanup behavior.

Reason: session lifecycle errors are the most common production issue.

### Step 3: Bind Signing and Transaction Calls

- connect session methods to your `solana_kit` transaction builders.
- keep wallet interactions behind one abstraction.

Reason: easier to swap/mock wallet behavior in tests.

### Step 4: Add User-Facing Failure Modes

- wallet unavailable
- session rejected
- signing denied

Reason: explicit UX handling improves trust and recovery.

### Step 5: Validate on Device

- test on real Android hardware.
- verify deep link/session resumption flows.

Reason: emulator-only testing misses many wallet handoff issues.
