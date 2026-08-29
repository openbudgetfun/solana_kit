/// Vault PDA derivation for the Squads V4 multisig program.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_squads/src/pda/seeds.dart';
import 'package:solana_kit_squads/src/program_address.dart';

/// Derives the vault PDA for a multisig and vault index.
///
/// A multisig can own multiple vaults; index `0` is the first and default
/// vault. The [index] is encoded as a single byte seed, so it must be
/// between 0 and 255 (inclusive).
///
/// Throws [ArgumentError] if [index] is outside the valid range.
///
/// ## Example
///
/// ```dart
/// final (vaultPda, bump) = await findVaultPda(
///   multisig: multisigPda,
///   index: 0,
/// );
/// ```
Future<ProgramDerivedAddress> findVaultPda({
  required Address multisig,
  required int index,
}) {
  if (index < 0 || index > 255) {
    throw ArgumentError.value(index, 'index', 'must be between 0 and 255');
  }
  return getProgramDerivedAddress(
    programAddress: squadsMultisigProgramAddressObject,
    seeds: [
      multisigSeedPrefix,
      getAddressEncoder().encode(multisig),
      vaultSeed,
      Uint8List(1)..[0] = index,
    ],
  );
}
