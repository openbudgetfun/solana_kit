---
"solana_kit_rpc_types": major
---

# Remove deprecated TokenAmount.uiAmount field

Removes the deprecated `uiAmount` field from `TokenAmount`. The floating-point `uiAmount` field loses precision for large token balances. Use `uiAmountString` instead, which preserves the full string representation from the RPC.

```dart
// Before
final amount = TokenAmount(
  amount: StringifiedBigInt('1000000'),
  decimals: 6,
  uiAmountString: StringifiedNumber('1'),
  uiAmount: 1.0,
);

// After
final amount = TokenAmount(
  amount: StringifiedBigInt('1000000'),
  decimals: 6,
  uiAmountString: StringifiedNumber('1'),
);
```
