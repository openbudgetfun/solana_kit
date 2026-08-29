// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class Creator {
  const Creator({
    required this.address,
    required this.percentage,
  });

  final Address address;
  final int percentage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Creator &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          percentage == other.percentage;

  @override
  int get hashCode => Object.hash(address, percentage);

  @override
  String toString() => 'Creator(address: $address, percentage: $percentage)';
}

Encoder<Creator> getCreatorEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('address', getAddressEncoder()),
    ('percentage', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Creator value) => <String, Object?>{
      'address': value.address,
      'percentage': value.percentage,
    },
  );
}

Decoder<Creator> getCreatorDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('address', getAddressDecoder()),
    ('percentage', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Creator(
      address: map['address']! as Address,
      percentage: map['percentage']! as int,
    ),
  );
}

Codec<Creator, Creator> getCreatorCodec() {
  return combineCodec(getCreatorEncoder(), getCreatorDecoder());
}
