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
class UnstakeInstructionData {
  const UnstakeInstructionData({
    this.discriminator = 2,
  });

  final int discriminator;
}

Encoder<UnstakeInstructionData> getUnstakeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UnstakeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<UnstakeInstructionData> getUnstakeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UnstakeInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<UnstakeInstructionData, UnstakeInstructionData> getUnstakeInstructionDataCodec() {
  return combineCodec(getUnstakeInstructionDataEncoder(), getUnstakeInstructionDataDecoder());
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
  final data = UnstakeInstructionData(

  );

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
    data: getUnstakeInstructionDataEncoder().encode(data),
  );
}

/// Parses a [Unstake] instruction from raw instruction data.
UnstakeInstructionData parseUnstakeInstruction(Instruction instruction) {
  return getUnstakeInstructionDataDecoder().decode(instruction.data!);
}
