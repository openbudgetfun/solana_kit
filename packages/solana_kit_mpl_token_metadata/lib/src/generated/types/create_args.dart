// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './asset_data.dart';
import './print_supply.dart';

sealed class CreateArgs {
  const CreateArgs();
}

final class CreateArgsV1 extends CreateArgs {
  const CreateArgsV1({
    required this.assetData,
    required this.decimals,
    required this.printSupply,
  });

  final AssetData assetData;
  final int? decimals;
  final PrintSupply? printSupply;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateArgsV1 &&
          assetData == other.assetData &&
          decimals == other.decimals &&
          printSupply == other.printSupply;

  @override
  int get hashCode => Object.hash(assetData, decimals, printSupply);

  @override
  String toString() =>
      'CreateArgs.V1(assetData: $assetData, decimals: $decimals, printSupply: $printSupply)';
}

Encoder<CreateArgs> getCreateArgsEncoder() {
  return transformEncoder<Map<String, Object?>, CreateArgs>(
    getDiscriminatedUnionEncoder([
      (
        0,
        getStructEncoder([
          ('assetData', getAssetDataEncoder()),
          (
            'decimals',
            getNullableEncoder<int>(
              transformEncoder(getU8Encoder(), (int value) => value),
            ),
          ),
          (
            'printSupply',
            getNullableEncoder<PrintSupply>(
              transformEncoder(
                getPrintSupplyEncoder(),
                (PrintSupply value) => value,
              ),
            ),
          ),
        ]),
      ),
    ], size: getU8Encoder()),
    (CreateArgs value) => switch (value) {
      CreateArgsV1(
        assetData: final assetData,
        decimals: final decimals,
        printSupply: final printSupply,
      ) =>
        <String, Object?>{
          '__kind': 0,
          'assetData': assetData,
          'decimals': decimals,
          'printSupply': printSupply,
        },
    },
  );
}

Decoder<CreateArgs> getCreateArgsDecoder() {
  return transformDecoder<Map<String, Object?>, CreateArgs>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('assetData', getAssetDataDecoder()),
            ('decimals', getNullableDecoder<int>(getU8Decoder())),
            (
              'printSupply',
              getNullableDecoder<PrintSupply>(getPrintSupplyDecoder()),
            ),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return CreateArgsV1(
            assetData: map['assetData']! as AssetData,
            decimals: map['decimals'] as int?,
            printSupply: map['printSupply'] as PrintSupply?,
          );
      }
      throw StateError(
        'Unsupported CreateArgs discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<CreateArgs, CreateArgs> getCreateArgsCodec() {
  return combineCodec(getCreateArgsEncoder(), getCreateArgsDecoder());
}
