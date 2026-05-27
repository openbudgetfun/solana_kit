/// Tree authority PDA derivation for mpl-bubblegum.
///
/// The tree authority is a PDA derived from the Merkle tree address,
/// used as the authority/signer for tree operations.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_mpl_bubblegum/src/program_address.dart';

/// Derives the tree authority PDA for a given Merkle tree address.
///
/// The tree authority is a Program Derived Address (PDA) that serves as
/// the signing authority for operations on the Merkle tree. It is derived
/// from the Merkle tree address using the Bubblegum program ID.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
///
/// void main() async {
///   final merkleTree = Address('...merkle tree address...');
///   final (authority, bump) = await findTreeAuthorityPda(
///     merkleTree: merkleTree,
///   );
///   print(authority); // The derived PDA address
/// }
/// ```
Future<ProgramDerivedAddress> findTreeAuthorityPda({
  required Address merkleTree,
}) {
  return getProgramDerivedAddress(
    programAddress: mplBubblegumProgramAddressObject,
    seeds: [getAddressEncoder().encode(merkleTree)],
  );
}
