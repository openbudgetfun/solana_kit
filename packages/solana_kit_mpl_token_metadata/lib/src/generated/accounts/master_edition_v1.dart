// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import '../types/key.dart';

@immutable
class MasterEditionV1 {
  const MasterEditionV1({
    required this.key,
    required this.supply,
    required this.maxSupply,
    required this.printingMint,
    required this.oneTimePrintingAuthorizationMint,
  });

  final Key key;
  final BigInt supply;
  final BigInt? maxSupply;
  final Address printingMint;
  final Address oneTimePrintingAuthorizationMint;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MasterEditionV1 &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          supply == other.supply &&
          maxSupply == other.maxSupply &&
          printingMint == other.printingMint &&
          oneTimePrintingAuthorizationMint ==
              other.oneTimePrintingAuthorizationMint;

  @override
  int get hashCode => Object.hash(
    key,
    supply,
    maxSupply,
    printingMint,
    oneTimePrintingAuthorizationMint,
  );

  @override
  String toString() =>
      'MasterEditionV1(key: $key, supply: $supply, maxSupply: $maxSupply, printingMint: $printingMint, oneTimePrintingAuthorizationMint: $oneTimePrintingAuthorizationMint)';
}

Encoder<MasterEditionV1> getMasterEditionV1Encoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('supply', getU64Encoder()),
    (
      'maxSupply',
      getNullableEncoder<BigInt>(
        transformEncoder(getU64Encoder(), (BigInt value) => value),
      ),
    ),
    ('printingMint', getAddressEncoder()),
    ('oneTimePrintingAuthorizationMint', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (MasterEditionV1 value) => <String, Object?>{
      'key': value.key,
      'supply': value.supply,
      'maxSupply': value.maxSupply,
      'printingMint': value.printingMint,
      'oneTimePrintingAuthorizationMint':
          value.oneTimePrintingAuthorizationMint,
    },
  );
}

Decoder<MasterEditionV1> getMasterEditionV1Decoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('supply', getU64Decoder()),
    ('maxSupply', getNullableDecoder<BigInt>(getU64Decoder())),
    ('printingMint', getAddressDecoder()),
    ('oneTimePrintingAuthorizationMint', getAddressDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'masterEditionV1 account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MasterEditionV1, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      MasterEditionV1(
        key: map['key']! as Key,
        supply: map['supply']! as BigInt,
        maxSupply: map['maxSupply'] as BigInt?,
        printingMint: map['printingMint']! as Address,
        oneTimePrintingAuthorizationMint:
            map['oneTimePrintingAuthorizationMint']! as Address,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MasterEditionV1>(
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
      VariableSizeDecoder<MasterEditionV1>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<MasterEditionV1, MasterEditionV1> getMasterEditionV1Codec() {
  return combineCodec(getMasterEditionV1Encoder(), getMasterEditionV1Decoder());
}

Account<MasterEditionV1> decodeMasterEditionV1(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getMasterEditionV1Decoder());
}
