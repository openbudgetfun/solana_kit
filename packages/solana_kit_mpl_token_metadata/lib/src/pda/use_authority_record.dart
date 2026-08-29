/// Use authority record PDA derivation for mpl-token-metadata.
///
/// The use authority record PDA stores approvals of additional authorities
/// allowed to use (consume) a token.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_mpl_token_metadata/src/program_address.dart';

/// Derives the use authority record PDA for a given mint and use authority.
///
/// The use authority record PDA is derived from the seeds
/// `['metadata', programId, mint, 'user', useAuthority]` using the
/// mpl-token-metadata program ID.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
///
/// void main() async {
///   final mint = Address('So11111111111111111111111111111111111111112');
///   final authority = Address('9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin');
///   final (record, bump) = await findUseAuthorityRecordPda(
///     mint: mint,
///     useAuthority: authority,
///   );
///   print(record); // The derived use authority record PDA
/// }
/// ```
Future<ProgramDerivedAddress> findUseAuthorityRecordPda({
  required Address mint,
  required Address useAuthority,
}) {
  return getProgramDerivedAddress(
    programAddress: mplTokenMetadataProgramAddressObject,
    seeds: [
      Uint8List.fromList('metadata'.codeUnits),
      getAddressEncoder().encode(mplTokenMetadataProgramAddressObject),
      getAddressEncoder().encode(mint),
      Uint8List.fromList('user'.codeUnits),
      getAddressEncoder().encode(useAuthority),
    ],
  );
}
