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
class WithdrawInstructionData {
  const WithdrawInstructionData({this.discriminator = 4, required this.args});

  final int discriminator;
  final BigInt args;
}

Encoder<WithdrawInstructionData> getWithdrawInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('args', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (WithdrawInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'args': value.args,
    },
  );
}

Decoder<WithdrawInstructionData> getWithdrawInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('args', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        WithdrawInstructionData(
          discriminator: map['discriminator']! as int,
          args: map['args']! as BigInt,
        ),
  );
}

Codec<WithdrawInstructionData, WithdrawInstructionData>
getWithdrawInstructionDataCodec() {
  return combineCodec(
    getWithdrawInstructionDataEncoder(),
    getWithdrawInstructionDataDecoder(),
  );
}

/// Creates a [Withdraw] instruction.
Instruction getWithdrawInstruction({
  required Address programAddress,
  required Address stake,
  required Address recipient,
  required Address clockSysvar,
  required Address stakeHistory,
  required Address withdrawAuthority,
  Address? lockupAuthority,
  required BigInt args,
}) {
  final instructionData = WithdrawInstructionData(args: args);

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: stake, role: AccountRole.writable),
      AccountMeta(address: recipient, role: AccountRole.writable),
      AccountMeta(address: clockSysvar, role: AccountRole.readonly),
      AccountMeta(address: stakeHistory, role: AccountRole.readonly),
      AccountMeta(address: withdrawAuthority, role: AccountRole.readonlySigner),
      if (lockupAuthority != null)
        AccountMeta(address: lockupAuthority, role: AccountRole.readonlySigner),
    ],
    data: getWithdrawInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Withdraw] instruction from raw instruction data.
WithdrawInstructionData parseWithdrawInstruction(Instruction instruction) {
  return getWithdrawInstructionDataDecoder().decode(instruction.data!);
}
