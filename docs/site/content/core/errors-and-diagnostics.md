---
title: Errors and Diagnostics
description: Handle structured Solana errors, preserve context, and build recoverable failure flows.
---

Solana Kit favors structured errors over string parsing.

That means you can reason about failures by:

- error code
- error domain
- attached structured context

instead of brittle substring matching against user-facing messages.

## Domain helpers

<!-- {=errorDomainHelpersSection} -->

### Typed Error Domains

`solana_kit_errors` includes domain helpers layered over numeric error codes.
Use them to route error handling without hardcoding code ranges.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

try {
  // ...
} on SolanaError catch (e) {
  if (e.isInDomain(SolanaErrorDomain.rpc)) {
    // Handle transport/server concerns.
  }
}
```

<!-- {/errorDomainHelpersSection} -->

## Practical guidance

### Catch `SolanaError` at service boundaries

Boundary layers such as repositories, API services, or command handlers are good places to classify and map errors.

### Preserve context when rethrowing

If you convert one failure into another, keep the original structured information whenever possible.

### Avoid broad untyped catches in core flows

Catching `Object` too early can erase useful domain information.

## Why this matters

Typed diagnostics help you answer questions like:

- was this an RPC transport failure?
- was the account data malformed?
- was the transaction missing a signer?
- did a lifetime constraint expire?
- did a program-specific error occur during execution?

That is much easier than parsing free-form strings downstream.

## Read next

- [Transactions](transactions)
- [RPC and Subscriptions](rpc-and-subscriptions)
- [Package Catalog](../reference/package-catalog)
