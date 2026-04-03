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
class WithdrawNonceAccountInstructionData {
  const WithdrawNonceAccountInstructionData({
    this.discriminator = 5,
    required this.withdrawAmount,
  });

  final int discriminator;
  final BigInt withdrawAmount;
}

Encoder<WithdrawNonceAccountInstructionData> getWithdrawNonceAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('withdrawAmount', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (WithdrawNonceAccountInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'withdrawAmount': value.withdrawAmount,
    },
  );
}

Decoder<WithdrawNonceAccountInstructionData> getWithdrawNonceAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('withdrawAmount', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => WithdrawNonceAccountInstructionData(
      discriminator: map['discriminator']! as int,
      withdrawAmount: map['withdrawAmount']! as BigInt,
    ),
  );
}

Codec<WithdrawNonceAccountInstructionData, WithdrawNonceAccountInstructionData> getWithdrawNonceAccountInstructionDataCodec() {
  return combineCodec(getWithdrawNonceAccountInstructionDataEncoder(), getWithdrawNonceAccountInstructionDataDecoder());
}

/// Creates a [WithdrawNonceAccount] instruction.
Instruction getWithdrawNonceAccountInstruction({
  required Address programAddress,
  required Address nonceAccount,
  required Address recipientAccount,
  required Address recentBlockhashesSysvar,
  required Address rentSysvar,
  required Address nonceAuthority,
  required BigInt withdrawAmount,
}) {
  final instructionData = WithdrawNonceAccountInstructionData(
      withdrawAmount: withdrawAmount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: nonceAccount, role: AccountRole.writable),
    AccountMeta(address: recipientAccount, role: AccountRole.writable),
    AccountMeta(address: recentBlockhashesSysvar, role: AccountRole.readonly),
    AccountMeta(address: rentSysvar, role: AccountRole.readonly),
    AccountMeta(address: nonceAuthority, role: AccountRole.readonlySigner),
    ],
    data: getWithdrawNonceAccountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [WithdrawNonceAccount] instruction from raw instruction data.
WithdrawNonceAccountInstructionData parseWithdrawNonceAccountInstruction(Instruction instruction) {
  return getWithdrawNonceAccountInstructionDataDecoder().decode(instruction.data!);
}
