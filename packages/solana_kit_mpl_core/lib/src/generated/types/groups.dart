// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class Groups {
  const Groups({
    required this.groups,
  });

  final List<Address> groups;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Groups &&
          runtimeType == other.runtimeType &&
          groups == other.groups;

  @override
  int get hashCode => groups.hashCode;

  @override
  String toString() => 'Groups(groups: $groups)';
}

Encoder<Groups> getGroupsEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'groups',
      getArrayEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (Groups value) => <String, Object?>{
      'groups': value.groups,
    },
  );
}

Decoder<Groups> getGroupsDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('groups', getArrayDecoder(getAddressDecoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Groups(
      groups: map['groups']! as List<Address>,
    ),
  );
}

Codec<Groups, Groups> getGroupsCodec() {
  return combineCodec(getGroupsEncoder(), getGroupsDecoder());
}
