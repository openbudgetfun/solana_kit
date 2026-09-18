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
class EnableHarvestToMintInstructionData {
  const EnableHarvestToMintInstructionData()
    : discriminator = 37,
      confidentialTransferFeeDiscriminator = 4;

  final int discriminator;
  final int confidentialTransferFeeDiscriminator;
}

Encoder<EnableHarvestToMintInstructionData>
getEnableHarvestToMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferFeeDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (EnableHarvestToMintInstructionData value) => <String, Object?>{
      'discriminator': 37,
      'confidentialTransferFeeDiscriminator': 4,
    },
  );
}

Decoder<EnableHarvestToMintInstructionData>
getEnableHarvestToMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferFeeDiscriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'enableHarvestToMint instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (EnableHarvestToMintInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(37),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(4),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      EnableHarvestToMintInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<EnableHarvestToMintInstructionData>(
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
      VariableSizeDecoder<EnableHarvestToMintInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<EnableHarvestToMintInstructionData, EnableHarvestToMintInstructionData>
getEnableHarvestToMintInstructionDataCodec() {
  return combineCodec(
    getEnableHarvestToMintInstructionDataEncoder(),
    getEnableHarvestToMintInstructionDataDecoder(),
  );
}

/// Creates a [EnableHarvestToMint] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getEnableHarvestToMintInstruction({
  required Address programAddress,
  required Address mint,
  required Address authority,

  bool authorityIsSigner = true,
}) {
  final instructionData = EnableHarvestToMintInstructionData();

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
    data: getEnableHarvestToMintInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [EnableHarvestToMint] instruction from raw instruction data.
EnableHarvestToMintInstructionData parseEnableHarvestToMintInstruction(
  Instruction instruction,
) {
  return getEnableHarvestToMintInstructionDataDecoder().decode(
    instruction.data!,
  );
}
