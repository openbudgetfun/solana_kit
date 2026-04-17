/// Address Lookup Table program client for the Solana Kit Dart SDK.
///
/// Provides instruction builders, codecs, account decoders, and parsers for the
/// Address Lookup Table program, which manages lookup tables used in versioned
/// (v0) transactions.
///
/// ## Quick start
///
/// ```dart
/// import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';
///
/// // Create a lookup table
/// final createIx = getCreateLookupTableInstruction(
///   address: tableAddress,
///   authority: authorityAddress,
///   payer: payerAddress,
///   recentSlot: BigInt.from(slot),
///   bump: bump,
/// );
///
/// // Extend a lookup table with new addresses
/// final extendIx = getExtendLookupTableInstruction(
///   address: tableAddress,
///   authority: authorityAddress,
///   payer: payerAddress,
///   addresses: [addr1, addr2],
/// );
/// ```
library;

export 'src/generated/address_lookup_table.dart';
