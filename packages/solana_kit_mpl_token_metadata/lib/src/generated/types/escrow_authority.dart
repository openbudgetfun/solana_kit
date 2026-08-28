// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

sealed class EscrowAuthority {
  const EscrowAuthority();
}

final class EscrowAuthorityTokenOwner extends EscrowAuthority {
  const EscrowAuthorityTokenOwner();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EscrowAuthorityTokenOwner;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'EscrowAuthority.TokenOwner()';
}

final class EscrowAuthorityCreator extends EscrowAuthority {
  const EscrowAuthorityCreator(this.value);

  final Address value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EscrowAuthorityCreator && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'EscrowAuthority.Creator($value)';
}

Encoder<EscrowAuthority> getEscrowAuthorityEncoder() {
  return transformEncoder<Map<String, Object?>, EscrowAuthority>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (
        1,
        transformEncoder<Address, Map<String, Object?>>(
          getAddressEncoder(),
          (Map<String, Object?> map) => map['value']! as Address,
        ),
      ),
    ], size: getU8Encoder()),
    (EscrowAuthority value) => switch (value) {
      EscrowAuthorityTokenOwner() => <String, Object?>{'__kind': 0},
      EscrowAuthorityCreator(value: final value) => <String, Object?>{
        '__kind': 1,
        'value': value,
      },
    },
  );
}

Decoder<EscrowAuthority> getEscrowAuthorityDecoder() {
  return transformDecoder<Map<String, Object?>, EscrowAuthority>(
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
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return const EscrowAuthorityTokenOwner();
        case 1:
          return EscrowAuthorityCreator(map['value']! as Address);
      }
      throw StateError(
        'Unsupported EscrowAuthority discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<EscrowAuthority, EscrowAuthority> getEscrowAuthorityCodec() {
  return combineCodec(getEscrowAuthorityEncoder(), getEscrowAuthorityDecoder());
}
