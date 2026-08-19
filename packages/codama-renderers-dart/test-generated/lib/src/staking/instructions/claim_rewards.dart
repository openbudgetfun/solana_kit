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
class ClaimRewardsInstructionData {
  const ClaimRewardsInstructionData() : discriminator = 3;

  final int discriminator;
}

Encoder<ClaimRewardsInstructionData> getClaimRewardsInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ClaimRewardsInstructionData value) => <String, Object?>{
      'discriminator': 3,
    },
  );
}

Decoder<ClaimRewardsInstructionData> getClaimRewardsInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'claimRewards instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ClaimRewardsInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(3),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ClaimRewardsInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ClaimRewardsInstructionData>(
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
      VariableSizeDecoder<ClaimRewardsInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ClaimRewardsInstructionData, ClaimRewardsInstructionData>
getClaimRewardsInstructionDataCodec() {
  return combineCodec(
    getClaimRewardsInstructionDataEncoder(),
    getClaimRewardsInstructionDataDecoder(),
  );
}

/// Creates a [ClaimRewards] instruction.
Instruction getClaimRewardsInstruction({
  required Address programAddress,
  required Address pool,
  required Address stakeAccount,
  required Address staker,
  required Address rewardTokenAccount,
  required Address rewardVault,
  required Address tokenProgram,
}) {
  final instructionData = ClaimRewardsInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: pool, role: AccountRole.writable),
      AccountMeta(address: stakeAccount, role: AccountRole.writable),
      AccountMeta(address: staker, role: AccountRole.readonlySigner),
      AccountMeta(address: rewardTokenAccount, role: AccountRole.writable),
      AccountMeta(address: rewardVault, role: AccountRole.writable),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
    ],
    data: getClaimRewardsInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ClaimRewards] instruction from raw instruction data.
ClaimRewardsInstructionData parseClaimRewardsInstruction(
  Instruction instruction,
) {
  return getClaimRewardsInstructionDataDecoder().decode(instruction.data!);
}
