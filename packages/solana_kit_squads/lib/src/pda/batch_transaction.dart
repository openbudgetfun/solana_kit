/// Vault batch transaction PDA derivation for the Squads V4 multisig
/// program.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import 'package:solana_kit_squads/src/pda/seeds.dart';
import 'package:solana_kit_squads/src/program_address.dart';

/// Derives the vault batch transaction PDA for a multisig, batch index, and
/// transaction index.
///
/// The [batchIndex] identifies the batch (a transaction with an index of
/// its own) and is encoded as a little-endian 64-bit integer, while
/// [transactionIndex] addresses a transaction inside the batch and is
/// encoded as a little-endian 32-bit integer.
///
/// ## Example
///
/// ```dart
/// final (batchTransactionPda, bump) = await findBatchTransactionPda(
///   multisig: multisigPda,
///   batchIndex: BigInt.from(3),
///   transactionIndex: 7,
/// );
/// ```
Future<ProgramDerivedAddress> findBatchTransactionPda({
  required Address multisig,
  required BigInt batchIndex,
  required int transactionIndex,
}) {
  return getProgramDerivedAddress(
    programAddress: squadsMultisigProgramAddressObject,
    seeds: [
      multisigSeedPrefix,
      getAddressEncoder().encode(multisig),
      transactionSeed,
      getU64Encoder().encode(batchIndex),
      batchTransactionSeed,
      getU32Encoder().encode(transactionIndex),
    ],
  );
}
