// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class Reservation {
  const Reservation({
    required this.address,
    required this.spotsRemaining,
    required this.totalSpots,
  });

  final Address address;
  final BigInt spotsRemaining;
  final BigInt totalSpots;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reservation &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          spotsRemaining == other.spotsRemaining &&
          totalSpots == other.totalSpots;

  @override
  int get hashCode => Object.hash(address, spotsRemaining, totalSpots);

  @override
  String toString() =>
      'Reservation(address: $address, spotsRemaining: $spotsRemaining, totalSpots: $totalSpots)';
}

Encoder<Reservation> getReservationEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('address', getAddressEncoder()),
    ('spotsRemaining', getU64Encoder()),
    ('totalSpots', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Reservation value) => <String, Object?>{
      'address': value.address,
      'spotsRemaining': value.spotsRemaining,
      'totalSpots': value.totalSpots,
    },
  );
}

Decoder<Reservation> getReservationDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('address', getAddressDecoder()),
    ('spotsRemaining', getU64Decoder()),
    ('totalSpots', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Reservation(
      address: map['address']! as Address,
      spotsRemaining: map['spotsRemaining']! as BigInt,
      totalSpots: map['totalSpots']! as BigInt,
    ),
  );
}

Codec<Reservation, Reservation> getReservationCodec() {
  return combineCodec(getReservationEncoder(), getReservationDecoder());
}
