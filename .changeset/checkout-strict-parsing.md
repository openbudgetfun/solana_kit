---
"solana_kit_helius": patch
---

# Reject malformed Helius checkout responses instead of silently defaulting them

The hosted-checkout response models (`CheckoutInitializeResponse`, `CheckoutPreviewResponse`, `CheckoutStatusResponse`) parsed with `?? ''` / `?? 0` / `?? false` fallbacks on every field, so a malformed renewal response could tell a user to pay zero cents to an empty wallet through a payment link that looked real. All three models now parse with the package's `JsonReader` require-accessors and throw `FormatException` naming the missing key, matching the strict parsing the developer-portal API clients already use. `pollCheckoutCompletion`'s documented synthetic pending/expired statuses are unchanged; only genuinely malformed HTTP responses now fail.

`fetchTipFloor75th` still returns null for transient endpoint failures but no longer swallows `ArgumentError` and `TypeError`: a bad endpoint argument now surfaces as a programming error instead of the conservative null tip.
