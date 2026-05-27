// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// FreezeV2 instruction data for mpl-bubblegum compressed NFTs.
@immutable
class FreezeV2InstructionData {
  const FreezeV2InstructionData({
    this.discriminator = 12,
    required this.root,
    required this.dataHash,
    required this.creatorHash,
    this.assetDataHash,
    this.flags,
    required this.nonce,
    required this.index,
  });

  final int discriminator;
  final List<int> root;
  final List<int> dataHash;
  final List<int> creatorHash;
  final List<int>? assetDataHash;
  final int? flags;
  final BigInt nonce;
  final int index;
}

Encoder<FreezeV2InstructionData> getFreezeV2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
      ('root', getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32))),
      ('dataHash', getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32))),
      ('creatorHash', getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32))),
      ('assetDataHash', getNullableEncoder(getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32)))),
      ('flags', getNullableEncoder(getU8Encoder())),
      ('nonce', getU64Encoder()),
      ('index', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (FreezeV2InstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'root': Uint8List.fromList(value.root),
      'dataHash': Uint8List.fromList(value.dataHash),
      'creatorHash': Uint8List.fromList(value.creatorHash),
      'assetDataHash': value.assetDataHash,
      'flags': value.flags,
      'nonce': value.nonce,
      'index': value.index,
    },
  );
}

Decoder<FreezeV2InstructionData> getFreezeV2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
      ('root', getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32))),
      ('dataHash', getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32))),
      ('creatorHash', getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32))),
      ('assetDataHash', getNullableDecoder(getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32)))),
      ('flags', getNullableDecoder(getU8Decoder())),
      ('nonce', getU64Decoder()),
      ('index', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => FreezeV2InstructionData(
          discriminator: map['discriminator']! as int,
          root: map['root']! as List<int>,
          dataHash: map['dataHash']! as List<int>,
          creatorHash: map['creatorHash']! as List<int>,
          assetDataHash: map['assetDataHash']! as List<int>?,
          flags: map['flags']! as int?,
          nonce: map['nonce']! as BigInt,
          index: map['index']! as int,
        ),
  );
}

Codec<FreezeV2InstructionData, FreezeV2InstructionData> getFreezeV2InstructionDataCodec() {
  return combineCodec(
    getFreezeV2InstructionDataEncoder(),
    getFreezeV2InstructionDataDecoder(),
  );
}

/// Creates a [FreezeV2] instruction.
Instruction getFreezeV2Instruction({
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
  required List<int>? assetDataHash,
  required int? flags,
  required BigInt nonce,
  required int index,
}) {
  final instructionData = FreezeV2InstructionData(
      root: root,
      dataHash: dataHash,
      creatorHash: creatorHash,
      assetDataHash: assetDataHash,
      flags: flags,
      nonce: nonce,
      index: index,
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
    data: getFreezeV2InstructionDataEncoder().encode(instructionData),
  );
}
