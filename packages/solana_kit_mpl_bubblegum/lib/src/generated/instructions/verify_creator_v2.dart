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

/// VerifyCreatorV2 instruction data for mpl-bubblegum compressed NFTs.
@immutable
class VerifyCreatorV2InstructionData {
  const VerifyCreatorV2InstructionData({
    this.discriminator = 35,
    required this.root,
    this.assetDataHash,
    this.flags,
    required this.nonce,
    required this.index,
    required this.message,
  });

  final int discriminator;
  final List<int> root;
  final List<int>? assetDataHash;
  final int? flags;
  final int nonce;
  final int index;
  final MetadataArgsV2 message;
}

Encoder<VerifyCreatorV2InstructionData> getVerifyCreatorV2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
      ('root', getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32))),
      ('assetDataHash', getNullableEncoder(getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32)))),
      ('flags', getNullableEncoder(getU8Encoder())),
      ('nonce', getU64Encoder()),
      ('index', getU32Encoder()),
      ('message', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (VerifyCreatorV2InstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'root': Uint8List.fromList(value.root),
      'assetDataHash': value.assetDataHash,
      'flags': value.flags,
      'nonce': value.nonce,
      'index': value.index,
      'message': value.message,
    },
  );
}

Decoder<VerifyCreatorV2InstructionData> getVerifyCreatorV2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
      ('root', getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32))),
      ('assetDataHash', getNullableDecoder(getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32)))),
      ('flags', getNullableDecoder(getU8Decoder())),
      ('nonce', getU64Decoder()),
      ('index', getU32Decoder()),
      ('message', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => VerifyCreatorV2InstructionData(
          discriminator: map['discriminator']! as int,
          root: map['root']! as List<int>,
          assetDataHash: map['assetDataHash']! as List<int>?,
          flags: map['flags']! as int?,
          nonce: map['nonce']! as int,
          index: map['index']! as int,
          message: map['message']! as MetadataArgsV2,
        ),
  );
}

Codec<VerifyCreatorV2InstructionData, VerifyCreatorV2InstructionData> getVerifyCreatorV2InstructionDataCodec() {
  return combineCodec(
    getVerifyCreatorV2InstructionDataEncoder(),
    getVerifyCreatorV2InstructionDataDecoder(),
  );
}

/// Creates a [VerifyCreatorV2] instruction.
Instruction getVerifyCreatorV2Instruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address payer,
  required Address creator,
  required Address leafOwner,
  required Address leafDelegate,
  required Address merkleTree,
  required Address logWrapper,
  required Address compressionProgram,
  required Address systemProgram,
  required List<int> root,
  required List<int>? assetDataHash,
  required int? flags,
  required int nonce,
  required int index,
  required MetadataArgsV2 message,
}) {
  final instructionData = VerifyCreatorV2InstructionData(
      root: root,
      assetDataHash: assetDataHash,
      flags: flags,
      nonce: nonce,
      index: index,
      message: message,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: creator, role: AccountRole.readonlySigner),
      AccountMeta(address: leafOwner, role: AccountRole.readonly),
      AccountMeta(address: leafDelegate, role: AccountRole.readonly),
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: logWrapper, role: AccountRole.readonly),
      AccountMeta(address: compressionProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getVerifyCreatorV2InstructionDataEncoder().encode(instructionData),
  );
}
