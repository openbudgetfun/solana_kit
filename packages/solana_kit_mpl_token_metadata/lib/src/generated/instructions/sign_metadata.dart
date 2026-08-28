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
class SignMetadataInstructionData {
  const SignMetadataInstructionData() : discriminator = 7;

  final int discriminator;
}

Encoder<SignMetadataInstructionData> getSignMetadataInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SignMetadataInstructionData value) => <String, Object?>{
      'discriminator': 7,
    },
  );
}

Decoder<SignMetadataInstructionData> getSignMetadataInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'signMetadata instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (SignMetadataInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(7),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      SignMetadataInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<SignMetadataInstructionData>(
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
      VariableSizeDecoder<SignMetadataInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<SignMetadataInstructionData, SignMetadataInstructionData>
getSignMetadataInstructionDataCodec() {
  return combineCodec(
    getSignMetadataInstructionDataEncoder(),
    getSignMetadataInstructionDataDecoder(),
  );
}

/// Creates a [SignMetadata] instruction.
Instruction getSignMetadataInstruction({
  required Address programAddress,
  required Address metadata,
  required Address creator,
}) {
  final instructionData = SignMetadataInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: creator, role: AccountRole.readonlySigner),
    ],
    data: getSignMetadataInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [SignMetadata] instruction from raw instruction data.
SignMetadataInstructionData parseSignMetadataInstruction(
  Instruction instruction,
) {
  return getSignMetadataInstructionDataDecoder().decode(instruction.data!);
}
