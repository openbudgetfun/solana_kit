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

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class EmitEventInstructionData {
  const EmitEventInstructionData() : discriminator = 228;

  final int discriminator;
}

Encoder<EmitEventInstructionData> getEmitEventInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (EmitEventInstructionData value) => <String, Object?>{'discriminator': 228},
  );
}

Decoder<EmitEventInstructionData> getEmitEventInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
      'codecDescription': 'emitEvent instruction decoder',
      'expected': expected,
      'bytesLength': bytesLength,
    });
  }

  (EmitEventInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(getU8Encoder().encode(228)).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (EmitEventInstructionData(), newOffset);
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<EmitEventInstructionData>(
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
      VariableSizeDecoder<EmitEventInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<EmitEventInstructionData, EmitEventInstructionData>
getEmitEventInstructionDataCodec() {
  return combineCodec(
    getEmitEventInstructionDataEncoder(),
    getEmitEventInstructionDataDecoder(),
  );
}

/// Creates a [EmitEvent] instruction.
Instruction getEmitEventInstruction({
  required Address programAddress,
  required Address eventAuthority,
}) {
  final instructionData = EmitEventInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: eventAuthority, role: AccountRole.readonlySigner),
    ],
    data: getEmitEventInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [EmitEvent] instruction from raw instruction data.
EmitEventInstructionData parseEmitEventInstruction(Instruction instruction) {
  return getEmitEventInstructionDataDecoder().decode(instruction.data!);
}
