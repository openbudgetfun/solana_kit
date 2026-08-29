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
    required this.verified,
    required this.share,
  });

  final Address address;
  final bool verified;
  final int share;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Creator &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          verified == other.verified &&
          share == other.share;

  @override
  int get hashCode => Object.hash(address, verified, share);

  @override
  String toString() =>
      'Creator(address: $address, verified: $verified, share: $share)';
}

Encoder<Creator> getCreatorEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('address', getAddressEncoder()),
    ('verified', getBooleanEncoder()),
    ('share', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Creator value) => <String, Object?>{
      'address': value.address,
      'verified': value.verified,
      'share': value.share,
    },
  );
}

Decoder<Creator> getCreatorDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('address', getAddressDecoder()),
    ('verified', getBooleanDecoder()),
    ('share', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Creator(
      address: map['address']! as Address,
      verified: map['verified']! as bool,
      share: map['share']! as int,
    ),
  );
}

Codec<Creator, Creator> getCreatorCodec() {
  return combineCodec(getCreatorEncoder(), getCreatorDecoder());
}
