/// Master edition account PDA derivation for mpl-token-metadata.
///
/// The master edition PDA stores the edition data of a non-fungible mint,
/// such as the max supply and printed edition count.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_mpl_token_metadata/src/program_address.dart';

/// Derives the master edition PDA for a given mint.
///
/// The master edition PDA is derived from the seeds
/// `['metadata', programId, mint, 'edition']` using the
/// mpl-token-metadata program ID. The same derivation is used for both
/// `MasterEditionV2` and the deprecated `MasterEditionV1` accounts.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
///
/// void main() async {
///   final mint = Address('So11111111111111111111111111111111111111112');
///   final (masterEdition, bump) = await findMasterEditionPda(mint: mint);
///   print(masterEdition); // The derived master edition PDA
/// }
/// ```
Future<ProgramDerivedAddress> findMasterEditionPda({required Address mint}) {
  return getProgramDerivedAddress(
    programAddress: mplTokenMetadataProgramAddressObject,
    seeds: [
      Uint8List.fromList('metadata'.codeUnits),
      getAddressEncoder().encode(mplTokenMetadataProgramAddressObject),
      getAddressEncoder().encode(mint),
      Uint8List.fromList('edition'.codeUnits),
    ],
  );
}
