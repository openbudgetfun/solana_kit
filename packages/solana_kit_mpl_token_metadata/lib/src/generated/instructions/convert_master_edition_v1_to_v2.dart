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
class ConvertMasterEditionV1ToV2InstructionData {
  const ConvertMasterEditionV1ToV2InstructionData() : discriminator = 12;

  final int discriminator;
}

Encoder<ConvertMasterEditionV1ToV2InstructionData>
getConvertMasterEditionV1ToV2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ConvertMasterEditionV1ToV2InstructionData value) => <String, Object?>{
      'discriminator': 12,
    },
  );
}

Decoder<ConvertMasterEditionV1ToV2InstructionData>
getConvertMasterEditionV1ToV2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'convertMasterEditionV1ToV2 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ConvertMasterEditionV1ToV2InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(12),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ConvertMasterEditionV1ToV2InstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ConvertMasterEditionV1ToV2InstructionData>(
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
      VariableSizeDecoder<ConvertMasterEditionV1ToV2InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  ConvertMasterEditionV1ToV2InstructionData,
  ConvertMasterEditionV1ToV2InstructionData
>
getConvertMasterEditionV1ToV2InstructionDataCodec() {
  return combineCodec(
    getConvertMasterEditionV1ToV2InstructionDataEncoder(),
    getConvertMasterEditionV1ToV2InstructionDataDecoder(),
  );
}

/// Creates a [ConvertMasterEditionV1ToV2] instruction.
Instruction getConvertMasterEditionV1ToV2Instruction({
  required Address programAddress,
  required Address masterEdition,
  required Address oneTimeAuth,
  required Address printingMint,
}) {
  final instructionData = ConvertMasterEditionV1ToV2InstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: masterEdition, role: AccountRole.writable),
      AccountMeta(address: oneTimeAuth, role: AccountRole.writable),
      AccountMeta(address: printingMint, role: AccountRole.writable),
    ],
    data: getConvertMasterEditionV1ToV2InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ConvertMasterEditionV1ToV2] instruction from raw instruction data.
ConvertMasterEditionV1ToV2InstructionData
parseConvertMasterEditionV1ToV2Instruction(Instruction instruction) {
  return getConvertMasterEditionV1ToV2InstructionDataDecoder().decode(
    instruction.data!,
  );
}
