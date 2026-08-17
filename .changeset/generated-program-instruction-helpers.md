---
"codama-renderers-dart": major
"solana_kit_compute_budget": minor
---

# Generate program-level instruction identification and parsing helpers

Generate typed program instruction identifiers and parsers from instruction discriminators, and expose the generated helpers in the Compute Budget program client.

```dart
// Before: hand-rolled discriminator matching
if (data[0] == 0x02) {
  // setComputeUnitLimit
}

// After: generated identification and parsing helpers
final instruction = identifyComputeBudgetInstruction(data);
final parsed = parseComputeBudgetInstruction(data);
```
