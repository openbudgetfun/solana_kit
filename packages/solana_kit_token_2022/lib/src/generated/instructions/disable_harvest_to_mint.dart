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
class DisableHarvestToMintInstructionData {
  const DisableHarvestToMintInstructionData()
    : discriminator = 37,
      confidentialTransferFeeDiscriminator = 5;

  final int discriminator;
  final int confidentialTransferFeeDiscriminator;
}

Encoder<DisableHarvestToMintInstructionData>
getDisableHarvestToMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferFeeDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DisableHarvestToMintInstructionData value) => <String, Object?>{
      'discriminator': 37,
      'confidentialTransferFeeDiscriminator': 5,
    },
  );
}

Decoder<DisableHarvestToMintInstructionData>
getDisableHarvestToMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferFeeDiscriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'disableHarvestToMint instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (DisableHarvestToMintInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(37),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(5),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      DisableHarvestToMintInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<DisableHarvestToMintInstructionData>(
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
      VariableSizeDecoder<DisableHarvestToMintInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<DisableHarvestToMintInstructionData, DisableHarvestToMintInstructionData>
getDisableHarvestToMintInstructionDataCodec() {
  return combineCodec(
    getDisableHarvestToMintInstructionDataEncoder(),
    getDisableHarvestToMintInstructionDataDecoder(),
  );
}

/// Creates a [DisableHarvestToMint] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getDisableHarvestToMintInstruction({
  required Address programAddress,
  required Address mint,
  required Address authority,

  bool authorityIsSigner = true,
}) {
  final instructionData = DisableHarvestToMintInstructionData();

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
    data: getDisableHarvestToMintInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [DisableHarvestToMint] instruction from raw instruction data.
DisableHarvestToMintInstructionData parseDisableHarvestToMintInstruction(
  Instruction instruction,
) {
  return getDisableHarvestToMintInstructionDataDecoder().decode(
    instruction.data!,
  );
}
