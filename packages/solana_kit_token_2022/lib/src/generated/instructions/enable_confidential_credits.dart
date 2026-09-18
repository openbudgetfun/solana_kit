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

/// The discriminator field name: 'confidentialTransferDiscriminator'.
/// Offset: 1.

@immutable
class EnableConfidentialCreditsInstructionData {
  const EnableConfidentialCreditsInstructionData()
    : discriminator = 27,
      confidentialTransferDiscriminator = 9;

  final int discriminator;
  final int confidentialTransferDiscriminator;
}

Encoder<EnableConfidentialCreditsInstructionData>
getEnableConfidentialCreditsInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (EnableConfidentialCreditsInstructionData value) => <String, Object?>{
      'discriminator': 27,
      'confidentialTransferDiscriminator': 9,
    },
  );
}

Decoder<EnableConfidentialCreditsInstructionData>
getEnableConfidentialCreditsInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'enableConfidentialCredits instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (EnableConfidentialCreditsInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(27),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(9),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      EnableConfidentialCreditsInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<EnableConfidentialCreditsInstructionData>(
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
      VariableSizeDecoder<EnableConfidentialCreditsInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  EnableConfidentialCreditsInstructionData,
  EnableConfidentialCreditsInstructionData
>
getEnableConfidentialCreditsInstructionDataCodec() {
  return combineCodec(
    getEnableConfidentialCreditsInstructionDataEncoder(),
    getEnableConfidentialCreditsInstructionDataDecoder(),
  );
}

/// Creates a [EnableConfidentialCredits] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getEnableConfidentialCreditsInstruction({
  required Address programAddress,
  required Address token,
  required Address authority,

  bool authorityIsSigner = true,
}) {
  final instructionData = EnableConfidentialCreditsInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getEnableConfidentialCreditsInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [EnableConfidentialCredits] instruction from raw instruction data.
EnableConfidentialCreditsInstructionData
parseEnableConfidentialCreditsInstruction(Instruction instruction) {
  return getEnableConfidentialCreditsInstructionDataDecoder().decode(
    instruction.data!,
  );
}
