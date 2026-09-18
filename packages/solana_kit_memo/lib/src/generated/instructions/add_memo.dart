// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
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

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'addMemo instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (AddMemoInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      AddMemoInstructionData(
        memo: map['memo']! as String,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<AddMemoInstructionData>(
        fixedSize: structDecoder.fixedSize,
        read: (bytes, offset) {
          final bytesLength = bytes.length - offset;
          if (bytesLength != structDecoder.fixedSize) {
            throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
          }
          return readTopLevel(bytes, offset);
        },
      ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<AddMemoInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
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
