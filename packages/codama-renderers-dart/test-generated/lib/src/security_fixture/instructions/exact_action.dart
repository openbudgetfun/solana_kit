// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

@immutable
class ExactActionInstructionData {
  const ExactActionInstructionData({
    required this.amount,
  });

  final int amount;
}

Encoder<ExactActionInstructionData> getExactActionInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('amount', getU16Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ExactActionInstructionData value) => <String, Object?>{
      'amount': value.amount,
    },
  );
}

Decoder<ExactActionInstructionData> getExactActionInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('amount', getU16Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'exactAction instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ExactActionInstructionData, int) readExact(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }
    return (
      ExactActionInstructionData(
        amount: map['amount']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ExactActionInstructionData>(
        fixedSize: structDecoder.fixedSize,
        read: (bytes, offset) {
          final bytesLength = bytes.length - offset;
          if (bytesLength != structDecoder.fixedSize) {
            throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
          }
          return readExact(bytes, offset);
        },
      ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<ExactActionInstructionData>(
        read: readExact,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ExactActionInstructionData, ExactActionInstructionData>
getExactActionInstructionDataCodec() {
  return combineCodec(
    getExactActionInstructionDataEncoder(),
    getExactActionInstructionDataDecoder(),
  );
}

/// Creates a [ExactAction] instruction.
Instruction getExactActionInstruction({
  required Address programAddress,

  required int amount,
}) {
  final instructionData = ExactActionInstructionData(
    amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [],
    data: getExactActionInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ExactAction] instruction from raw instruction data.
ExactActionInstructionData parseExactActionInstruction(
  Instruction instruction,
) {
  return getExactActionInstructionDataDecoder().decode(instruction.data!);
}
