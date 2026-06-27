// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class FixedDelegationSeeds {
  const FixedDelegationSeeds({
    required this.subscriptionAuthority,
    required this.delegator,
    required this.delegatee,
    required this.nonce,
  });

  final Address subscriptionAuthority;
  final Address delegator;
  final Address delegatee;
  final BigInt nonce;
}

/// Finds the program derived address for [FixedDelegation].
Future<(Address, int)> findFixedDelegationPda({
  required FixedDelegationSeeds seeds,
  required Address programAddress,
}) async {
  final seedValues = <Object>[
    'delegation',
    getAddressEncoder().encode(seeds.subscriptionAuthority),
    getAddressEncoder().encode(seeds.delegator),
    getAddressEncoder().encode(seeds.delegatee),
    getU64Encoder().encode(seeds.nonce),
  ];

  return getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: seedValues,
  );
}
