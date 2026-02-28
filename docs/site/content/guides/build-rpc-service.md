---
title: Build an RPC Service
description: Step-by-step guide for creating a production-ready Solana RPC service layer.
---

This guide builds a reusable service that isolates RPC concerns from UI/business logic.

## Why This Pattern Matters

- It keeps transport/retry policy in one place.
- It makes testing easier by mocking one service boundary.
- It prevents ad-hoc method calls spread across the app.

## Step 1: Create a Service Class

```dart
import 'package:solana_kit/solana_kit.dart';

class SolanaRpcService {
  SolanaRpcService(String url) : _rpc = createSolanaRpc(url: url);

  final Rpc _rpc;

  Future<BigInt> getBalance(Address address) async {
    final result = await _rpc.getBalance(address).send();
    return result.value;
  }

  Future<int> getSlot() => _rpc.getSlot().send();
}
```

Reason: this turns request construction into a single testable dependency.

## Step 2: Add Error Mapping

```dart
Future<T> withSolanaErrorHandling<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } on SolanaError catch (error) {
    // Map to your app-level error model here.
    rethrow;
  }
}
```

Reason: typed error handling avoids brittle string matching.

## Step 3: Centralize Configuration

- Keep endpoint URLs in one config object.
- Optionally inject a custom transport from `solana_kit_rpc_transport_http`.
- Define commitment defaults at service initialization.

Reason: consistency and easier environment switching.

## Step 4: Add Health and Latency Probes

- call `getSlot()` as a health probe.
- measure timing around critical methods.
- emit metrics with method labels.

Reason: Solana RPC reliability is workload-dependent and should be observable.

## Step 5: Integrate in App Layer

- provide `SolanaRpcService` via dependency injection.
- keep widgets/controllers free of raw RPC method construction.

Reason: cleaner architecture and easier migration/testing.
