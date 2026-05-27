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
class InsertOrAppendInstructionData {
  const InsertOrAppendInstructionData({
    this.discriminator = 5,
    required this.root,
    required this.leaf,
    required this.index,
  });

  final int discriminator;
  final Uint8List root;
  final Uint8List leaf;
  final int index;
}

Encoder<InsertOrAppendInstructionData>
getInsertOrAppendInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('root', getArrayEncoder(getU8Encoder(), size: FixedArraySize(32))),
    ('leaf', getArrayEncoder(getU8Encoder(), size: FixedArraySize(32))),
    ('index', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InsertOrAppendInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'root': value.root,
      'leaf': value.leaf,
      'index': value.index,
    },
  );
}

Decoder<InsertOrAppendInstructionData>
getInsertOrAppendInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('root', getArrayDecoder(getU8Decoder(), size: FixedArraySize(32))),
    ('leaf', getArrayDecoder(getU8Decoder(), size: FixedArraySize(32))),
    ('index', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        InsertOrAppendInstructionData(
          discriminator: map['discriminator']! as int,
          root: Uint8List.fromList(map['root']! as List<int>),
          leaf: Uint8List.fromList(map['leaf']! as List<int>),
          index: map['index']! as int,
        ),
  );
}

Codec<InsertOrAppendInstructionData, InsertOrAppendInstructionData>
getInsertOrAppendInstructionDataCodec() {
  return combineCodec(
    getInsertOrAppendInstructionDataEncoder(),
    getInsertOrAppendInstructionDataDecoder(),
  );
}

/// Creates a [InsertOrAppend] instruction.
Instruction getInsertOrAppendInstruction({
  required Address programAddress,
  required Address merkleTree,
  required Address authority,
  required Address noop,

  required Uint8List root,
  required Uint8List leaf,
  required int index,
}) {
  final instructionData = InsertOrAppendInstructionData(
    root: root,
    leaf: leaf,
    index: index,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: noop, role: AccountRole.readonly),
    ],
    data: getInsertOrAppendInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InsertOrAppend] instruction from raw instruction data.
InsertOrAppendInstructionData parseInsertOrAppendInstruction(
  Instruction instruction,
) {
  return getInsertOrAppendInstructionDataDecoder().decode(instruction.data!);
}
