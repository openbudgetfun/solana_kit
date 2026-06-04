// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

@immutable
class SubscriptionAuthoritySeeds {
  const SubscriptionAuthoritySeeds({
    required this.user,
    required this.tokenMint,
  });

  final Address user;
  final Address tokenMint;
}

/// Finds the program derived address for [SubscriptionAuthority].
Future<(Address, int)> findSubscriptionAuthorityPda({
  required SubscriptionAuthoritySeeds seeds,
  required Address programAddress,
}) async {
  final seedValues = <Object>[
    'SubscriptionAuthority',
    getAddressEncoder().encode(seeds.user),
    getAddressEncoder().encode(seeds.tokenMint),
  ];

  return getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: seedValues,
  );
}
