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
class ThawAccountInstructionData {
  const ThawAccountInstructionData({
    this.discriminator = 11,
  });

  final int discriminator;
}

Encoder<ThawAccountInstructionData> getThawAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ThawAccountInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<ThawAccountInstructionData> getThawAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => ThawAccountInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<ThawAccountInstructionData, ThawAccountInstructionData> getThawAccountInstructionDataCodec() {
  return combineCodec(getThawAccountInstructionDataEncoder(), getThawAccountInstructionDataDecoder());
}

/// Creates a [ThawAccount] instruction.
Instruction getThawAccountInstruction({
  required Address programAddress,
  required Address account,
  required Address mint,
  required Address owner,

}) {
  final instructionData = ThawAccountInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: account, role: AccountRole.writable),
    AccountMeta(address: mint, role: AccountRole.readonly),
    AccountMeta(address: owner, role: AccountRole.readonlySigner),
    ],
    data: getThawAccountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ThawAccount] instruction from raw instruction data.
ThawAccountInstructionData parseThawAccountInstruction(Instruction instruction) {
  return getThawAccountInstructionDataDecoder().decode(instruction.data!);
}
