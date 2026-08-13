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
class BurnCheckedInstructionData {
  const BurnCheckedInstructionData({
    this.discriminator = 15,
    required this.amount,
    required this.decimals,
  });

  final int discriminator;
  final BigInt amount;
  final int decimals;
}

Encoder<BurnCheckedInstructionData> getBurnCheckedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
    ('decimals', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (BurnCheckedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'amount': value.amount,
      'decimals': value.decimals,
    },
  );
}

Decoder<BurnCheckedInstructionData> getBurnCheckedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
    ('decimals', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => BurnCheckedInstructionData(
      discriminator: map['discriminator']! as int,
      amount: map['amount']! as BigInt,
      decimals: map['decimals']! as int,
    ),
  );
}

Codec<BurnCheckedInstructionData, BurnCheckedInstructionData> getBurnCheckedInstructionDataCodec() {
  return combineCodec(getBurnCheckedInstructionDataEncoder(), getBurnCheckedInstructionDataDecoder());
}

/// Creates a [BurnChecked] instruction.
Instruction getBurnCheckedInstruction({
  required Address programAddress,
  required Address account,
  required Address mint,
  required Address authority,
  required BigInt amount,
  required int decimals,
}) {
  final instructionData = BurnCheckedInstructionData(
      amount: amount,
      decimals: decimals,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: account, role: AccountRole.writable),
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getBurnCheckedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [BurnChecked] instruction from raw instruction data.
BurnCheckedInstructionData parseBurnCheckedInstruction(Instruction instruction) {
  return getBurnCheckedInstructionDataDecoder().decode(instruction.data!);
}
