---
default: patch
---

Add fluent extension methods to `TransactionMessage` for Dart-idiomatic
composition without requiring function + `.pipe` style.

- `withFeePayer`
- `withBlockhashLifetime`
- `withDurableNonceLifetime`
- `appendInstruction` / `appendInstructions`
- `prependInstruction` / `prependInstructions`
