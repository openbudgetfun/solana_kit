/// Spending limit PDA derivation for the Squads V4 multisig program.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_squads/src/pda/seeds.dart';
import 'package:solana_kit_squads/src/program_address.dart';

/// Derives the spending limit PDA for a multisig and create key.
///
/// Each spending limit is identified by its own [createKey], chosen when
/// the limit is added to the multisig.
///
/// ## Example
///
/// ```dart
/// final (spendingLimitPda, bump) = await findSpendingLimitPda(
///   multisig: multisigPda,
///   createKey: limitCreateKey,
/// );
/// ```
Future<ProgramDerivedAddress> findSpendingLimitPda({
  required Address multisig,
  required Address createKey,
}) {
  return getProgramDerivedAddress(
    programAddress: squadsMultisigProgramAddressObject,
    seeds: [
      multisigSeedPrefix,
      getAddressEncoder().encode(multisig),
      spendingLimitSeed,
      getAddressEncoder().encode(createKey),
    ],
  );
}
