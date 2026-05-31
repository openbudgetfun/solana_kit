---
"solana_kit_address_lookup_table": major
---

# Add Address Lookup Table program package

Add `solana_kit_address_lookup_table` package with the full generated+helpers Address Lookup Table program client. Includes all five instructions (`CreateLookupTable`, `FreezeLookupTable`, `ExtendLookupTable`, `DeactivateLookupTable`, `CloseLookupTable`), the `AddressLookupTable` account decoder/fetch helpers, PDA derivation, create-with-PDA convenience builder, lookup table size constants, byte-delta metadata, codec round-trip tests, instruction identification, and parsed instruction types.

```dart
import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';

final instruction = getCreateLookupTableInstruction(
  authority: authorityAddress,
  payer: payerAddress,
);
```
