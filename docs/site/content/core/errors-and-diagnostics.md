---
title: Errors and Diagnostics
description: Use structured Solana Kit errors and domain helpers.
---

Solana Kit favors typed/structured errors over string parsing.

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

## Practical Guidance

- Catch `SolanaError` at service boundaries and map codes to domain responses.
- Preserve `context` when rethrowing to keep diagnostics actionable.
- Avoid broad `catch (e)` handlers in core transaction or RPC flows unless you reclassify to typed errors.
