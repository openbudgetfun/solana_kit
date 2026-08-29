/// Edition marker PDA derivations for mpl-token-metadata.
///
/// Edition markers track which editions of a master edition have been
/// minted. The `EDITION_MARKER_BIT_SIZE` is 248, meaning each marker
/// accounts for 248 editions.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_mpl_token_metadata/src/program_address.dart';

/// The number of editions tracked by a single edition marker account.
///
/// Each `EditionMarker` stores a 31-byte (248-bit) bitmap, so every marker
/// accounts for 248 editions.
const int editionMarkerBitSize = 248;

/// Derives the edition marker PDA for a given mint and edition number.
///
/// The edition marker PDA is derived from the seeds
/// `['metadata', programId, mint, 'edition', editionMarkerNumber]` where
/// `editionMarkerNumber` is the string representation of
/// `floor(edition / 248)`, matching the Rust program's
/// `find_edition_account`.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
///
/// void main() async {
///   final mint = Address('So11111111111111111111111111111111111111112');
///   final (editionMarker, bump) = await findEditionMarkerPda(
///     mint: mint,
///     edition: 42,
///   );
///   print(editionMarker); // The derived edition marker PDA
/// }
/// ```
Future<ProgramDerivedAddress> findEditionMarkerPda({
  required Address mint,
  required int edition,
}) {
  final editionMarkerNumber = (edition ~/ editionMarkerBitSize).toString();

  return getProgramDerivedAddress(
    programAddress: mplTokenMetadataProgramAddressObject,
    seeds: [
      Uint8List.fromList('metadata'.codeUnits),
      getAddressEncoder().encode(mplTokenMetadataProgramAddressObject),
      getAddressEncoder().encode(mint),
      Uint8List.fromList('edition'.codeUnits),
      Uint8List.fromList(editionMarkerNumber.codeUnits),
    ],
  );
}

/// Derives the edition marker V2 PDA for a given mint.
///
/// The `EditionMarkerV2` account tracks all editions of a master edition
/// in a single account. It is derived from the seeds
/// `['metadata', programId, mint, 'edition', 'marker']`.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
///
/// void main() async {
///   final mint = Address('So11111111111111111111111111111111111111112');
///   final (editionMarkerV2, bump) = await findEditionMarkerV2Pda(mint: mint);
///   print(editionMarkerV2); // The derived edition marker V2 PDA
/// }
/// ```
Future<ProgramDerivedAddress> findEditionMarkerV2Pda({required Address mint}) {
  return getProgramDerivedAddress(
    programAddress: mplTokenMetadataProgramAddressObject,
    seeds: [
      Uint8List.fromList('metadata'.codeUnits),
      getAddressEncoder().encode(mplTokenMetadataProgramAddressObject),
      getAddressEncoder().encode(mint),
      Uint8List.fromList('edition'.codeUnits),
      Uint8List.fromList('marker'.codeUnits),
    ],
  );
}
