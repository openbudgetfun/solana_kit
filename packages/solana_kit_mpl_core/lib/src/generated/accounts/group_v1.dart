// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import '../types/key.dart';

@immutable
class GroupV1 {
  const GroupV1({
    required this.key,
    required this.updateAuthority,
    required this.name,
    required this.uri,
    required this.collections,
    required this.groups,
    required this.parentGroups,
    required this.assets,
  });

  final Key key;
  final Address updateAuthority;
  final String name;
  final String uri;
  final List<Address> collections;
  final List<Address> groups;
  final List<Address> parentGroups;
  final List<Address> assets;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupV1 &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          updateAuthority == other.updateAuthority &&
          name == other.name &&
          uri == other.uri &&
          collections == other.collections &&
          groups == other.groups &&
          parentGroups == other.parentGroups &&
          assets == other.assets;

  @override
  int get hashCode => Object.hash(
    key,
    updateAuthority,
    name,
    uri,
    collections,
    groups,
    parentGroups,
    assets,
  );

  @override
  String toString() =>
      'GroupV1(key: $key, updateAuthority: $updateAuthority, name: $name, uri: $uri, collections: $collections, groups: $groups, parentGroups: $parentGroups, assets: $assets)';
}

Encoder<GroupV1> getGroupV1Encoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('updateAuthority', getAddressEncoder()),
    ('name', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('uri', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    (
      'collections',
      getArrayEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
    (
      'groups',
      getArrayEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
    (
      'parentGroups',
      getArrayEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
    (
      'assets',
      getArrayEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (GroupV1 value) => <String, Object?>{
      'key': value.key,
      'updateAuthority': value.updateAuthority,
      'name': value.name,
      'uri': value.uri,
      'collections': value.collections,
      'groups': value.groups,
      'parentGroups': value.parentGroups,
      'assets': value.assets,
    },
  );
}

Decoder<GroupV1> getGroupV1Decoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('updateAuthority', getAddressDecoder()),
    ('name', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('uri', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('collections', getArrayDecoder(getAddressDecoder())),
    ('groups', getArrayDecoder(getAddressDecoder())),
    ('parentGroups', getArrayDecoder(getAddressDecoder())),
    ('assets', getArrayDecoder(getAddressDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'groupV1 account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (GroupV1, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      GroupV1(
        key: map['key']! as Key,
        updateAuthority: map['updateAuthority']! as Address,
        name: map['name']! as String,
        uri: map['uri']! as String,
        collections: map['collections']! as List<Address>,
        groups: map['groups']! as List<Address>,
        parentGroups: map['parentGroups']! as List<Address>,
        assets: map['assets']! as List<Address>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<GroupV1>(
      fixedSize: structDecoder.fixedSize,
      read: (bytes, offset) {
        final bytesLength = bytes.length - offset;
        if (bytesLength < structDecoder.fixedSize) {
          throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
        }
        return readTopLevel(bytes, offset);
      },
    ),
    VariableSizeDecoder<Map<String, Object?>>() => VariableSizeDecoder<GroupV1>(
      read: readTopLevel,
      maxSize: structDecoder.maxSize,
    ),
  };
}

Codec<GroupV1, GroupV1> getGroupV1Codec() {
  return combineCodec(getGroupV1Encoder(), getGroupV1Decoder());
}

Account<GroupV1> decodeGroupV1(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getGroupV1Decoder());
}
