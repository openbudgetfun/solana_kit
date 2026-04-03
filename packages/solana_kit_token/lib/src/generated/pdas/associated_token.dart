// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';


@immutable
class AssociatedTokenSeeds {
  const AssociatedTokenSeeds({
    required this.owner,
    required this.tokenProgram,
    required this.mint,
  });

  final Address owner;
  final Address tokenProgram;
  final Address mint;
}

/// Finds the program derived address for [AssociatedToken].
Future<(Address, int)> findAssociatedTokenPda({
  required AssociatedTokenSeeds seeds,
  required Address programAddress,
}) async {
  final seedValues = <Object>[
    getAddressEncoder().encode(seeds.owner),
    getAddressEncoder().encode(seeds.tokenProgram),
    getAddressEncoder().encode(seeds.mint),
  ];

  return getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: seedValues,
  );
}
