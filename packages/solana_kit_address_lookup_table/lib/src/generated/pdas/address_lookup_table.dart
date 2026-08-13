// Auto-generated. Do not edit.
// ignore_for_file: type=lint



import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';


@immutable
class AddressLookupTableSeeds {
  const AddressLookupTableSeeds({
    required this.authority,
    required this.recentSlot,
  });

  final Address authority;
  final BigInt recentSlot;
}

/// Finds the program derived address for [AddressLookupTable].
Future<(Address, int)> findAddressLookupTablePda({
  required AddressLookupTableSeeds seeds,
  required Address programAddress,
}) async {
  final seedValues = <Object>[
    getAddressEncoder().encode(seeds.authority),
    getU64Encoder().encode(seeds.recentSlot),
  ];

  return getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: seedValues,
  );
}
