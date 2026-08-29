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
class CollectionV1 {
  const CollectionV1({
    required this.key,
    required this.updateAuthority,
    required this.name,
    required this.uri,
    required this.numMinted,
    required this.currentSize,
  });

  final Key key;
  final Address updateAuthority;
  final String name;
  final String uri;
  final int numMinted;
  final int currentSize;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionV1 &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          updateAuthority == other.updateAuthority &&
          name == other.name &&
          uri == other.uri &&
          numMinted == other.numMinted &&
          currentSize == other.currentSize;

  @override
  int get hashCode =>
      Object.hash(key, updateAuthority, name, uri, numMinted, currentSize);

  @override
  String toString() =>
      'CollectionV1(key: $key, updateAuthority: $updateAuthority, name: $name, uri: $uri, numMinted: $numMinted, currentSize: $currentSize)';
}

Encoder<CollectionV1> getCollectionV1Encoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('updateAuthority', getAddressEncoder()),
    ('name', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('uri', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('numMinted', getU32Encoder()),
    ('currentSize', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CollectionV1 value) => <String, Object?>{
      'key': value.key,
      'updateAuthority': value.updateAuthority,
      'name': value.name,
      'uri': value.uri,
      'numMinted': value.numMinted,
      'currentSize': value.currentSize,
    },
  );
}

Decoder<CollectionV1> getCollectionV1Decoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('updateAuthority', getAddressDecoder()),
    ('name', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('uri', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('numMinted', getU32Decoder()),
    ('currentSize', getU32Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'collectionV1 account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CollectionV1, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      CollectionV1(
        key: map['key']! as Key,
        updateAuthority: map['updateAuthority']! as Address,
        name: map['name']! as String,
        uri: map['uri']! as String,
        numMinted: map['numMinted']! as int,
        currentSize: map['currentSize']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<CollectionV1>(
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
      VariableSizeDecoder<CollectionV1>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CollectionV1, CollectionV1> getCollectionV1Codec() {
  return combineCodec(getCollectionV1Encoder(), getCollectionV1Decoder());
}

Account<CollectionV1> decodeCollectionV1(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getCollectionV1Decoder());
}
