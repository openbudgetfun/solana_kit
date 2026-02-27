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
  const WithdrawInstructionData({
    this.discriminator = 2,
    required this.amount,
  });

  final int discriminator;
  final BigInt amount;
}

Encoder<WithdrawInstructionData> getWithdrawInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (WithdrawInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'amount': value.amount,
    },
  );
}

Decoder<WithdrawInstructionData> getWithdrawInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => WithdrawInstructionData(
      discriminator: map['discriminator']! as int,
      amount: map['amount']! as BigInt,
    ),
  );
}

Codec<WithdrawInstructionData, WithdrawInstructionData> getWithdrawInstructionDataCodec() {
  return combineCodec(getWithdrawInstructionDataEncoder(), getWithdrawInstructionDataDecoder());
}

/// Creates a [Withdraw] instruction.
Instruction getWithdrawInstruction({
  required Address programAddress,
  required Address vault,
  required Address authority,
  required Address vaultTokenAccount,
  required Address destinationTokenAccount,
  required Address tokenProgram,
  required BigInt amount,
}) {
  final data = WithdrawInstructionData(
      amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: vault, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    AccountMeta(address: vaultTokenAccount, role: AccountRole.writable),
    AccountMeta(address: destinationTokenAccount, role: AccountRole.writable),
    AccountMeta(address: tokenProgram, role: AccountRole.readonly),
    ],
    data: getWithdrawInstructionDataEncoder().encode(data),
  );
}

/// Parses a [Withdraw] instruction from raw instruction data.
WithdrawInstructionData parseWithdrawInstruction(Instruction instruction) {
  return getWithdrawInstructionDataDecoder().decode(instruction.data!);
}
