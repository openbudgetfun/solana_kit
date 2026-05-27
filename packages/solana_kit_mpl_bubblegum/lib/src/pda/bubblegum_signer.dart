/// Bubblegum signer PDA derivation for mpl-bubblegum.
///
/// The Bubblegum signer PDA is used as an additional signer for certain
/// instructions that require delegated authority.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import '../program_address.dart';

/// Derives the Bubblegum signer PDA.
///
/// The Bubblegum signer is a Program Derived Address (PDA) derived from
/// a constant seed and used as an additional signer for instructions like
/// `verifyLeaf` and `delegate`.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';
///
/// void main() async {
///   final (signer, bump) = await findBubblegumSignerPda();
///   print(signer); // The derived signer PDA
/// }
/// ```
Future<ProgramDerivedAddress> findBubblegumSignerPda() {
  return getProgramDerivedAddress(
    programAddress: mplBubblegumProgramAddressObject,
    seeds: [Uint8List.fromList('bubblegum_signer'.codeUnits)],
  );
}
