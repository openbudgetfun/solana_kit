/// Vault transaction PDA derivation for the Squads V4 multisig program.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import 'package:solana_kit_squads/src/pda/seeds.dart';
import 'package:solana_kit_squads/src/program_address.dart';

/// Derives the vault transaction PDA for a multisig and transaction index.
///
/// Transaction indices increment per multisig and are encoded as a
/// little-endian 64-bit integer seed.
///
/// ## Example
///
/// ```dart
/// final (transactionPda, bump) = await findTransactionPda(
///   multisig: multisigPda,
///   index: BigInt.zero,
/// );
/// ```
Future<ProgramDerivedAddress> findTransactionPda({
  required Address multisig,
  required BigInt index,
}) {
  return getProgramDerivedAddress(
    programAddress: squadsMultisigProgramAddressObject,
    seeds: [
      multisigSeedPrefix,
      getAddressEncoder().encode(multisig),
      transactionSeed,
      getU64Encoder().encode(index),
    ],
  );
}
