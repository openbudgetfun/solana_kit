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

/// The discriminator field name: 'pausableDiscriminator'.
/// Offset: 1.

@immutable
class ResumeInstructionData {
  const ResumeInstructionData() : discriminator = 44, pausableDiscriminator = 2;

  final int discriminator;
  final int pausableDiscriminator;
}

Encoder<ResumeInstructionData> getResumeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('pausableDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ResumeInstructionData value) => <String, Object?>{
      'discriminator': 44,
      'pausableDiscriminator': 2,
    },
  );
}

Decoder<ResumeInstructionData> getResumeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('pausableDiscriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'resume instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ResumeInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(44),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(2),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ResumeInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ResumeInstructionData>(
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
      VariableSizeDecoder<ResumeInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ResumeInstructionData, ResumeInstructionData>
getResumeInstructionDataCodec() {
  return combineCodec(
    getResumeInstructionDataEncoder(),
    getResumeInstructionDataDecoder(),
  );
}

/// Creates a [Resume] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getResumeInstruction({
  required Address programAddress,
  required Address mint,
  required Address authority,

  bool authorityIsSigner = true,
}) {
  final instructionData = ResumeInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getResumeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Resume] instruction from raw instruction data.
ResumeInstructionData parseResumeInstruction(Instruction instruction) {
  return getResumeInstructionDataDecoder().decode(instruction.data!);
}
