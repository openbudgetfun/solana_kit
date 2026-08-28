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
class PuffMetadataInstructionData {
  const PuffMetadataInstructionData() : discriminator = 14;

  final int discriminator;
}

Encoder<PuffMetadataInstructionData> getPuffMetadataInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (PuffMetadataInstructionData value) => <String, Object?>{
      'discriminator': 14,
    },
  );
}

Decoder<PuffMetadataInstructionData> getPuffMetadataInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'puffMetadata instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (PuffMetadataInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(14),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      PuffMetadataInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<PuffMetadataInstructionData>(
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
      VariableSizeDecoder<PuffMetadataInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<PuffMetadataInstructionData, PuffMetadataInstructionData>
getPuffMetadataInstructionDataCodec() {
  return combineCodec(
    getPuffMetadataInstructionDataEncoder(),
    getPuffMetadataInstructionDataDecoder(),
  );
}

/// Creates a [PuffMetadata] instruction.
Instruction getPuffMetadataInstruction({
  required Address programAddress,
  required Address metadata,
}) {
  final instructionData = PuffMetadataInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
    ],
    data: getPuffMetadataInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [PuffMetadata] instruction from raw instruction data.
PuffMetadataInstructionData parsePuffMetadataInstruction(
  Instruction instruction,
) {
  return getPuffMetadataInstructionDataDecoder().decode(instruction.data!);
}
