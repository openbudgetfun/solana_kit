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
class ChangeSchemaStatusInstructionData {
  const ChangeSchemaStatusInstructionData({required this.isPaused})
    : discriminator = 2;

  final int discriminator;
  final bool isPaused;
}

Encoder<ChangeSchemaStatusInstructionData>
getChangeSchemaStatusInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('isPaused', getBooleanEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ChangeSchemaStatusInstructionData value) => <String, Object?>{
      'discriminator': 2,
      'isPaused': value.isPaused,
    },
  );
}

Decoder<ChangeSchemaStatusInstructionData>
getChangeSchemaStatusInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('isPaused', getBooleanDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
      'codecDescription': 'changeSchemaStatus instruction decoder',
      'expected': expected,
      'bytesLength': bytesLength,
    });
  }

  (ChangeSchemaStatusInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(getU8Encoder().encode(2)).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ChangeSchemaStatusInstructionData(isPaused: map['isPaused']! as bool),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ChangeSchemaStatusInstructionData>(
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
      VariableSizeDecoder<ChangeSchemaStatusInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ChangeSchemaStatusInstructionData, ChangeSchemaStatusInstructionData>
getChangeSchemaStatusInstructionDataCodec() {
  return combineCodec(
    getChangeSchemaStatusInstructionDataEncoder(),
    getChangeSchemaStatusInstructionDataDecoder(),
  );
}

/// Creates a [ChangeSchemaStatus] instruction.
Instruction getChangeSchemaStatusInstruction({
  required Address programAddress,
  required Address authority,
  required Address credential,
  required Address schema,
  required bool isPaused,
}) {
  final instructionData = ChangeSchemaStatusInstructionData(isPaused: isPaused);

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: credential, role: AccountRole.readonly),
      AccountMeta(address: schema, role: AccountRole.writable),
    ],
    data: getChangeSchemaStatusInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ChangeSchemaStatus] instruction from raw instruction data.
ChangeSchemaStatusInstructionData parseChangeSchemaStatusInstruction(
  Instruction instruction,
) {
  return getChangeSchemaStatusInstructionDataDecoder().decode(
    instruction.data!,
  );
}
