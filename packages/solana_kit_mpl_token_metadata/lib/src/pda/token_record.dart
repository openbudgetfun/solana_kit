/// Token record PDA derivation for mpl-token-metadata.
///
/// The token record PDA stores the state of a token of a programmable
/// asset, such as whether it is frozen or locked.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_mpl_token_metadata/src/program_address.dart';

/// Derives the token record PDA for a given mint and token account.
///
/// The token record PDA is derived from the seeds
/// `['metadata', programId, mint, 'token_record', token]` using the
/// mpl-token-metadata program ID.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
///
/// void main() async {
///   final mint = Address('So11111111111111111111111111111111111111112');
///   final token = Address('4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7D4xWLs4gDB4T');
///   final (tokenRecord, bump) = await findTokenRecordPda(
///     mint: mint,
///     token: token,
///   );
///   print(tokenRecord); // The derived token record PDA
/// }
/// ```
Future<ProgramDerivedAddress> findTokenRecordPda({
  required Address mint,
  required Address token,
}) {
  return getProgramDerivedAddress(
    programAddress: mplTokenMetadataProgramAddressObject,
    seeds: [
      Uint8List.fromList('metadata'.codeUnits),
      getAddressEncoder().encode(mplTokenMetadataProgramAddressObject),
      getAddressEncoder().encode(mint),
      Uint8List.fromList('token_record'.codeUnits),
      getAddressEncoder().encode(token),
    ],
  );
}
