/// Holder delegate record PDA derivation for mpl-token-metadata.
///
/// The holder delegate record PDA stores token-holder-level delegations,
/// such as print delegates.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_mpl_token_metadata/src/program_address.dart';

/// Returns the PDA seed string for a holder delegate role.
///
/// The `HolderDelegateRole` enum currently only contains the print
/// delegate variant, which maps to the string `'print_delegate'`, matching
/// the Rust program's `Display` implementation used for PDA derivation.
const String _holderDelegatePrintSeed = 'print_delegate';

/// Derives the holder delegate record PDA for a given mint, owner, and
/// delegate.
///
/// The holder delegate record PDA is derived from the seeds
/// `['metadata', programId, mint, 'print_delegate', owner, delegate]`,
/// matching the Rust program's `find_holder_delegate_record_account` with
/// the print delegate role.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
///
/// void main() async {
///   final mint = Address('So11111111111111111111111111111111111111112');
///   final owner = Address('Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS');
///   final delegate = Address('4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7D4xWLs4gDB4T');
///   final (record, bump) = await findHolderDelegateRecordPda(
///     mint: mint,
///     owner: owner,
///     delegate: delegate,
///   );
///   print(record); // The derived holder delegate record PDA
/// }
/// ```
Future<ProgramDerivedAddress> findHolderDelegateRecordPda({
  required Address mint,
  required Address owner,
  required Address delegate,
}) {
  return getProgramDerivedAddress(
    programAddress: mplTokenMetadataProgramAddressObject,
    seeds: [
      Uint8List.fromList('metadata'.codeUnits),
      getAddressEncoder().encode(mplTokenMetadataProgramAddressObject),
      getAddressEncoder().encode(mint),
      Uint8List.fromList(_holderDelegatePrintSeed.codeUnits),
      getAddressEncoder().encode(owner),
      getAddressEncoder().encode(delegate),
    ],
  );
}
