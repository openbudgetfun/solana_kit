/// Program-as-burner PDA derivation for mpl-token-metadata.
///
/// The program-as-burner PDA is used by the program to act as a signer
/// (burner) for instructions that need to burn tokens, such as
/// `utilize` and `burnNft`. The Rust program calls this the
/// "program as burner" account.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_mpl_token_metadata/src/program_address.dart';

/// Derives the program-as-burner PDA.
///
/// The program-as-burner PDA is derived from the seeds
/// `['metadata', programId, 'burn']` using the mpl-token-metadata program
/// ID, matching the Rust program's `find_program_as_burner_account`.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
///
/// void main() async {
///   final (burner, bump) = await findProgramAsBurnerPda();
///   print(burner); // The derived program-as-burner PDA
/// }
/// ```
Future<ProgramDerivedAddress> findProgramAsBurnerPda() {
  return getProgramDerivedAddress(
    programAddress: mplTokenMetadataProgramAddressObject,
    seeds: [
      Uint8List.fromList('metadata'.codeUnits),
      getAddressEncoder().encode(mplTokenMetadataProgramAddressObject),
      Uint8List.fromList('burn'.codeUnits),
    ],
  );
}
