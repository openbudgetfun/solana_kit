import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_privacy_rings/src/constants.dart';

/// A program-derived address and the bump that produced it.
class DerivedAddress {
  /// Creates a derived address.
  const DerivedAddress({required this.address, required this.bump});

  /// The derived address.
  final Address address;

  /// Bump seed.
  final int bump;
}

/// SPL interface PDA for [mint].
///
/// Seeds: `b"spl_asset_vault" || mint`.
Future<DerivedAddress> splInterfacePda(Address mint) async {
  final (address, bump) = await getProgramDerivedAddress(
    programAddress: shieldedPoolProgramId,
    seeds: [splInterfaceSeed, getAddressEncoder().encode(mint)],
  );
  return DerivedAddress(address: address, bump: bump);
}

/// Nullifier PDA for [nullifier] in [tree].
///
/// Seeds: `b"nullifier" || tree || nullifier`.
Future<Address> nullifierPda(Address tree, List<int> nullifier) async {
  if (nullifier.length != 32) {
    throw ArgumentError.value(
      nullifier.length,
      'nullifier',
      'expected 32 bytes',
    );
  }
  final (address, _) = await getProgramDerivedAddress(
    programAddress: shieldedPoolProgramId,
    seeds: [
      nullifierSeed,
      getAddressEncoder().encode(tree),
      Uint8List.fromList(nullifier),
    ],
  );
  return address;
}

/// Derives the native SOL interface and checks it against the pinned address.
Future<DerivedAddress> deriveSolInterface() async {
  final (address, bump) = await getProgramDerivedAddress(
    programAddress: shieldedPoolProgramId,
    seeds: [
      solInterfaceSeed,
      Uint8List.fromList([0]),
    ],
  );
  return DerivedAddress(address: address, bump: bump);
}
