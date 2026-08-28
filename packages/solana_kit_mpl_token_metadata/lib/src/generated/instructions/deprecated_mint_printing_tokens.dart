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
class DeprecatedMintPrintingTokensInstructionData {
  const DeprecatedMintPrintingTokensInstructionData() : discriminator = 9;

  final int discriminator;
}

Encoder<DeprecatedMintPrintingTokensInstructionData>
getDeprecatedMintPrintingTokensInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DeprecatedMintPrintingTokensInstructionData value) => <String, Object?>{
      'discriminator': 9,
    },
  );
}

Decoder<DeprecatedMintPrintingTokensInstructionData>
getDeprecatedMintPrintingTokensInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'deprecatedMintPrintingTokens instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (DeprecatedMintPrintingTokensInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(9),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      DeprecatedMintPrintingTokensInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<DeprecatedMintPrintingTokensInstructionData>(
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
      VariableSizeDecoder<DeprecatedMintPrintingTokensInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  DeprecatedMintPrintingTokensInstructionData,
  DeprecatedMintPrintingTokensInstructionData
>
getDeprecatedMintPrintingTokensInstructionDataCodec() {
  return combineCodec(
    getDeprecatedMintPrintingTokensInstructionDataEncoder(),
    getDeprecatedMintPrintingTokensInstructionDataDecoder(),
  );
}

/// Creates a [DeprecatedMintPrintingTokens] instruction.
Instruction getDeprecatedMintPrintingTokensInstruction({
  required Address programAddress,
  required Address destination,
  required Address printingMint,
  required Address updateAuthority,
  required Address metadata,
  required Address masterEdition,
  required Address tokenProgram,
  required Address rent,
}) {
  final instructionData = DeprecatedMintPrintingTokensInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: destination, role: AccountRole.writable),
      AccountMeta(address: printingMint, role: AccountRole.writable),
      AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: metadata, role: AccountRole.readonly),
      AccountMeta(address: masterEdition, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getDeprecatedMintPrintingTokensInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [DeprecatedMintPrintingTokens] instruction from raw instruction data.
DeprecatedMintPrintingTokensInstructionData
parseDeprecatedMintPrintingTokensInstruction(Instruction instruction) {
  return getDeprecatedMintPrintingTokensInstructionDataDecoder().decode(
    instruction.data!,
  );
}
