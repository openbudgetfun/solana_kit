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

<!-- {=securityNoteCalloutSection|replace:"SECURITY_GUIDANCE_TOKEN":"Attach small, structured, non-sensitive context to `SolanaError` values so service boundaries can classify failures without parsing strings."|replace:"SECURITY_AVOIDANCE_TOKEN":"Avoid logging private keys, auth tokens, wallet session payloads, or full structured error contexts in production logs."} -->

> **Security note**
>
> Attach small, structured, non-sensitive context to `SolanaError` values so service boundaries can classify failures without parsing strings.
>
> Avoid logging private keys, auth tokens, wallet session payloads, or full structured error contexts in production logs.

<!-- {/securityNoteCalloutSection} -->

## Preferred construction helper

Use `createSolanaError(...)` and `wrapSolanaError(...)` when you want consistent null stripping, context naming, and nested-cause preservation.

```dart
import 'package:solana_kit_errors/solana_kit_errors.dart';

void main() {
  final cause = StateError('decoder failed');
  final error = wrapSolanaError(
    SolanaErrorCode.accountsFailedToDecodeAccount,
    cause,
    context: {
      SolanaErrorContextKeys.address:
          '11111111111111111111111111111111',
      SolanaErrorContextKeys.operation: 'decodeAccount',
    },
  );

  print(error.context[SolanaErrorContextKeys.causeType]);
}
```

Prefer shared keys such as `address`, `operation`, `methodName`, `path`, `statusCode`, and `url` so diagnostics stay predictable across packages.

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
