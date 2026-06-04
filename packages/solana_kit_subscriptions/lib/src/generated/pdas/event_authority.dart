// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// Finds the program derived address for [EventAuthority].
Future<(Address, int)> findEventAuthorityPda({
  required Address programAddress,
}) async {
  final seedValues = <Object>[
    'event_authority',
  ];

  return getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: seedValues,
  );
}
