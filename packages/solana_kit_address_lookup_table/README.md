# solana_kit_address_lookup_table

[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_address_lookup_table)

Address Lookup Table program client for the [Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart SDK.

Provides instruction builders, codecs, account decoders, and parsers for the Address Lookup Table program, which manages lookup tables used in versioned (v0) transactions.

## Installation

<!-- {=packageInstallSection:"solana_kit_address_lookup_table"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_address_lookup_table": ^0.4.2
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

## Usage

```dart
import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

void main() {
  const tableAddress = Address('11111111111111111111111111111111');
  const authority = Address('11111111111111111111111111111112');
  const payer = Address('11111111111111111111111111111113');
  const recipient = Address('11111111111111111111111111111114');
  const addr1 = Address('11111111111111111111111111111115');
  const addr2 = Address('11111111111111111111111111111116');

  // Create a new address lookup table.
  final createIx = getCreateLookupTableInstruction(
    programAddress: addressLookupTableProgramAddress,
    address: tableAddress,
    authority: authority,
    payer: payer,
    systemProgram: systemProgramAddress,
    recentSlot: BigInt.from(1000),
    bump: 255,
  );

  // Extend a lookup table with new addresses.
  final extendIx = getExtendLookupTableInstruction(
    programAddress: addressLookupTableProgramAddress,
    address: tableAddress,
    authority: authority,
    payer: payer,
    systemProgram: systemProgramAddress,
    addresses: [addr1, addr2],
  );

  // Deactivate a lookup table.
  final deactivateIx = getDeactivateLookupTableInstruction(
    programAddress: addressLookupTableProgramAddress,
    address: tableAddress,
    authority: authority,
  );

  // Close a deactivated lookup table.
  final closeIx = getCloseLookupTableInstruction(
    programAddress: addressLookupTableProgramAddress,
    address: tableAddress,
    authority: authority,
    recipient: recipient,
  );

  print(createIx.programAddress);
  print(extendIx.programAddress);
  print(deactivateIx.programAddress);
  print(closeIx.programAddress);
}
```

## Instructions

| Instruction             | Discriminator | Description                                              |
| ----------------------- | ------------- | -------------------------------------------------------- |
| `CreateLookupTable`     | 0             | Create a new address lookup table.                       |
| `FreezeLookupTable`     | 1             | Freeze a lookup table, preventing further modifications. |
| `ExtendLookupTable`     | 2             | Extend a lookup table with additional addresses.         |
| `DeactivateLookupTable` | 3             | Deactivate a lookup table before closing.                |
| `CloseLookupTable`      | 4             | Close a deactivated lookup table and reclaim lamports.   |

## Account

The `AddressLookupTableAccountData` decoder can decode on-chain account data for lookup tables, including the authority, deactivation slot, and stored addresses.

## Upstream reference

Generated layer mirrors [solana-program/address-lookup-table](https://github.com/solana-program/address-lookup-table) at `js@v0.14.0`.
