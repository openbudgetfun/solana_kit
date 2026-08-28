// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import '../types/key.dart';
import '../types/reservation.dart';

@immutable
class ReservationListV2 {
  const ReservationListV2({
    required this.key,
    required this.masterEdition,
    required this.supplySnapshot,
    required this.reservations,
    required this.totalReservationSpots,
    required this.currentReservationSpots,
  });

  final Key key;
  final Address masterEdition;
  final BigInt? supplySnapshot;
  final List<Reservation> reservations;
  final BigInt totalReservationSpots;
  final BigInt currentReservationSpots;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReservationListV2 &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          masterEdition == other.masterEdition &&
          supplySnapshot == other.supplySnapshot &&
          reservations == other.reservations &&
          totalReservationSpots == other.totalReservationSpots &&
          currentReservationSpots == other.currentReservationSpots;

  @override
  int get hashCode => Object.hash(
    key,
    masterEdition,
    supplySnapshot,
    reservations,
    totalReservationSpots,
    currentReservationSpots,
  );

  @override
  String toString() =>
      'ReservationListV2(key: $key, masterEdition: $masterEdition, supplySnapshot: $supplySnapshot, reservations: $reservations, totalReservationSpots: $totalReservationSpots, currentReservationSpots: $currentReservationSpots)';
}

Encoder<ReservationListV2> getReservationListV2Encoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('masterEdition', getAddressEncoder()),
    ('supplySnapshot', getNullableEncoder<BigInt>(getU64Encoder())),
    (
      'reservations',
      getArrayEncoder<Reservation>(
        transformEncoder(getReservationEncoder(), (Reservation value) => value),
      ),
    ),
    ('totalReservationSpots', getU64Encoder()),
    ('currentReservationSpots', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ReservationListV2 value) => <String, Object?>{
      'key': value.key,
      'masterEdition': value.masterEdition,
      'supplySnapshot': value.supplySnapshot,
      'reservations': value.reservations,
      'totalReservationSpots': value.totalReservationSpots,
      'currentReservationSpots': value.currentReservationSpots,
    },
  );
}

Decoder<ReservationListV2> getReservationListV2Decoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('masterEdition', getAddressDecoder()),
    ('supplySnapshot', getNullableDecoder<BigInt>(getU64Decoder())),
    ('reservations', getArrayDecoder(getReservationDecoder())),
    ('totalReservationSpots', getU64Decoder()),
    ('currentReservationSpots', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'reservationListV2 account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ReservationListV2, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      ReservationListV2(
        key: map['key']! as Key,
        masterEdition: map['masterEdition']! as Address,
        supplySnapshot: map['supplySnapshot'] as BigInt?,
        reservations: map['reservations']! as List<Reservation>,
        totalReservationSpots: map['totalReservationSpots']! as BigInt,
        currentReservationSpots: map['currentReservationSpots']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ReservationListV2>(
        fixedSize: structDecoder.fixedSize,
        read: (bytes, offset) {
          final bytesLength = bytes.length - offset;
          if (bytesLength < structDecoder.fixedSize) {
            throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
          }
          return readTopLevel(bytes, offset);
        },
      ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<ReservationListV2>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ReservationListV2, ReservationListV2> getReservationListV2Codec() {
  return combineCodec(
    getReservationListV2Encoder(),
    getReservationListV2Decoder(),
  );
}

Account<ReservationListV2> decodeReservationListV2(
  EncodedAccount encodedAccount,
) {
  return decodeAccount(encodedAccount, getReservationListV2Decoder());
}
