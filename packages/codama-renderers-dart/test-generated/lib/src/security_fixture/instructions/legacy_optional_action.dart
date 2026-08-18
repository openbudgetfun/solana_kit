// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

@immutable
class LegacyOptionalActionInstructionData {
  const LegacyOptionalActionInstructionData();
}

Encoder<LegacyOptionalActionInstructionData>
getLegacyOptionalActionInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[]);

  return transformEncoder(
    structEncoder,
    (LegacyOptionalActionInstructionData value) => <String, Object?>{},
  );
}

Decoder<LegacyOptionalActionInstructionData>
getLegacyOptionalActionInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'legacyOptionalAction instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (LegacyOptionalActionInstructionData, int) readExact(
    Uint8List bytes,
    int offset,
  ) {
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }
    return (
      LegacyOptionalActionInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<LegacyOptionalActionInstructionData>(
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
      VariableSizeDecoder<LegacyOptionalActionInstructionData>(
        read: readExact,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<LegacyOptionalActionInstructionData, LegacyOptionalActionInstructionData>
getLegacyOptionalActionInstructionDataCodec() {
  return combineCodec(
    getLegacyOptionalActionInstructionDataEncoder(),
    getLegacyOptionalActionInstructionDataDecoder(),
  );
}

/// Creates a [LegacyOptionalAction] instruction.
Instruction getLegacyOptionalActionInstruction({
  required Address programAddress,
  required Address before,
  Address? optionalMiddle,
  required Address after,
}) {
  final instructionData = LegacyOptionalActionInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: before, role: AccountRole.readonly),
      if (optionalMiddle != null)
        AccountMeta(address: optionalMiddle, role: AccountRole.writable),
      AccountMeta(address: after, role: AccountRole.readonlySigner),
    ],
    data: getLegacyOptionalActionInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [LegacyOptionalAction] instruction from raw instruction data.
LegacyOptionalActionInstructionData parseLegacyOptionalActionInstruction(
  Instruction instruction,
) {
  return getLegacyOptionalActionInstructionDataDecoder().decode(
    instruction.data!,
  );
}
