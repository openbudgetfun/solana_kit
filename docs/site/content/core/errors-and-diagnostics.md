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
Use them to route error handling without hardcoding code ranges throughout your
application.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

void handleSolanaFailure(SolanaError error) {
  if (error.isInDomain(SolanaErrorDomain.rpc)) {
    print('RPC failure: $error');
    return;
  }

  if (error.isInDomain(SolanaErrorDomain.transaction)) {
    print('Transaction failure: $error');
    return;
  }

  print('Unhandled Solana error: $error');
}
```

This keeps your error-routing logic readable while still preserving the exact
numeric code and context payload when you need lower-level diagnostics.

<!-- {/errorDomainHelpersSection} -->

## Practical guidance

### Catch `SolanaError` at service boundaries

Boundary layers such as repositories, API services, or command handlers are good places to classify and map errors.

### Preserve context when rethrowing

If you convert one failure into another, keep the original structured information whenever possible.

### Keep secrets out of diagnostics

Structured context is useful, but it should not become a dumping ground for secrets.

Avoid attaching or logging:

- private keys or seed material
- auth tokens
- full wallet session payloads
- raw encrypted messages unless you are in a controlled debugging environment

Prefer small, typed, non-sensitive context fields that still let you classify and route failures.

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
