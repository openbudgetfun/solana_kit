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

/// UpdateAssetDataV2 instruction data for mpl-bubblegum compressed NFTs.
@immutable
class UpdateAssetDataV2InstructionData {
  const UpdateAssetDataV2InstructionData({
    this.discriminator = 30,
    required this.root,
    required this.dataHash,
    required this.creatorHash,
    this.previousAssetDataHash,
    this.flags,
    required this.nonce,
    required this.index,
    this.newAssetData,
    this.newAssetDataSchema,
  });

  final int discriminator;
  final List<int> root;
  final List<int> dataHash;
  final List<int> creatorHash;
  final List<int>? previousAssetDataHash;
  final int? flags;
  final int nonce;
  final int index;
  final List<int>? newAssetData;
  final AssetDataSchema? newAssetDataSchema;
}

Encoder<UpdateAssetDataV2InstructionData> getUpdateAssetDataV2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
      ('root', getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32))),
      ('dataHash', getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32))),
      ('creatorHash', getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32))),
      ('previousAssetDataHash', getNullableEncoder(getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32)))),
      ('flags', getNullableEncoder(getU8Encoder())),
      ('nonce', getU64Encoder()),
      ('index', getU32Encoder()),
      ('newAssetData', getNullableEncoder(getBytesEncoder())),
      ('newAssetDataSchema', getNullableEncoder(getU8Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateAssetDataV2InstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'root': Uint8List.fromList(value.root),
      'dataHash': Uint8List.fromList(value.dataHash),
      'creatorHash': Uint8List.fromList(value.creatorHash),
      'previousAssetDataHash': value.previousAssetDataHash,
      'flags': value.flags,
      'nonce': value.nonce,
      'index': value.index,
      'newAssetData': value.newAssetData,
      'newAssetDataSchema': value.newAssetDataSchema,
    },
  );
}

Decoder<UpdateAssetDataV2InstructionData> getUpdateAssetDataV2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
      ('root', getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32))),
      ('dataHash', getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32))),
      ('creatorHash', getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32))),
      ('previousAssetDataHash', getNullableDecoder(getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32)))),
      ('flags', getNullableDecoder(getU8Decoder())),
      ('nonce', getU64Decoder()),
      ('index', getU32Decoder()),
      ('newAssetData', getNullableDecoder(getBytesDecoder())),
      ('newAssetDataSchema', getNullableDecoder(getU8Decoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UpdateAssetDataV2InstructionData(
          discriminator: map['discriminator']! as int,
          root: map['root']! as List<int>,
          dataHash: map['dataHash']! as List<int>,
          creatorHash: map['creatorHash']! as List<int>,
          previousAssetDataHash: map['previousAssetDataHash']! as List<int>?,
          flags: map['flags']! as int?,
          nonce: map['nonce']! as int,
          index: map['index']! as int,
          newAssetData: map['newAssetData']! as List<int>?,
          newAssetDataSchema: map['newAssetDataSchema']! as AssetDataSchema?,
        ),
  );
}

Codec<UpdateAssetDataV2InstructionData, UpdateAssetDataV2InstructionData> getUpdateAssetDataV2InstructionDataCodec() {
  return combineCodec(
    getUpdateAssetDataV2InstructionDataEncoder(),
    getUpdateAssetDataV2InstructionDataDecoder(),
  );
}

/// Creates a [UpdateAssetDataV2] instruction.
Instruction getUpdateAssetDataV2Instruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address payer,
  required Address authority,
  required Address leafOwner,
  required Address leafDelegate,
  required Address merkleTree,
  required Address coreCollection,
  required Address logWrapper,
  required Address compressionProgram,
  required Address systemProgram,
  required List<int> root,
  required List<int> dataHash,
  required List<int> creatorHash,
  required List<int>? previousAssetDataHash,
  required int? flags,
  required int nonce,
  required int index,
  required List<int>? newAssetData,
  required AssetDataSchema? newAssetDataSchema,
}) {
  final instructionData = UpdateAssetDataV2InstructionData(
      root: root,
      dataHash: dataHash,
      creatorHash: creatorHash,
      previousAssetDataHash: previousAssetDataHash,
      flags: flags,
      nonce: nonce,
      index: index,
      newAssetData: newAssetData,
      newAssetDataSchema: newAssetDataSchema,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: leafOwner, role: AccountRole.readonly),
      AccountMeta(address: leafDelegate, role: AccountRole.readonly),
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: coreCollection, role: AccountRole.readonly),
      AccountMeta(address: logWrapper, role: AccountRole.readonly),
      AccountMeta(address: compressionProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getUpdateAssetDataV2InstructionDataEncoder().encode(instructionData),
  );
}
