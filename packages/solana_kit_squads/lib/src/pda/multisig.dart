/// Multisig PDA derivation for the Squads V4 multisig program.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_squads/src/pda/seeds.dart';
import 'package:solana_kit_squads/src/program_address.dart';

/// Derives the multisig PDA for a given create key.
///
/// The [createKey] is a signer key chosen at multisig creation time that
/// uniquely identifies the multisig account together with the program.
///
/// ## Example
///
/// ```dart
/// final (multisigPda, bump) = await findMultisigPda(createKey: createKey);
/// ```
Future<ProgramDerivedAddress> findMultisigPda({required Address createKey}) {
  return getProgramDerivedAddress(
    programAddress: squadsMultisigProgramAddressObject,
    seeds: [
      multisigSeedPrefix,
      multisigSeed,
      getAddressEncoder().encode(createKey),
    ],
  );
}
