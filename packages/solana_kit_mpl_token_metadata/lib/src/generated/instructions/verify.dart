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

import '../types/verification_args.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class VerifyInstructionData {
  const VerifyInstructionData({
    required this.verificationArgs,
  }) : discriminator = 52;

  final int discriminator;
  final VerificationArgs verificationArgs;
}

Encoder<VerifyInstructionData> getVerifyInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('verificationArgs', getVerificationArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (VerifyInstructionData value) => <String, Object?>{
      'discriminator': 52,
      'verificationArgs': value.verificationArgs,
    },
  );
}

Decoder<VerifyInstructionData> getVerifyInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('verificationArgs', getVerificationArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'verify instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (VerifyInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(52),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      VerifyInstructionData(
        verificationArgs: map['verificationArgs']! as VerificationArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<VerifyInstructionData>(
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
      VariableSizeDecoder<VerifyInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<VerifyInstructionData, VerifyInstructionData>
getVerifyInstructionDataCodec() {
  return combineCodec(
    getVerifyInstructionDataEncoder(),
    getVerifyInstructionDataDecoder(),
  );
}

/// Creates a [Verify] instruction.
Instruction getVerifyInstruction({
  required Address programAddress,
  required Address authority,
  Address? delegateRecord,
  required Address metadata,
  Address? collectionMint,
  Address? collectionMetadata,
  Address? collectionMasterEdition,
  required Address systemProgram,
  required Address sysvarInstructions,
  required VerificationArgs verificationArgs,
}) {
  final instructionData = VerifyInstructionData(
    verificationArgs: verificationArgs,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      if (delegateRecord != null)
        AccountMeta(address: delegateRecord, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: metadata, role: AccountRole.writable),
      if (collectionMint != null)
        AccountMeta(address: collectionMint, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (collectionMetadata != null)
        AccountMeta(address: collectionMetadata, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (collectionMasterEdition != null)
        AccountMeta(
          address: collectionMasterEdition,
          role: AccountRole.readonly,
        )
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: sysvarInstructions, role: AccountRole.readonly),
    ],
    data: getVerifyInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Verify] instruction from raw instruction data.
VerifyInstructionData parseVerifyInstruction(Instruction instruction) {
  return getVerifyInstructionDataDecoder().decode(instruction.data!);
}
