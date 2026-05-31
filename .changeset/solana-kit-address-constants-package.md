---
"solana_kit_address_constants": major
---

# New `solana_kit_address_constants` package

Initial release of `solana_kit_address_constants` — well-known address constants for native programs, sysvars, SPL programs, Metaplex programs, and token mints extracted from `solana_kit_addresses`.

```dart
import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';

final address = systemProgramAddress; // native program
final sysvar = clockSysvarAddress;   // sysvar
```
