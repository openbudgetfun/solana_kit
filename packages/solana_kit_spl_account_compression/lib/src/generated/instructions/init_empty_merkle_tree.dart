// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class InitEmptyMerkleTreeInstructionData {
  const InitEmptyMerkleTreeInstructionData({
    this.discriminator = 0,
    required this.maxDepth,
    required this.maxBufferSize,
  });

  final int discriminator;
  final int maxDepth;
  final int maxBufferSize;
}

Encoder<InitEmptyMerkleTreeInstructionData>
getInitEmptyMerkleTreeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('maxDepth', getU32Encoder()),
    ('maxBufferSize', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitEmptyMerkleTreeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'maxDepth': value.maxDepth,
      'maxBufferSize': value.maxBufferSize,
    },
  );
}

Decoder<InitEmptyMerkleTreeInstructionData>
getInitEmptyMerkleTreeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('maxDepth', getU32Decoder()),
    ('maxBufferSize', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        InitEmptyMerkleTreeInstructionData(
          discriminator: map['discriminator']! as int,
          maxDepth: map['maxDepth']! as int,
          maxBufferSize: map['maxBufferSize']! as int,
        ),
  );
}

Codec<InitEmptyMerkleTreeInstructionData, InitEmptyMerkleTreeInstructionData>
getInitEmptyMerkleTreeInstructionDataCodec() {
  return combineCodec(
    getInitEmptyMerkleTreeInstructionDataEncoder(),
    getInitEmptyMerkleTreeInstructionDataDecoder(),
  );
}

/// Creates a [InitEmptyMerkleTree] instruction.
Instruction getInitEmptyMerkleTreeInstruction({
  required Address programAddress,
  required Address merkleTree,
  required Address authority,
  required Address noop,

  required int maxDepth,
  required int maxBufferSize,
}) {
  final instructionData = InitEmptyMerkleTreeInstructionData(
    maxDepth: maxDepth,
    maxBufferSize: maxBufferSize,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: noop, role: AccountRole.readonly),
    ],
    data: getInitEmptyMerkleTreeInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitEmptyMerkleTree] instruction from raw instruction data.
InitEmptyMerkleTreeInstructionData parseInitEmptyMerkleTreeInstruction(
  Instruction instruction,
) {
  return getInitEmptyMerkleTreeInstructionDataDecoder().decode(
    instruction.data!,
  );
}
