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
class EnableNonConfidentialCreditsInstructionData {
  const EnableNonConfidentialCreditsInstructionData()
    : discriminator = 27,
      confidentialTransferDiscriminator = 11;

  final int discriminator;
  final int confidentialTransferDiscriminator;
}

Encoder<EnableNonConfidentialCreditsInstructionData>
getEnableNonConfidentialCreditsInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (EnableNonConfidentialCreditsInstructionData value) => <String, Object?>{
      'discriminator': 27,
      'confidentialTransferDiscriminator': 11,
    },
  );
}

Decoder<EnableNonConfidentialCreditsInstructionData>
getEnableNonConfidentialCreditsInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'enableNonConfidentialCredits instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (EnableNonConfidentialCreditsInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(27),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(11),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      EnableNonConfidentialCreditsInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<EnableNonConfidentialCreditsInstructionData>(
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
      VariableSizeDecoder<EnableNonConfidentialCreditsInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  EnableNonConfidentialCreditsInstructionData,
  EnableNonConfidentialCreditsInstructionData
>
getEnableNonConfidentialCreditsInstructionDataCodec() {
  return combineCodec(
    getEnableNonConfidentialCreditsInstructionDataEncoder(),
    getEnableNonConfidentialCreditsInstructionDataDecoder(),
  );
}

/// Creates a [EnableNonConfidentialCredits] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getEnableNonConfidentialCreditsInstruction({
  required Address programAddress,
  required Address token,
  required Address authority,

  bool authorityIsSigner = true,
}) {
  final instructionData = EnableNonConfidentialCreditsInstructionData();

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
    data: getEnableNonConfidentialCreditsInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [EnableNonConfidentialCredits] instruction from raw instruction data.
EnableNonConfidentialCreditsInstructionData
parseEnableNonConfidentialCreditsInstruction(Instruction instruction) {
  return getEnableNonConfidentialCreditsInstructionDataDecoder().decode(
    instruction.data!,
  );
}
