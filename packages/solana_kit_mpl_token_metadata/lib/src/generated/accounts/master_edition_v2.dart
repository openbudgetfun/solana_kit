// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import '../types/key.dart';

@immutable
class MasterEditionV2 {
  const MasterEditionV2({
    required this.key,
    required this.supply,
    required this.maxSupply,
  });

  final Key key;
  final BigInt supply;
  final BigInt? maxSupply;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MasterEditionV2 &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          supply == other.supply &&
          maxSupply == other.maxSupply;

  @override
  int get hashCode => Object.hash(key, supply, maxSupply);

  @override
  String toString() =>
      'MasterEditionV2(key: $key, supply: $supply, maxSupply: $maxSupply)';
}

Encoder<MasterEditionV2> getMasterEditionV2Encoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('supply', getU64Encoder()),
    ('maxSupply', getNullableEncoder<BigInt>(getU64Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (MasterEditionV2 value) => <String, Object?>{
      'key': value.key,
      'supply': value.supply,
      'maxSupply': value.maxSupply,
    },
  );
}

Decoder<MasterEditionV2> getMasterEditionV2Decoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('supply', getU64Decoder()),
    ('maxSupply', getNullableDecoder<BigInt>(getU64Decoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'masterEditionV2 account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MasterEditionV2, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      MasterEditionV2(
        key: map['key']! as Key,
        supply: map['supply']! as BigInt,
        maxSupply: map['maxSupply'] as BigInt?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MasterEditionV2>(
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
      VariableSizeDecoder<MasterEditionV2>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<MasterEditionV2, MasterEditionV2> getMasterEditionV2Codec() {
  return combineCodec(getMasterEditionV2Encoder(), getMasterEditionV2Decoder());
}

Account<MasterEditionV2> decodeMasterEditionV2(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getMasterEditionV2Decoder());
}
