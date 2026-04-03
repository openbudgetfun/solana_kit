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
class FreezeAccountInstructionData {
  const FreezeAccountInstructionData({
    this.discriminator = 10,
  });

  final int discriminator;
}

Encoder<FreezeAccountInstructionData> getFreezeAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (FreezeAccountInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<FreezeAccountInstructionData> getFreezeAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => FreezeAccountInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<FreezeAccountInstructionData, FreezeAccountInstructionData> getFreezeAccountInstructionDataCodec() {
  return combineCodec(getFreezeAccountInstructionDataEncoder(), getFreezeAccountInstructionDataDecoder());
}

/// Creates a [FreezeAccount] instruction.
Instruction getFreezeAccountInstruction({
  required Address programAddress,
  required Address account,
  required Address mint,
  required Address owner,

}) {
  final instructionData = FreezeAccountInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: account, role: AccountRole.writable),
    AccountMeta(address: mint, role: AccountRole.readonly),
    AccountMeta(address: owner, role: AccountRole.readonlySigner),
    ],
    data: getFreezeAccountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [FreezeAccount] instruction from raw instruction data.
FreezeAccountInstructionData parseFreezeAccountInstruction(Instruction instruction) {
  return getFreezeAccountInstructionDataDecoder().decode(instruction.data!);
}
