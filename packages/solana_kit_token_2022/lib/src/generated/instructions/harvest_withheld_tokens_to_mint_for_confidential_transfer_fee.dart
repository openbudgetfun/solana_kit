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

/// The discriminator field name: 'confidentialTransferFeeDiscriminator'.
/// Offset: 1.

@immutable
class HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData {
  const HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData()
    : discriminator = 37,
      confidentialTransferFeeDiscriminator = 3;

  final int discriminator;
  final int confidentialTransferFeeDiscriminator;
}

Encoder<HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData>
getHarvestWithheldTokensToMintForConfidentialTransferFeeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferFeeDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (
      HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData
      value,
    ) => <String, Object?>{
      'discriminator': 37,
      'confidentialTransferFeeDiscriminator': 3,
    },
  );
}

Decoder<HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData>
getHarvestWithheldTokensToMintForConfidentialTransferFeeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferFeeDiscriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'harvestWithheldTokensToMintForConfidentialTransferFee instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData, int)
  readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(37),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(3),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<
        HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData
      >(
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
      VariableSizeDecoder<
        HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData
      >(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData,
  HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData
>
getHarvestWithheldTokensToMintForConfidentialTransferFeeInstructionDataCodec() {
  return combineCodec(
    getHarvestWithheldTokensToMintForConfidentialTransferFeeInstructionDataEncoder(),
    getHarvestWithheldTokensToMintForConfidentialTransferFeeInstructionDataDecoder(),
  );
}

/// Creates a [HarvestWithheldTokensToMintForConfidentialTransferFee] instruction.
Instruction
getHarvestWithheldTokensToMintForConfidentialTransferFeeInstruction({
  required Address programAddress,
  required Address mint,
}) {
  final instructionData =
      HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data:
        getHarvestWithheldTokensToMintForConfidentialTransferFeeInstructionDataEncoder()
            .encode(instructionData),
  );
}

/// Parses a [HarvestWithheldTokensToMintForConfidentialTransferFee] instruction from raw instruction data.
HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData
parseHarvestWithheldTokensToMintForConfidentialTransferFeeInstruction(
  Instruction instruction,
) {
  return getHarvestWithheldTokensToMintForConfidentialTransferFeeInstructionDataDecoder()
      .decode(instruction.data!);
}
