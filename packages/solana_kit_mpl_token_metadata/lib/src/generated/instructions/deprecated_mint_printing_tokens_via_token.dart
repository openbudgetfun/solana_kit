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
class DeprecatedMintPrintingTokensViaTokenInstructionData {
  const DeprecatedMintPrintingTokensViaTokenInstructionData()
    : discriminator = 8;

  final int discriminator;
}

Encoder<DeprecatedMintPrintingTokensViaTokenInstructionData>
getDeprecatedMintPrintingTokensViaTokenInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DeprecatedMintPrintingTokensViaTokenInstructionData value) =>
        <String, Object?>{
          'discriminator': 8,
        },
  );
}

Decoder<DeprecatedMintPrintingTokensViaTokenInstructionData>
getDeprecatedMintPrintingTokensViaTokenInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'deprecatedMintPrintingTokensViaToken instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (DeprecatedMintPrintingTokensViaTokenInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(8),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      DeprecatedMintPrintingTokensViaTokenInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<DeprecatedMintPrintingTokensViaTokenInstructionData>(
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
      VariableSizeDecoder<DeprecatedMintPrintingTokensViaTokenInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  DeprecatedMintPrintingTokensViaTokenInstructionData,
  DeprecatedMintPrintingTokensViaTokenInstructionData
>
getDeprecatedMintPrintingTokensViaTokenInstructionDataCodec() {
  return combineCodec(
    getDeprecatedMintPrintingTokensViaTokenInstructionDataEncoder(),
    getDeprecatedMintPrintingTokensViaTokenInstructionDataDecoder(),
  );
}

/// Creates a [DeprecatedMintPrintingTokensViaToken] instruction.
Instruction getDeprecatedMintPrintingTokensViaTokenInstruction({
  required Address programAddress,
  required Address destination,
  required Address token,
  required Address oneTimePrintingAuthorizationMint,
  required Address printingMint,
  required Address burnAuthority,
  required Address metadata,
  required Address masterEdition,
  required Address tokenProgram,
  required Address rent,
}) {
  final instructionData = DeprecatedMintPrintingTokensViaTokenInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: destination, role: AccountRole.writable),
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(
        address: oneTimePrintingAuthorizationMint,
        role: AccountRole.writable,
      ),
      AccountMeta(address: printingMint, role: AccountRole.writable),
      AccountMeta(address: burnAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: metadata, role: AccountRole.readonly),
      AccountMeta(address: masterEdition, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getDeprecatedMintPrintingTokensViaTokenInstructionDataEncoder()
        .encode(instructionData),
  );
}

/// Parses a [DeprecatedMintPrintingTokensViaToken] instruction from raw instruction data.
DeprecatedMintPrintingTokensViaTokenInstructionData
parseDeprecatedMintPrintingTokensViaTokenInstruction(Instruction instruction) {
  return getDeprecatedMintPrintingTokensViaTokenInstructionDataDecoder().decode(
    instruction.data!,
  );
}
