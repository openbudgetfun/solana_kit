/// Program config PDA derivation for the Squads V4 multisig program.
///
/// The program config is a singleton account that stores program-wide
/// settings such as the program authority and multisig creation fee.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_squads/src/pda/seeds.dart';
import 'package:solana_kit_squads/src/program_address.dart';

/// Derives the program config PDA for the Squads V4 multisig program.
///
/// The program config is a program-owned singleton PDA derived from the
/// `'multisig'` and `'program_config'` seeds only, so it always resolves
/// to the same address regardless of input.
///
/// ## Example
///
/// ```dart
/// final (programConfig, bump) = await findProgramConfigPda();
/// ```
Future<ProgramDerivedAddress> findProgramConfigPda() {
  return getProgramDerivedAddress(
    programAddress: squadsMultisigProgramAddressObject,
    seeds: [multisigSeedPrefix, programConfigSeed],
  );
}
