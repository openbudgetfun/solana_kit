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
class InitializePoolInstructionData {
  const InitializePoolInstructionData({
    this.discriminator = 0,
    required this.rewardRate,
    required this.minStakeDuration,
    required this.maxStakers,
  });

  final int discriminator;
  final BigInt rewardRate;
  final BigInt minStakeDuration;
  final int maxStakers;
}

Encoder<InitializePoolInstructionData> getInitializePoolInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('rewardRate', getU64Encoder()),
    ('minStakeDuration', getI64Encoder()),
    ('maxStakers', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializePoolInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'rewardRate': value.rewardRate,
      'minStakeDuration': value.minStakeDuration,
      'maxStakers': value.maxStakers,
    },
  );
}

Decoder<InitializePoolInstructionData> getInitializePoolInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('rewardRate', getU64Decoder()),
    ('minStakeDuration', getI64Decoder()),
    ('maxStakers', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializePoolInstructionData(
      discriminator: map['discriminator']! as int,
      rewardRate: map['rewardRate']! as BigInt,
      minStakeDuration: map['minStakeDuration']! as BigInt,
      maxStakers: map['maxStakers']! as int,
    ),
  );
}

Codec<InitializePoolInstructionData, InitializePoolInstructionData> getInitializePoolInstructionDataCodec() {
  return combineCodec(getInitializePoolInstructionDataEncoder(), getInitializePoolInstructionDataDecoder());
}

/// Creates a [InitializePool] instruction.
Instruction getInitializePoolInstruction({
  required Address programAddress,
  required Address pool,
  required Address admin,
  required Address rewardMint,
  required Address stakeMint,
  required Address systemProgram,
  required BigInt rewardRate,
  required BigInt minStakeDuration,
  required int maxStakers,
}) {
  final data = InitializePoolInstructionData(
      rewardRate: rewardRate,
      minStakeDuration: minStakeDuration,
      maxStakers: maxStakers,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: pool, role: AccountRole.writable),
    AccountMeta(address: admin, role: AccountRole.writableSigner),
    AccountMeta(address: rewardMint, role: AccountRole.readonly),
    AccountMeta(address: stakeMint, role: AccountRole.readonly),
    AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getInitializePoolInstructionDataEncoder().encode(data),
  );
}

/// Parses a [InitializePool] instruction from raw instruction data.
InitializePoolInstructionData parseInitializePoolInstruction(Instruction instruction) {
  return getInitializePoolInstructionDataDecoder().decode(instruction.data!);
}
