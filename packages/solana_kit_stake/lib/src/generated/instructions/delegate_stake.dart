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
class DelegateStakeInstructionData {
  const DelegateStakeInstructionData({this.discriminator = 2});

  final int discriminator;
}

Encoder<DelegateStakeInstructionData> getDelegateStakeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DelegateStakeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<DelegateStakeInstructionData> getDelegateStakeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        DelegateStakeInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

Codec<DelegateStakeInstructionData, DelegateStakeInstructionData>
getDelegateStakeInstructionDataCodec() {
  return combineCodec(
    getDelegateStakeInstructionDataEncoder(),
    getDelegateStakeInstructionDataDecoder(),
  );
}

/// Creates a [DelegateStake] instruction.
Instruction getDelegateStakeInstruction({
  required Address programAddress,
  required Address stake,
  required Address vote,
  required Address clockSysvar,
  required Address stakeHistory,
  required Address unused,
  required Address stakeAuthority,
}) {
  final instructionData = DelegateStakeInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: stake, role: AccountRole.writable),
      AccountMeta(address: vote, role: AccountRole.readonly),
      AccountMeta(address: clockSysvar, role: AccountRole.readonly),
      AccountMeta(address: stakeHistory, role: AccountRole.readonly),
      AccountMeta(address: unused, role: AccountRole.readonly),
      AccountMeta(address: stakeAuthority, role: AccountRole.readonlySigner),
    ],
    data: getDelegateStakeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [DelegateStake] instruction from raw instruction data.
DelegateStakeInstructionData parseDelegateStakeInstruction(
  Instruction instruction,
) {
  return getDelegateStakeInstructionDataDecoder().decode(instruction.data!);
}
