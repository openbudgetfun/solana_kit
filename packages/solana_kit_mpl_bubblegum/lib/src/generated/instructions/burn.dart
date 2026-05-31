// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Burn instruction data for mpl-bubblegum compressed NFTs.
@immutable
class BurnInstructionData {
  const BurnInstructionData({
    this.discriminator = 0,
    required this.root,
    required this.dataHash,
    required this.creatorHash,
    required this.nonce,
    required this.index,
  });

  final int discriminator;
  final List<int> root;
  final List<int> dataHash;
  final List<int> creatorHash;
  final BigInt nonce;
  final int index;
}

Encoder<BurnInstructionData> getBurnInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('root', getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32))),
    (
      'dataHash',
      getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32)),
    ),
    (
      'creatorHash',
      getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32)),
    ),
    ('nonce', getU64Encoder()),
    ('index', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (BurnInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'root': Uint8List.fromList(value.root),
      'dataHash': Uint8List.fromList(value.dataHash),
      'creatorHash': Uint8List.fromList(value.creatorHash),
      'nonce': value.nonce,
      'index': value.index,
    },
  );
}

Decoder<BurnInstructionData> getBurnInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('root', getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32))),
    (
      'dataHash',
      getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32)),
    ),
    (
      'creatorHash',
      getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32)),
    ),
    ('nonce', getU64Decoder()),
    ('index', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        BurnInstructionData(
          discriminator: map['discriminator']! as int,
          root: map['root']! as List<int>,
          dataHash: map['dataHash']! as List<int>,
          creatorHash: map['creatorHash']! as List<int>,
          nonce: map['nonce']! as BigInt,
          index: map['index']! as int,
        ),
  );
}

Codec<BurnInstructionData, BurnInstructionData> getBurnInstructionDataCodec() {
  return combineCodec(
    getBurnInstructionDataEncoder(),
    getBurnInstructionDataDecoder(),
  );
}

/// Creates a [Burn] instruction.
Instruction getBurnInstruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address leafOwner,
  required Address leafDelegate,
  required Address merkleTree,
  required Address logWrapper,
  required Address compressionProgram,
  required Address systemProgram,
  required List<int> root,
  required List<int> dataHash,
  required List<int> creatorHash,
  required BigInt nonce,
  required int index,
}) {
  final instructionData = BurnInstructionData(
    root: root,
    dataHash: dataHash,
    creatorHash: creatorHash,
    nonce: nonce,
    index: index,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.readonly),
      AccountMeta(address: leafOwner, role: AccountRole.readonly),
      AccountMeta(address: leafDelegate, role: AccountRole.readonly),
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: logWrapper, role: AccountRole.readonly),
      AccountMeta(address: compressionProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getBurnInstructionDataEncoder().encode(instructionData),
  );
}
