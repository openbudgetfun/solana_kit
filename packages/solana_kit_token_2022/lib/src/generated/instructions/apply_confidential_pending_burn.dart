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

/// The discriminator field name: 'confidentialMintBurnDiscriminator'.
/// Offset: 1.

@immutable
class ApplyConfidentialPendingBurnInstructionData {
  const ApplyConfidentialPendingBurnInstructionData()
    : discriminator = 42,
      confidentialMintBurnDiscriminator = 5;

  final int discriminator;
  final int confidentialMintBurnDiscriminator;
}

Encoder<ApplyConfidentialPendingBurnInstructionData>
getApplyConfidentialPendingBurnInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialMintBurnDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ApplyConfidentialPendingBurnInstructionData value) => <String, Object?>{
      'discriminator': 42,
      'confidentialMintBurnDiscriminator': 5,
    },
  );
}

Decoder<ApplyConfidentialPendingBurnInstructionData>
getApplyConfidentialPendingBurnInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialMintBurnDiscriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'applyConfidentialPendingBurn instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ApplyConfidentialPendingBurnInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(42),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(5),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ApplyConfidentialPendingBurnInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ApplyConfidentialPendingBurnInstructionData>(
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
      VariableSizeDecoder<ApplyConfidentialPendingBurnInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  ApplyConfidentialPendingBurnInstructionData,
  ApplyConfidentialPendingBurnInstructionData
>
getApplyConfidentialPendingBurnInstructionDataCodec() {
  return combineCodec(
    getApplyConfidentialPendingBurnInstructionDataEncoder(),
    getApplyConfidentialPendingBurnInstructionDataDecoder(),
  );
}

/// Creates a [ApplyConfidentialPendingBurn] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getApplyConfidentialPendingBurnInstruction({
  required Address programAddress,
  required Address mint,
  required Address authority,

  bool authorityIsSigner = true,
}) {
  final instructionData = ApplyConfidentialPendingBurnInstructionData();

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
    data: getApplyConfidentialPendingBurnInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ApplyConfidentialPendingBurn] instruction from raw instruction data.
ApplyConfidentialPendingBurnInstructionData
parseApplyConfidentialPendingBurnInstruction(Instruction instruction) {
  return getApplyConfidentialPendingBurnInstructionDataDecoder().decode(
    instruction.data!,
  );
}
