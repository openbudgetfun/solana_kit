// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class StakeInstructionData {
  const StakeInstructionData({
    this.discriminator = 1,
    required this.amount,
  });

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
      'discriminator': value.discriminator,
      'amount': value.amount,
    },
  );
}

Decoder<StakeInstructionData> getStakeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => StakeInstructionData(
      discriminator: map['discriminator']! as int,
      amount: map['amount']! as BigInt,
    ),
  );
}

Codec<StakeInstructionData, StakeInstructionData> getStakeInstructionDataCodec() {
  return combineCodec(getStakeInstructionDataEncoder(), getStakeInstructionDataDecoder());
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
  final data = StakeInstructionData(
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
    data: getStakeInstructionDataEncoder().encode(data),
  );
}

/// Parses a [Stake] instruction from raw instruction data.
StakeInstructionData parseStakeInstruction(Instruction instruction) {
  return getStakeInstructionDataDecoder().decode(instruction.data!);
}
