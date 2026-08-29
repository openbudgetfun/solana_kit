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
class ApproveUseAuthorityInstructionData {
  const ApproveUseAuthorityInstructionData({
    required this.numberOfUses,
  }) : discriminator = 20;

  final int discriminator;
  final BigInt numberOfUses;
}

Encoder<ApproveUseAuthorityInstructionData>
getApproveUseAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('numberOfUses', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ApproveUseAuthorityInstructionData value) => <String, Object?>{
      'discriminator': 20,
      'numberOfUses': value.numberOfUses,
    },
  );
}

Decoder<ApproveUseAuthorityInstructionData>
getApproveUseAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('numberOfUses', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'approveUseAuthority instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ApproveUseAuthorityInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(20),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ApproveUseAuthorityInstructionData(
        numberOfUses: map['numberOfUses']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ApproveUseAuthorityInstructionData>(
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
      VariableSizeDecoder<ApproveUseAuthorityInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ApproveUseAuthorityInstructionData, ApproveUseAuthorityInstructionData>
getApproveUseAuthorityInstructionDataCodec() {
  return combineCodec(
    getApproveUseAuthorityInstructionDataEncoder(),
    getApproveUseAuthorityInstructionDataDecoder(),
  );
}

/// Creates a [ApproveUseAuthority] instruction.
Instruction getApproveUseAuthorityInstruction({
  required Address programAddress,
  required Address useAuthorityRecord,
  required Address owner,
  required Address payer,
  required Address user,
  required Address ownerTokenAccount,
  required Address metadata,
  required Address mint,
  required Address burner,
  required Address tokenProgram,
  required Address systemProgram,
  Address? rent,
  required BigInt numberOfUses,
}) {
  final instructionData = ApproveUseAuthorityInstructionData(
    numberOfUses: numberOfUses,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: useAuthorityRecord, role: AccountRole.writable),
      AccountMeta(address: owner, role: AccountRole.writableSigner),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: user, role: AccountRole.readonly),
      AccountMeta(address: ownerTokenAccount, role: AccountRole.writable),
      AccountMeta(address: metadata, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: burner, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      if (rent != null) AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getApproveUseAuthorityInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ApproveUseAuthority] instruction from raw instruction data.
ApproveUseAuthorityInstructionData parseApproveUseAuthorityInstruction(
  Instruction instruction,
) {
  return getApproveUseAuthorityInstructionDataDecoder().decode(
    instruction.data!,
  );
}
