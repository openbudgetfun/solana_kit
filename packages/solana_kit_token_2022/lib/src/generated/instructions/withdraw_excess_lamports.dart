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
class WithdrawExcessLamportsInstructionData {
  const WithdrawExcessLamportsInstructionData({
    this.discriminator = 38,
  });

  final int discriminator;
}

Encoder<WithdrawExcessLamportsInstructionData> getWithdrawExcessLamportsInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (WithdrawExcessLamportsInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<WithdrawExcessLamportsInstructionData> getWithdrawExcessLamportsInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => WithdrawExcessLamportsInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<WithdrawExcessLamportsInstructionData, WithdrawExcessLamportsInstructionData> getWithdrawExcessLamportsInstructionDataCodec() {
  return combineCodec(getWithdrawExcessLamportsInstructionDataEncoder(), getWithdrawExcessLamportsInstructionDataDecoder());
}

/// Creates a [WithdrawExcessLamports] instruction.
Instruction getWithdrawExcessLamportsInstruction({
  required Address programAddress,
  required Address sourceAccount,
  required Address destinationAccount,
  required Address authority,

}) {
  final instructionData = WithdrawExcessLamportsInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: sourceAccount, role: AccountRole.writable),
    AccountMeta(address: destinationAccount, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getWithdrawExcessLamportsInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [WithdrawExcessLamports] instruction from raw instruction data.
WithdrawExcessLamportsInstructionData parseWithdrawExcessLamportsInstruction(Instruction instruction) {
  return getWithdrawExcessLamportsInstructionDataDecoder().decode(instruction.data!);
}
