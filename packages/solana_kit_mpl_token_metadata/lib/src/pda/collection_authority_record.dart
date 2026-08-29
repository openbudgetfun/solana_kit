/// Collection authority record PDA derivation for mpl-token-metadata.
///
/// The collection authority record PDA stores approvals of additional
/// collection authorities on a collection.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_mpl_token_metadata/src/program_address.dart';

/// Derives the collection authority record PDA for a given mint and
/// collection authority.
///
/// The collection authority record PDA is derived from the seeds
/// `['metadata', programId, mint, 'collection_authority', collectionAuthority]`
/// using the mpl-token-metadata program ID.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
///
/// void main() async {
///   final mint = Address('So11111111111111111111111111111111111111112');
///   final authority = Address('9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin');
///   final (record, bump) = await findCollectionAuthorityRecordPda(
///     mint: mint,
///     collectionAuthority: authority,
///   );
///   print(record); // The derived collection authority record PDA
/// }
/// ```
Future<ProgramDerivedAddress> findCollectionAuthorityRecordPda({
  required Address mint,
  required Address collectionAuthority,
}) {
  return getProgramDerivedAddress(
    programAddress: mplTokenMetadataProgramAddressObject,
    seeds: [
      Uint8List.fromList('metadata'.codeUnits),
      getAddressEncoder().encode(mplTokenMetadataProgramAddressObject),
      getAddressEncoder().encode(mint),
      Uint8List.fromList('collection_authority'.codeUnits),
      getAddressEncoder().encode(collectionAuthority),
    ],
  );
}
