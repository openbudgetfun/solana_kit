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
class CloseGroupV1InstructionData {
  const CloseGroupV1InstructionData() : discriminator = 40;

  final int discriminator;
}

Encoder<CloseGroupV1InstructionData> getCloseGroupV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CloseGroupV1InstructionData value) => <String, Object?>{
      'discriminator': 40,
    },
  );
}

Decoder<CloseGroupV1InstructionData> getCloseGroupV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'closeGroupV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CloseGroupV1InstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(40),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CloseGroupV1InstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CloseGroupV1InstructionData>(
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
      VariableSizeDecoder<CloseGroupV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CloseGroupV1InstructionData, CloseGroupV1InstructionData>
getCloseGroupV1InstructionDataCodec() {
  return combineCodec(
    getCloseGroupV1InstructionDataEncoder(),
    getCloseGroupV1InstructionDataDecoder(),
  );
}

/// Creates a [CloseGroupV1] instruction.
Instruction getCloseGroupV1Instruction({
  required Address programAddress,
  required Address group,
  required Address payer,
  Address? authority,
}) {
  final instructionData = CloseGroupV1InstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: group, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.readonlySigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getCloseGroupV1InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CloseGroupV1] instruction from raw instruction data.
CloseGroupV1InstructionData parseCloseGroupV1Instruction(
  Instruction instruction,
) {
  return getCloseGroupV1InstructionDataDecoder().decode(instruction.data!);
}
