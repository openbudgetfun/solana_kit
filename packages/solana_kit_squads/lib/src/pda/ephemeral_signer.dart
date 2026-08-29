/// Ephemeral signer PDA derivation for the Squads V4 multisig program.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import 'package:solana_kit_squads/src/pda/seeds.dart';
import 'package:solana_kit_squads/src/program_address.dart';

/// Derives the ephemeral signer PDA for a vault transaction and signer
/// index.
///
/// Ephemeral signers are additional signers declared in a vault
/// transaction message that are derived from the transaction PDA instead
/// of being part of the multisig.
///
/// ## Example
///
/// ```dart
/// final (ephemeralSignerPda, bump) = await findEphemeralSignerPda(
///   transaction: transactionPda,
///   ephemeralSignerIndex: 0,
/// );
/// ```
Future<ProgramDerivedAddress> findEphemeralSignerPda({
  required Address transaction,
  required int ephemeralSignerIndex,
}) {
  return getProgramDerivedAddress(
    programAddress: squadsMultisigProgramAddressObject,
    seeds: [
      multisigSeedPrefix,
      getAddressEncoder().encode(transaction),
      ephemeralSignerSeed,
      getU8Encoder().encode(ephemeralSignerIndex),
    ],
  );
}
