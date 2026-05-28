---
solana_kit_instructions: patch
---

# Add structural equality and toString to AccountMeta, AccountLookupMeta, and Instruction

Implement `operator ==` and `hashCode` on `AccountMeta`, `AccountLookupMeta`, and `Instruction` so these core value types behave correctly in `Set`s, as `Map` keys, and in test assertions using `expect(...)`.

`AccountMeta` compares by `address` and `role`. `AccountLookupMeta` extends that to also compare `addressIndex` and `lookupTableAddress`. `Instruction` compares `programAddress`, and performs deep equality on the `accounts` list and `data` byte buffer.

All three classes also gain a `toString()` override that prints their fields, making debug output and test failure messages far more readable than the default `Instance of ...` representation.
