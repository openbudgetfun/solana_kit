// Auto-generated. Do not edit.
// ignore_for_file: type=lint



import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';


@immutable
class SubscriptionDelegationSeeds {
  const SubscriptionDelegationSeeds({
    required this.planPda,
    required this.subscriber,
  });

  final Address planPda;
  final Address subscriber;
}

/// Finds the program derived address for [SubscriptionDelegation].
Future<(Address, int)> findSubscriptionDelegationPda({
  required SubscriptionDelegationSeeds seeds,
  required Address programAddress,
}) async {
  final seedValues = <Object>[
    'subscription',
    getAddressEncoder().encode(seeds.planPda),
    getAddressEncoder().encode(seeds.subscriber),
  ];

  return getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: seedValues,
  );
}
