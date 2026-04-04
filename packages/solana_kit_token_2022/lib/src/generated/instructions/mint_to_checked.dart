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
class MintToCheckedInstructionData {
  const MintToCheckedInstructionData({
    this.discriminator = 14,
    required this.amount,
    required this.decimals,
  });

  final int discriminator;
  final BigInt amount;
  final int decimals;
}

Encoder<MintToCheckedInstructionData> getMintToCheckedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
    ('decimals', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (MintToCheckedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'amount': value.amount,
      'decimals': value.decimals,
    },
  );
}

Decoder<MintToCheckedInstructionData> getMintToCheckedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
    ('decimals', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => MintToCheckedInstructionData(
      discriminator: map['discriminator']! as int,
      amount: map['amount']! as BigInt,
      decimals: map['decimals']! as int,
    ),
  );
}

Codec<MintToCheckedInstructionData, MintToCheckedInstructionData> getMintToCheckedInstructionDataCodec() {
  return combineCodec(getMintToCheckedInstructionDataEncoder(), getMintToCheckedInstructionDataDecoder());
}

/// Creates a [MintToChecked] instruction.
Instruction getMintToCheckedInstruction({
  required Address programAddress,
  required Address mint,
  required Address token,
  required Address mintAuthority,
  required BigInt amount,
  required int decimals,
}) {
  final instructionData = MintToCheckedInstructionData(
      amount: amount,
      decimals: decimals,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: token, role: AccountRole.writable),
    AccountMeta(address: mintAuthority, role: AccountRole.readonlySigner),
    ],
    data: getMintToCheckedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [MintToChecked] instruction from raw instruction data.
MintToCheckedInstructionData parseMintToCheckedInstruction(Instruction instruction) {
  return getMintToCheckedInstructionDataDecoder().decode(instruction.data!);
}
