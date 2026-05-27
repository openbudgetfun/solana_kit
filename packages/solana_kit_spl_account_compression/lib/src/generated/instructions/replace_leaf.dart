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
class ReplaceLeafInstructionData {
  const ReplaceLeafInstructionData({
    this.discriminator = 1,
    required this.root,
    required this.previousLeaf,
    required this.newLeaf,
    required this.index,
  });

  final int discriminator;
  final Uint8List root;
  final Uint8List previousLeaf;
  final Uint8List newLeaf;
  final int index;
}

Encoder<ReplaceLeafInstructionData> getReplaceLeafInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('root', getArrayEncoder(getU8Encoder(), size: FixedArraySize(32))),
    ('previousLeaf', getArrayEncoder(getU8Encoder(), size: FixedArraySize(32))),
    ('newLeaf', getArrayEncoder(getU8Encoder(), size: FixedArraySize(32))),
    ('index', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ReplaceLeafInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'root': value.root,
      'previousLeaf': value.previousLeaf,
      'newLeaf': value.newLeaf,
      'index': value.index,
    },
  );
}

Decoder<ReplaceLeafInstructionData> getReplaceLeafInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('root', getArrayDecoder(getU8Decoder(), size: FixedArraySize(32))),
    ('previousLeaf', getArrayDecoder(getU8Decoder(), size: FixedArraySize(32))),
    ('newLeaf', getArrayDecoder(getU8Decoder(), size: FixedArraySize(32))),
    ('index', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        ReplaceLeafInstructionData(
          discriminator: map['discriminator']! as int,
          root: Uint8List.fromList(map['root']! as List<int>),
          previousLeaf: Uint8List.fromList(map['previousLeaf']! as List<int>),
          newLeaf: Uint8List.fromList(map['newLeaf']! as List<int>),
          index: map['index']! as int,
        ),
  );
}

Codec<ReplaceLeafInstructionData, ReplaceLeafInstructionData>
getReplaceLeafInstructionDataCodec() {
  return combineCodec(
    getReplaceLeafInstructionDataEncoder(),
    getReplaceLeafInstructionDataDecoder(),
  );
}

/// Creates a [ReplaceLeaf] instruction.
Instruction getReplaceLeafInstruction({
  required Address programAddress,
  required Address merkleTree,
  required Address authority,
  required Address noop,

  required Uint8List root,
  required Uint8List previousLeaf,
  required Uint8List newLeaf,
  required int index,
}) {
  final instructionData = ReplaceLeafInstructionData(
    root: root,
    previousLeaf: previousLeaf,
    newLeaf: newLeaf,
    index: index,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: noop, role: AccountRole.readonly),
    ],
    data: getReplaceLeafInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ReplaceLeaf] instruction from raw instruction data.
ReplaceLeafInstructionData parseReplaceLeafInstruction(
  Instruction instruction,
) {
  return getReplaceLeafInstructionDataDecoder().decode(instruction.data!);
}
