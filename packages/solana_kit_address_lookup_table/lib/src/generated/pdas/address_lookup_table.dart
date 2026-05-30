// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:solana_kit_address_lookup_table/src/generated/constants.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

/// Finds the Address Lookup Table PDA for [authority] and [recentSlot].
///
/// The PDA seeds match the upstream program client: the authority public key
/// bytes followed by the recent slot encoded as little-endian `u64`.
Future<ProgramDerivedAddress> findAddressLookupTablePda({
  required Address authority,
  required BigInt recentSlot,
  Address programAddress = addressLookupTableProgramAddress,
}) {
  return getProgramDerivedAddress(
    programAddress: programAddress,
    seeds: [
      getPublicKeyFromAddress(authority),
      _encodeRecentSlotSeed(recentSlot),
    ],
  );
}

Uint8List _encodeRecentSlotSeed(BigInt recentSlot) {
  return getU64Encoder().encode(recentSlot);
}
