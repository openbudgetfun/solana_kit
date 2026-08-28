// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import '../types/key.dart';

@immutable
class HashedAssetV1 {
  const HashedAssetV1({
    required this.key,
    required this.hash,
  });

  final Key key;
  final Uint8List hash;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HashedAssetV1 &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          hash == other.hash;

  @override
  int get hashCode => Object.hash(key, hash);

  @override
  String toString() => 'HashedAssetV1(key: $key, hash: $hash)';
}

/// The size of the [HashedAssetV1] account data in bytes.
const int hashedAssetV1Size = 33;

Encoder<HashedAssetV1> getHashedAssetV1Encoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('hash', fixEncoderSize(getBytesEncoder(), 32, allowTruncation: false)),
  ]);

  return transformEncoder(
    structEncoder,
    (HashedAssetV1 value) => <String, Object?>{
      'key': value.key,
      'hash': value.hash,
    },
  );
}

Decoder<HashedAssetV1> getHashedAssetV1Decoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('hash', fixDecoderSize(getBytesDecoder(), 32)),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'hashedAssetV1 account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (HashedAssetV1, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      HashedAssetV1(
        key: map['key']! as Key,
        hash: map['hash']! as Uint8List,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<HashedAssetV1>(
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
      VariableSizeDecoder<HashedAssetV1>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<HashedAssetV1, HashedAssetV1> getHashedAssetV1Codec() {
  return combineCodec(getHashedAssetV1Encoder(), getHashedAssetV1Decoder());
}

Account<HashedAssetV1> decodeHashedAssetV1(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getHashedAssetV1Decoder());
}
