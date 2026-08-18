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
class StakeInstructionData {
  const StakeInstructionData({
    required this.amount,
  }) : discriminator = 1;

  final int discriminator;
  final BigInt amount;
}

Encoder<StakeInstructionData> getStakeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (StakeInstructionData value) => <String, Object?>{
      'discriminator': 1,
      'amount': value.amount,
    },
  );
}

Decoder<StakeInstructionData> getStakeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'stake instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (StakeInstructionData, int) readExact(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(1),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }
    return (
      StakeInstructionData(
        amount: map['amount']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<StakeInstructionData>(
        fixedSize: structDecoder.fixedSize,
        read: (bytes, offset) {
          final bytesLength = bytes.length - offset;
          if (bytesLength != structDecoder.fixedSize) {
            throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
          }
          return readExact(bytes, offset);
        },
      ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<StakeInstructionData>(
        read: readExact,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<StakeInstructionData, StakeInstructionData>
getStakeInstructionDataCodec() {
  return combineCodec(
    getStakeInstructionDataEncoder(),
    getStakeInstructionDataDecoder(),
  );
}

/// Creates a [Stake] instruction.
Instruction getStakeInstruction({
  required Address programAddress,
  required Address pool,
  required Address stakeAccount,
  required Address staker,
  required Address stakerTokenAccount,
  required Address poolTokenAccount,
  required Address tokenProgram,
  required Address systemProgram,
  required BigInt amount,
}) {
  final instructionData = StakeInstructionData(
    amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: pool, role: AccountRole.writable),
      AccountMeta(address: stakeAccount, role: AccountRole.writable),
      AccountMeta(address: staker, role: AccountRole.writableSigner),
      AccountMeta(address: stakerTokenAccount, role: AccountRole.writable),
      AccountMeta(address: poolTokenAccount, role: AccountRole.writable),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getStakeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Stake] instruction from raw instruction data.
StakeInstructionData parseStakeInstruction(Instruction instruction) {
  return getStakeInstructionDataDecoder().decode(instruction.data!);
}
