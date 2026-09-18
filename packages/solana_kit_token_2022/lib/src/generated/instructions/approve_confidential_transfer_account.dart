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
class ApproveConfidentialTransferAccountInstructionData {
  const ApproveConfidentialTransferAccountInstructionData()
    : discriminator = 27,
      confidentialTransferDiscriminator = 3;

  final int discriminator;
  final int confidentialTransferDiscriminator;
}

Encoder<ApproveConfidentialTransferAccountInstructionData>
getApproveConfidentialTransferAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ApproveConfidentialTransferAccountInstructionData value) =>
        <String, Object?>{
          'discriminator': 27,
          'confidentialTransferDiscriminator': 3,
        },
  );
}

Decoder<ApproveConfidentialTransferAccountInstructionData>
getApproveConfidentialTransferAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'approveConfidentialTransferAccount instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ApproveConfidentialTransferAccountInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(27),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(3),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ApproveConfidentialTransferAccountInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ApproveConfidentialTransferAccountInstructionData>(
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
      VariableSizeDecoder<ApproveConfidentialTransferAccountInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  ApproveConfidentialTransferAccountInstructionData,
  ApproveConfidentialTransferAccountInstructionData
>
getApproveConfidentialTransferAccountInstructionDataCodec() {
  return combineCodec(
    getApproveConfidentialTransferAccountInstructionDataEncoder(),
    getApproveConfidentialTransferAccountInstructionDataDecoder(),
  );
}

/// Creates a [ApproveConfidentialTransferAccount] instruction.
Instruction getApproveConfidentialTransferAccountInstruction({
  required Address programAddress,
  required Address token,
  required Address mint,
  required Address authority,
}) {
  final instructionData = ApproveConfidentialTransferAccountInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getApproveConfidentialTransferAccountInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ApproveConfidentialTransferAccount] instruction from raw instruction data.
ApproveConfidentialTransferAccountInstructionData
parseApproveConfidentialTransferAccountInstruction(Instruction instruction) {
  return getApproveConfidentialTransferAccountInstructionDataDecoder().decode(
    instruction.data!,
  );
}
