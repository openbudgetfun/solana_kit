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
class DisableConfidentialCreditsInstructionData {
  const DisableConfidentialCreditsInstructionData()
    : discriminator = 27,
      confidentialTransferDiscriminator = 10;

  final int discriminator;
  final int confidentialTransferDiscriminator;
}

Encoder<DisableConfidentialCreditsInstructionData>
getDisableConfidentialCreditsInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DisableConfidentialCreditsInstructionData value) => <String, Object?>{
      'discriminator': 27,
      'confidentialTransferDiscriminator': 10,
    },
  );
}

Decoder<DisableConfidentialCreditsInstructionData>
getDisableConfidentialCreditsInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'disableConfidentialCredits instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (DisableConfidentialCreditsInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(27),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(10),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      DisableConfidentialCreditsInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<DisableConfidentialCreditsInstructionData>(
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
      VariableSizeDecoder<DisableConfidentialCreditsInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  DisableConfidentialCreditsInstructionData,
  DisableConfidentialCreditsInstructionData
>
getDisableConfidentialCreditsInstructionDataCodec() {
  return combineCodec(
    getDisableConfidentialCreditsInstructionDataEncoder(),
    getDisableConfidentialCreditsInstructionDataDecoder(),
  );
}

/// Creates a [DisableConfidentialCredits] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getDisableConfidentialCreditsInstruction({
  required Address programAddress,
  required Address token,
  required Address authority,

  bool authorityIsSigner = true,
}) {
  final instructionData = DisableConfidentialCreditsInstructionData();

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
    data: getDisableConfidentialCreditsInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [DisableConfidentialCredits] instruction from raw instruction data.
DisableConfidentialCreditsInstructionData
parseDisableConfidentialCreditsInstruction(Instruction instruction) {
  return getDisableConfidentialCreditsInstructionDataDecoder().decode(
    instruction.data!,
  );
}
