// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class ReservationV1 {
  const ReservationV1({
    required this.address,
    required this.spotsRemaining,
    required this.totalSpots,
  });

  final Address address;
  final int spotsRemaining;
  final int totalSpots;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReservationV1 &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          spotsRemaining == other.spotsRemaining &&
          totalSpots == other.totalSpots;

  @override
  int get hashCode => Object.hash(address, spotsRemaining, totalSpots);

  @override
  String toString() =>
      'ReservationV1(address: $address, spotsRemaining: $spotsRemaining, totalSpots: $totalSpots)';
}

Encoder<ReservationV1> getReservationV1Encoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('address', getAddressEncoder()),
    ('spotsRemaining', getU8Encoder()),
    ('totalSpots', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ReservationV1 value) => <String, Object?>{
      'address': value.address,
      'spotsRemaining': value.spotsRemaining,
      'totalSpots': value.totalSpots,
    },
  );
}

Decoder<ReservationV1> getReservationV1Decoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('address', getAddressDecoder()),
    ('spotsRemaining', getU8Decoder()),
    ('totalSpots', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => ReservationV1(
      address: map['address']! as Address,
      spotsRemaining: map['spotsRemaining']! as int,
      totalSpots: map['totalSpots']! as int,
    ),
  );
}

Codec<ReservationV1, ReservationV1> getReservationV1Codec() {
  return combineCodec(getReservationV1Encoder(), getReservationV1Decoder());
}
