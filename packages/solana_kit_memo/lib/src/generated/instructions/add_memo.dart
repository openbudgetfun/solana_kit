// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

@immutable
class AddMemoInstructionData {
  const AddMemoInstructionData({
    required this.memo,
  });

  final String memo;
}

Encoder<AddMemoInstructionData> getAddMemoInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('memo', getUtf8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AddMemoInstructionData value) => <String, Object?>{
      'memo': value.memo,
    },
  );
}

Decoder<AddMemoInstructionData> getAddMemoInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('memo', getUtf8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        AddMemoInstructionData(
          memo: map['memo']! as String,
        ),
  );
}

Codec<AddMemoInstructionData, AddMemoInstructionData>
getAddMemoInstructionDataCodec() {
  return combineCodec(
    getAddMemoInstructionDataEncoder(),
    getAddMemoInstructionDataDecoder(),
  );
}

/// Creates a [AddMemo] instruction.
Instruction getAddMemoInstruction({
  required Address programAddress,

  required String memo,
}) {
  final instructionData = AddMemoInstructionData(
    memo: memo,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [],
    data: getAddMemoInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [AddMemo] instruction from raw instruction data.
AddMemoInstructionData parseAddMemoInstruction(Instruction instruction) {
  return getAddMemoInstructionDataDecoder().decode(instruction.data!);
}
