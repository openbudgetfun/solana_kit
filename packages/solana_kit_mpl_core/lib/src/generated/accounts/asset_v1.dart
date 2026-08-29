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
import '../types/update_authority.dart';

@immutable
class AssetV1 {
  const AssetV1({
    required this.key,
    required this.owner,
    required this.updateAuthority,
    required this.name,
    required this.uri,
    required this.seq,
  });

  final Key key;
  final Address owner;
  final UpdateAuthority updateAuthority;
  final String name;
  final String uri;
  final BigInt? seq;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetV1 &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          owner == other.owner &&
          updateAuthority == other.updateAuthority &&
          name == other.name &&
          uri == other.uri &&
          seq == other.seq;

  @override
  int get hashCode => Object.hash(key, owner, updateAuthority, name, uri, seq);

  @override
  String toString() =>
      'AssetV1(key: $key, owner: $owner, updateAuthority: $updateAuthority, name: $name, uri: $uri, seq: $seq)';
}

Encoder<AssetV1> getAssetV1Encoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('owner', getAddressEncoder()),
    ('updateAuthority', getUpdateAuthorityEncoder()),
    ('name', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('uri', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    (
      'seq',
      getNullableEncoder<BigInt>(
        transformEncoder(getU64Encoder(), (BigInt value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (AssetV1 value) => <String, Object?>{
      'key': value.key,
      'owner': value.owner,
      'updateAuthority': value.updateAuthority,
      'name': value.name,
      'uri': value.uri,
      'seq': value.seq,
    },
  );
}

Decoder<AssetV1> getAssetV1Decoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('owner', getAddressDecoder()),
    ('updateAuthority', getUpdateAuthorityDecoder()),
    ('name', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('uri', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('seq', getNullableDecoder<BigInt>(getU64Decoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'assetV1 account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (AssetV1, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      AssetV1(
        key: map['key']! as Key,
        owner: map['owner']! as Address,
        updateAuthority: map['updateAuthority']! as UpdateAuthority,
        name: map['name']! as String,
        uri: map['uri']! as String,
        seq: map['seq'] as BigInt?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<AssetV1>(
      fixedSize: structDecoder.fixedSize,
      read: (bytes, offset) {
        final bytesLength = bytes.length - offset;
        if (bytesLength < structDecoder.fixedSize) {
          throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
        }
        return readTopLevel(bytes, offset);
      },
    ),
    VariableSizeDecoder<Map<String, Object?>>() => VariableSizeDecoder<AssetV1>(
      read: readTopLevel,
      maxSize: structDecoder.maxSize,
    ),
  };
}

Codec<AssetV1, AssetV1> getAssetV1Codec() {
  return combineCodec(getAssetV1Encoder(), getAssetV1Decoder());
}

Account<AssetV1> decodeAssetV1(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getAssetV1Decoder());
}
