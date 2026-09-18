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
class EmptyConfidentialTransferAccountInstructionData {
  const EmptyConfidentialTransferAccountInstructionData({
    required this.proofInstructionOffset,
  }) : discriminator = 27,
       confidentialTransferDiscriminator = 4;

  final int discriminator;
  final int confidentialTransferDiscriminator;
  final int proofInstructionOffset;
}

Encoder<EmptyConfidentialTransferAccountInstructionData>
getEmptyConfidentialTransferAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
    ('proofInstructionOffset', getI8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (EmptyConfidentialTransferAccountInstructionData value) =>
        <String, Object?>{
          'discriminator': 27,
          'confidentialTransferDiscriminator': 4,
          'proofInstructionOffset': value.proofInstructionOffset,
        },
  );
}

Decoder<EmptyConfidentialTransferAccountInstructionData>
getEmptyConfidentialTransferAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
    ('proofInstructionOffset', getI8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'emptyConfidentialTransferAccount instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (EmptyConfidentialTransferAccountInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(27),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(4),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      EmptyConfidentialTransferAccountInstructionData(
        proofInstructionOffset: map['proofInstructionOffset']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<EmptyConfidentialTransferAccountInstructionData>(
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
      VariableSizeDecoder<EmptyConfidentialTransferAccountInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  EmptyConfidentialTransferAccountInstructionData,
  EmptyConfidentialTransferAccountInstructionData
>
getEmptyConfidentialTransferAccountInstructionDataCodec() {
  return combineCodec(
    getEmptyConfidentialTransferAccountInstructionDataEncoder(),
    getEmptyConfidentialTransferAccountInstructionDataDecoder(),
  );
}

/// Creates a [EmptyConfidentialTransferAccount] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getEmptyConfidentialTransferAccountInstruction({
  required Address programAddress,
  required Address token,
  required Address instructionsSysvarOrContextState,
  required Address authority,
  required int proofInstructionOffset,
  bool authorityIsSigner = true,
}) {
  final instructionData = EmptyConfidentialTransferAccountInstructionData(
    proofInstructionOffset: proofInstructionOffset,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(
        address: instructionsSysvarOrContextState,
        role: AccountRole.readonly,
      ),
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getEmptyConfidentialTransferAccountInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [EmptyConfidentialTransferAccount] instruction from raw instruction data.
EmptyConfidentialTransferAccountInstructionData
parseEmptyConfidentialTransferAccountInstruction(Instruction instruction) {
  return getEmptyConfidentialTransferAccountInstructionDataDecoder().decode(
    instruction.data!,
  );
}
