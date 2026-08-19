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
class UnstakeInstructionData {
  const UnstakeInstructionData() : discriminator = 2;

  final int discriminator;
}

Encoder<UnstakeInstructionData> getUnstakeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UnstakeInstructionData value) => <String, Object?>{
      'discriminator': 2,
    },
  );
}

Decoder<UnstakeInstructionData> getUnstakeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'unstake instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UnstakeInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(2),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UnstakeInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UnstakeInstructionData>(
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
      VariableSizeDecoder<UnstakeInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<UnstakeInstructionData, UnstakeInstructionData>
getUnstakeInstructionDataCodec() {
  return combineCodec(
    getUnstakeInstructionDataEncoder(),
    getUnstakeInstructionDataDecoder(),
  );
}

/// Creates a [Unstake] instruction.
Instruction getUnstakeInstruction({
  required Address programAddress,
  required Address pool,
  required Address stakeAccount,
  required Address staker,
  required Address poolTokenAccount,
  required Address stakerTokenAccount,
  required Address tokenProgram,
}) {
  final instructionData = UnstakeInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: pool, role: AccountRole.writable),
      AccountMeta(address: stakeAccount, role: AccountRole.writable),
      AccountMeta(address: staker, role: AccountRole.writableSigner),
      AccountMeta(address: poolTokenAccount, role: AccountRole.writable),
      AccountMeta(address: stakerTokenAccount, role: AccountRole.writable),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
    ],
    data: getUnstakeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Unstake] instruction from raw instruction data.
UnstakeInstructionData parseUnstakeInstruction(Instruction instruction) {
  return getUnstakeInstructionDataDecoder().decode(instruction.data!);
}
