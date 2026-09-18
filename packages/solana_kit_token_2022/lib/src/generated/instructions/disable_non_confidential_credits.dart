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
class DisableNonConfidentialCreditsInstructionData {
  const DisableNonConfidentialCreditsInstructionData()
    : discriminator = 27,
      confidentialTransferDiscriminator = 12;

  final int discriminator;
  final int confidentialTransferDiscriminator;
}

Encoder<DisableNonConfidentialCreditsInstructionData>
getDisableNonConfidentialCreditsInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DisableNonConfidentialCreditsInstructionData value) => <String, Object?>{
      'discriminator': 27,
      'confidentialTransferDiscriminator': 12,
    },
  );
}

Decoder<DisableNonConfidentialCreditsInstructionData>
getDisableNonConfidentialCreditsInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'disableNonConfidentialCredits instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (DisableNonConfidentialCreditsInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(27),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(12),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      DisableNonConfidentialCreditsInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<DisableNonConfidentialCreditsInstructionData>(
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
      VariableSizeDecoder<DisableNonConfidentialCreditsInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  DisableNonConfidentialCreditsInstructionData,
  DisableNonConfidentialCreditsInstructionData
>
getDisableNonConfidentialCreditsInstructionDataCodec() {
  return combineCodec(
    getDisableNonConfidentialCreditsInstructionDataEncoder(),
    getDisableNonConfidentialCreditsInstructionDataDecoder(),
  );
}

/// Creates a [DisableNonConfidentialCredits] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getDisableNonConfidentialCreditsInstruction({
  required Address programAddress,
  required Address token,
  required Address authority,

  bool authorityIsSigner = true,
}) {
  final instructionData = DisableNonConfidentialCreditsInstructionData();

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
    data: getDisableNonConfidentialCreditsInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [DisableNonConfidentialCredits] instruction from raw instruction data.
DisableNonConfidentialCreditsInstructionData
parseDisableNonConfidentialCreditsInstruction(Instruction instruction) {
  return getDisableNonConfidentialCreditsInstructionDataDecoder().decode(
    instruction.data!,
  );
}
