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
class MintToInstructionData {
  const MintToInstructionData({
    this.discriminator = 7,
    required this.amount,
  });

  final int discriminator;
  final BigInt amount;
}

Encoder<MintToInstructionData> getMintToInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (MintToInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'amount': value.amount,
    },
  );
}

Decoder<MintToInstructionData> getMintToInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => MintToInstructionData(
      discriminator: map['discriminator']! as int,
      amount: map['amount']! as BigInt,
    ),
  );
}

Codec<MintToInstructionData, MintToInstructionData> getMintToInstructionDataCodec() {
  return combineCodec(getMintToInstructionDataEncoder(), getMintToInstructionDataDecoder());
}

/// Creates a [MintTo] instruction.
Instruction getMintToInstruction({
  required Address programAddress,
  required Address mint,
  required Address token,
  required Address mintAuthority,
  required BigInt amount,
}) {
  final instructionData = MintToInstructionData(
      amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: token, role: AccountRole.writable),
    AccountMeta(address: mintAuthority, role: AccountRole.readonlySigner),
    ],
    data: getMintToInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [MintTo] instruction from raw instruction data.
MintToInstructionData parseMintToInstruction(Instruction instruction) {
  return getMintToInstructionDataDecoder().decode(instruction.data!);
}
