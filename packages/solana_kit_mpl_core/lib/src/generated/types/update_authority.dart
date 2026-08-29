// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

sealed class UpdateAuthority {
  const UpdateAuthority();
}

final class UpdateAuthorityNone extends UpdateAuthority {
  const UpdateAuthorityNone();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UpdateAuthorityNone;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'UpdateAuthority.None()';
}

final class UpdateAuthorityAddress extends UpdateAuthority {
  const UpdateAuthorityAddress(this.value);

  final Address value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAuthorityAddress && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'UpdateAuthority.Address($value)';
}

final class UpdateAuthorityCollection extends UpdateAuthority {
  const UpdateAuthorityCollection(this.value);

  final Address value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAuthorityCollection && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'UpdateAuthority.Collection($value)';
}

Encoder<UpdateAuthority> getUpdateAuthorityEncoder() {
  return transformEncoder<Map<String, Object?>, UpdateAuthority>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (
        1,
        transformEncoder<Address, Map<String, Object?>>(
          getAddressEncoder(),
          (Map<String, Object?> map) => map['value']! as Address,
        ),
      ),
      (
        2,
        transformEncoder<Address, Map<String, Object?>>(
          getAddressEncoder(),
          (Map<String, Object?> map) => map['value']! as Address,
        ),
      ),
    ], size: getU8Encoder()),
    (UpdateAuthority value) => switch (value) {
      UpdateAuthorityNone() => <String, Object?>{'__kind': 0},
      UpdateAuthorityAddress(value: final value) => <String, Object?>{
        '__kind': 1,
        'value': value,
      },
      UpdateAuthorityCollection(value: final value) => <String, Object?>{
        '__kind': 2,
        'value': value,
      },
    },
  );
}

Decoder<UpdateAuthority> getUpdateAuthorityDecoder() {
  return transformDecoder<Map<String, Object?>, UpdateAuthority>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder(<(String, Decoder<Object?>)>[]),
          (Map<String, Object?> map, Uint8List bytes, int offset) =>
              <String, Object?>{},
        ),
      ),
      (
        1,
        transformDecoder<Address, Map<String, Object?>>(
          getAddressDecoder(),
          (Address value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        2,
        transformDecoder<Address, Map<String, Object?>>(
          getAddressDecoder(),
          (Address value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return const UpdateAuthorityNone();
        case 1:
          return UpdateAuthorityAddress(map['value']! as Address);
        case 2:
          return UpdateAuthorityCollection(map['value']! as Address);
      }
      throw StateError(
        'Unsupported UpdateAuthority discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<UpdateAuthority, UpdateAuthority> getUpdateAuthorityCodec() {
  return combineCodec(getUpdateAuthorityEncoder(), getUpdateAuthorityDecoder());
}
