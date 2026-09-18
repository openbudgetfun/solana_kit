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
class PauseInstructionData {
  const PauseInstructionData() : discriminator = 44, pausableDiscriminator = 1;

  final int discriminator;
  final int pausableDiscriminator;
}

Encoder<PauseInstructionData> getPauseInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('pausableDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (PauseInstructionData value) => <String, Object?>{
      'discriminator': 44,
      'pausableDiscriminator': 1,
    },
  );
}

Decoder<PauseInstructionData> getPauseInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('pausableDiscriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'pause instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (PauseInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(44),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(1),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      PauseInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<PauseInstructionData>(
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
      VariableSizeDecoder<PauseInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<PauseInstructionData, PauseInstructionData>
getPauseInstructionDataCodec() {
  return combineCodec(
    getPauseInstructionDataEncoder(),
    getPauseInstructionDataDecoder(),
  );
}

/// Creates a [Pause] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getPauseInstruction({
  required Address programAddress,
  required Address mint,
  required Address authority,

  bool authorityIsSigner = true,
}) {
  final instructionData = PauseInstructionData();

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
    data: getPauseInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Pause] instruction from raw instruction data.
PauseInstructionData parsePauseInstruction(Instruction instruction) {
  return getPauseInstructionDataDecoder().decode(instruction.data!);
}
