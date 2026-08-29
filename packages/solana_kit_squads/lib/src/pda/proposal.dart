/// Proposal PDA derivation for the Squads V4 multisig program.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import 'package:solana_kit_squads/src/pda/seeds.dart';
import 'package:solana_kit_squads/src/program_address.dart';

/// Derives the proposal PDA for a multisig and transaction index.
///
/// The proposal PDA extends the transaction PDA seeds with the
/// `'proposal'` suffix, so a proposal always maps 1:1 to the transaction
/// it refers to.
///
/// ## Example
///
/// ```dart
/// final (proposalPda, bump) = await findProposalPda(
///   multisig: multisigPda,
///   transactionIndex: BigInt.one,
/// );
/// ```
Future<ProgramDerivedAddress> findProposalPda({
  required Address multisig,
  required BigInt transactionIndex,
}) {
  return getProgramDerivedAddress(
    programAddress: squadsMultisigProgramAddressObject,
    seeds: [
      multisigSeedPrefix,
      getAddressEncoder().encode(multisig),
      transactionSeed,
      getU64Encoder().encode(transactionIndex),
      proposalSeed,
    ],
  );
}
