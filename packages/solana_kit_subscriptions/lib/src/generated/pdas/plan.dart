// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class PlanSeeds {
  const PlanSeeds({
    required this.owner,
    required this.planId,
  });

  final Address owner;
  final BigInt planId;
}

/// Finds the program derived address for [Plan].
Future<(Address, int)> findPlanPda({
  required PlanSeeds seeds,
  required Address programAddress,
}) async {
  final seedValues = <Object>[
    'plan',
    getAddressEncoder().encode(seeds.owner),
    getU64Encoder().encode(seeds.planId),
  ];

  return getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: seedValues,
  );
}
