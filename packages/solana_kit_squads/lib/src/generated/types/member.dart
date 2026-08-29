// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './permissions.dart';

@immutable
class Member {
  const Member({
    required this.key,
    required this.permissions,
  });

  final Address key;
  final Permissions permissions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Member &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          permissions == other.permissions;

  @override
  int get hashCode => Object.hash(key, permissions);

  @override
  String toString() => 'Member(key: $key, permissions: $permissions)';
}

Encoder<Member> getMemberEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getAddressEncoder()),
    ('permissions', getPermissionsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Member value) => <String, Object?>{
      'key': value.key,
      'permissions': value.permissions,
    },
  );
}

Decoder<Member> getMemberDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getAddressDecoder()),
    ('permissions', getPermissionsDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Member(
      key: map['key']! as Address,
      permissions: map['permissions']! as Permissions,
    ),
  );
}

Codec<Member, Member> getMemberCodec() {
  return combineCodec(getMemberEncoder(), getMemberDecoder());
}
