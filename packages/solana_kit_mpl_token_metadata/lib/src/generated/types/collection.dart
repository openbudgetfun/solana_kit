// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class Collection {
  const Collection({
    required this.verified,
    required this.key,
  });

  final bool verified;
  final Address key;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Collection &&
          runtimeType == other.runtimeType &&
          verified == other.verified &&
          key == other.key;

  @override
  int get hashCode => Object.hash(verified, key);

  @override
  String toString() => 'Collection(verified: $verified, key: $key)';
}

Encoder<Collection> getCollectionEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('verified', getBooleanEncoder()),
    ('key', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Collection value) => <String, Object?>{
      'verified': value.verified,
      'key': value.key,
    },
  );
}

Decoder<Collection> getCollectionDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('verified', getBooleanDecoder()),
    ('key', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Collection(
      verified: map['verified']! as bool,
      key: map['key']! as Address,
    ),
  );
}

Codec<Collection, Collection> getCollectionCodec() {
  return combineCodec(getCollectionEncoder(), getCollectionDecoder());
}
