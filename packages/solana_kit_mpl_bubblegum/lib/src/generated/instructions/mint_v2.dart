// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/enums.dart';

/// MintV2 instruction data for mpl-bubblegum compressed NFTs.
@immutable
class MintV2InstructionData {
  const MintV2InstructionData({
    this.discriminator = 15,
    required this.metadataArgs,
    this.assetData,
    this.assetDataSchema,
  });

  final int discriminator;
  final MetadataArgsV2 metadataArgs;
  final List<int>? assetData;
  final AssetDataSchema? assetDataSchema;
}

Encoder<MintV2InstructionData> getMintV2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('metadataArgs', getU8Encoder()),
    ('assetData', getNullableEncoder(getBytesEncoder())),
    ('assetDataSchema', getNullableEncoder(getU8Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (MintV2InstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'metadataArgs': value.metadataArgs,
      'assetData': value.assetData,
      'assetDataSchema': value.assetDataSchema,
    },
  );
}

Decoder<MintV2InstructionData> getMintV2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('metadataArgs', getU8Decoder()),
    ('assetData', getNullableDecoder(getBytesDecoder())),
    ('assetDataSchema', getNullableDecoder(getU8Decoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        MintV2InstructionData(
          discriminator: map['discriminator']! as int,
          metadataArgs: map['metadataArgs']! as MetadataArgsV2,
          assetData: map['assetData']! as List<int>?,
          assetDataSchema: map['assetDataSchema']! as AssetDataSchema?,
        ),
  );
}

Codec<MintV2InstructionData, MintV2InstructionData>
getMintV2InstructionDataCodec() {
  return combineCodec(
    getMintV2InstructionDataEncoder(),
    getMintV2InstructionDataDecoder(),
  );
}

/// Creates a [MintV2] instruction.
Instruction getMintV2Instruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address payer,
  required Address treeDelegate,
  required Address collectionAuthority,
  required Address leafOwner,
  required Address leafDelegate,
  required Address merkleTree,
  required Address coreCollection,
  required Address mplCoreCpiSigner,
  required Address logWrapper,
  required Address compressionProgram,
  required Address mplCoreProgram,
  required Address systemProgram,
  required MetadataArgsV2 metadataArgs,
  required List<int>? assetData,
  required AssetDataSchema? assetDataSchema,
}) {
  final instructionData = MintV2InstructionData(
    metadataArgs: metadataArgs,
    assetData: assetData,
    assetDataSchema: assetDataSchema,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: treeDelegate, role: AccountRole.readonlySigner),
      AccountMeta(
        address: collectionAuthority,
        role: AccountRole.readonlySigner,
      ),
      AccountMeta(address: leafOwner, role: AccountRole.readonly),
      AccountMeta(address: leafDelegate, role: AccountRole.readonly),
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: coreCollection, role: AccountRole.writable),
      AccountMeta(address: mplCoreCpiSigner, role: AccountRole.readonly),
      AccountMeta(address: logWrapper, role: AccountRole.readonly),
      AccountMeta(address: compressionProgram, role: AccountRole.readonly),
      AccountMeta(address: mplCoreProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getMintV2InstructionDataEncoder().encode(instructionData),
  );
}
