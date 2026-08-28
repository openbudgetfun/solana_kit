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
import '../types/reservation_v1.dart';

@immutable
class ReservationListV1 {
  const ReservationListV1({
    required this.key,
    required this.masterEdition,
    required this.supplySnapshot,
    required this.reservations,
  });

  final Key key;
  final Address masterEdition;
  final BigInt? supplySnapshot;
  final List<ReservationV1> reservations;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReservationListV1 &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          masterEdition == other.masterEdition &&
          supplySnapshot == other.supplySnapshot &&
          reservations == other.reservations;

  @override
  int get hashCode =>
      Object.hash(key, masterEdition, supplySnapshot, reservations);

  @override
  String toString() =>
      'ReservationListV1(key: $key, masterEdition: $masterEdition, supplySnapshot: $supplySnapshot, reservations: $reservations)';
}

Encoder<ReservationListV1> getReservationListV1Encoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('masterEdition', getAddressEncoder()),
    ('supplySnapshot', getNullableEncoder<BigInt>(getU64Encoder())),
    (
      'reservations',
      getArrayEncoder<ReservationV1>(
        transformEncoder(
          getReservationV1Encoder(),
          (ReservationV1 value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (ReservationListV1 value) => <String, Object?>{
      'key': value.key,
      'masterEdition': value.masterEdition,
      'supplySnapshot': value.supplySnapshot,
      'reservations': value.reservations,
    },
  );
}

Decoder<ReservationListV1> getReservationListV1Decoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('masterEdition', getAddressDecoder()),
    ('supplySnapshot', getNullableDecoder<BigInt>(getU64Decoder())),
    ('reservations', getArrayDecoder(getReservationV1Decoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'reservationListV1 account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ReservationListV1, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      ReservationListV1(
        key: map['key']! as Key,
        masterEdition: map['masterEdition']! as Address,
        supplySnapshot: map['supplySnapshot'] as BigInt?,
        reservations: map['reservations']! as List<ReservationV1>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ReservationListV1>(
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
      VariableSizeDecoder<ReservationListV1>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ReservationListV1, ReservationListV1> getReservationListV1Codec() {
  return combineCodec(
    getReservationListV1Encoder(),
    getReservationListV1Decoder(),
  );
}

Account<ReservationListV1> decodeReservationListV1(
  EncodedAccount encodedAccount,
) {
  return decodeAccount(encodedAccount, getReservationListV1Decoder());
}
