# solana_kit_address_lookup_table

Address Lookup Table program client for the
[Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart SDK.

Provides instruction builders, codecs, account decoders, and parsers for the
Address Lookup Table program, which manages lookup tables used in versioned
(v0) transactions.

## Installation

```yaml
dependencies:
  solana_kit_address_lookup_table: ^0.3.1
```

## Usage

```dart
import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';

// Create a new address lookup table
final createIx = getCreateLookupTableInstruction(
  address: tableAddress,
  authority: authorityAddress,
  payer: payerAddress,
  recentSlot: BigInt.from(slot),
  bump: bump,
);

// Extend a lookup table with new addresses
final extendIx = getExtendLookupTableInstruction(
  address: tableAddress,
  authority: authorityAddress,
  payer: payerAddress,
  addresses: [addr1, addr2],
);

// Deactivate a lookup table
final deactivateIx = getDeactivateLookupTableInstruction(
  address: tableAddress,
  authority: authorityAddress,
);

// Close a deactivated lookup table
final closeIx = getCloseLookupTableInstruction(
  address: tableAddress,
  authority: authorityAddress,
  recipient: recipientAddress,
);
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

The `AddressLookupTableAccountData` decoder can decode on-chain account data
for lookup tables, including the authority, deactivation slot, and stored
addresses.

## Upstream reference

Generated layer mirrors
[solana-program/address-lookup-table](https://github.com/solana-program/address-lookup-table)
at `js@v0.11.0`.
