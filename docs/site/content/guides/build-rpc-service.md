---
title: Build an RPC Service
description: Create a reusable application service that owns Solana RPC access, policy, and error mapping.
---

This guide shows a practical pattern for keeping raw RPC details out of your UI, controllers, or domain services.

## Why this pattern works

A dedicated RPC service gives you one place to own:

- endpoint configuration
- commitment defaults
- transport policy
- retries/timeouts
- error mapping
- request-specific helper methods

## Step 1: wrap the RPC client

```dart
import 'package:solana_kit/solana_kit.dart';

class SolanaRpcService {
  SolanaRpcService(String url) : _rpc = createSolanaRpc(url: url);

  final Rpc _rpc;

  Future<Slot> getSlot() {
    return _rpc.getSlot().send();
  }

  Future<Lamports> getBalance(Address address) async {
    final result = await _rpc.getBalance(address).send();
    return result.value;
  }

  Future<MaybeEncodedAccount> getAccount(Address address) {
    return fetchEncodedAccount(_rpc, address);
  }
}
```

This already pays off because callers no longer need to know which RPC method to call or how the result is shaped.

## Step 2: centralize error classification

```dart
Future<T> mapSolanaErrors<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } on SolanaError catch (error) {
    if (error.isInDomain(SolanaErrorDomain.rpc)) {
      // Map to a transport/service-level error in your app.
      rethrow;
    }
    rethrow;
  }
}
```

Then use that wrapper inside service methods if your application has its own domain error model.

## Step 3: expose task-oriented methods

Your application usually cares about workflows, not raw JSON-RPC calls.

```dart
class WalletOverviewService {
  WalletOverviewService(this._rpcService);

  final SolanaRpcService _rpcService;

  Future<(Lamports, Slot)> loadOverview(Address address) async {
    final balance = await _rpcService.getBalance(address);
    final slot = await _rpcService.getSlot();
    return (balance, slot);
  }
}
```

This keeps your app code focused on product behavior rather than transport mechanics.

## Step 4: move transport configuration to the edge

If you need a custom HTTP client or transport policy, configure it at service creation time.

```dart
import 'package:http/http.dart' as http;
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';

final transport = createHttpTransportForSolanaRpc(
  url: 'https://api.devnet.solana.com',
  client: http.Client(),
  headers: {'x-service-name': 'wallet-api'},
);
```

That makes it much easier to switch providers, add observability, or test against a custom transport.

## Step 5: test at the service boundary

A service wrapper is a much more useful unit to test than many ad hoc RPC calls spread throughout the app.

Typical test cases:

- returns a typed balance result
- maps missing accounts to the expected app behavior
- classifies RPC-domain failures correctly
- applies the right commitment or endpoint policy

## Related docs

- [RPC and Subscriptions](../core/rpc-and-subscriptions)
- [Errors and Diagnostics](../core/errors-and-diagnostics)
- [Fetch an Account](../getting-started/fetch-an-account)
