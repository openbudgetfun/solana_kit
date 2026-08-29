/// Metadata account PDA derivation for mpl-token-metadata.
///
/// The metadata PDA stores the metadata of a mint and is the canonical
/// account for the Token Metadata program.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_mpl_token_metadata/src/program_address.dart';

/// Derives the metadata PDA for a given mint.
///
/// The metadata PDA is derived from the seeds
/// `['metadata', programId, mint]` using the mpl-token-metadata program ID.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
///
/// void main() async {
///   final mint = Address('So11111111111111111111111111111111111111112');
///   final (metadata, bump) = await findMetadataPda(mint: mint);
///   print(metadata); // The derived metadata PDA
/// }
/// ```
Future<ProgramDerivedAddress> findMetadataPda({required Address mint}) {
  return getProgramDerivedAddress(
    programAddress: mplTokenMetadataProgramAddressObject,
    seeds: [
      Uint8List.fromList('metadata'.codeUnits),
      getAddressEncoder().encode(mplTokenMetadataProgramAddressObject),
      getAddressEncoder().encode(mint),
    ],
  );
}
