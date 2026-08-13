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
class BurnInstructionData {
  const BurnInstructionData({
    this.discriminator = 8,
    required this.amount,
  });

  final int discriminator;
  final BigInt amount;
}

Encoder<BurnInstructionData> getBurnInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (BurnInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'amount': value.amount,
    },
  );
}

Decoder<BurnInstructionData> getBurnInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => BurnInstructionData(
      discriminator: map['discriminator']! as int,
      amount: map['amount']! as BigInt,
    ),
  );
}

Codec<BurnInstructionData, BurnInstructionData> getBurnInstructionDataCodec() {
  return combineCodec(getBurnInstructionDataEncoder(), getBurnInstructionDataDecoder());
}

/// Creates a [Burn] instruction.
Instruction getBurnInstruction({
  required Address programAddress,
  required Address account,
  required Address mint,
  required Address authority,
  required BigInt amount,
}) {
  final instructionData = BurnInstructionData(
      amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: account, role: AccountRole.writable),
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getBurnInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Burn] instruction from raw instruction data.
BurnInstructionData parseBurnInstruction(Instruction instruction) {
  return getBurnInstructionDataDecoder().decode(instruction.data!);
}
