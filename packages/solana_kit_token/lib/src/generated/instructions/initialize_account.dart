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
class InitializeAccountInstructionData {
  const InitializeAccountInstructionData({
    this.discriminator = 1,
  });

  final int discriminator;
}

Encoder<InitializeAccountInstructionData> getInitializeAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeAccountInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<InitializeAccountInstructionData> getInitializeAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeAccountInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<InitializeAccountInstructionData, InitializeAccountInstructionData> getInitializeAccountInstructionDataCodec() {
  return combineCodec(getInitializeAccountInstructionDataEncoder(), getInitializeAccountInstructionDataDecoder());
}

/// Creates a [InitializeAccount] instruction.
Instruction getInitializeAccountInstruction({
  required Address programAddress,
  required Address account,
  required Address mint,
  required Address owner,
  required Address rent,

}) {
  final instructionData = InitializeAccountInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: account, role: AccountRole.writable),
    AccountMeta(address: mint, role: AccountRole.readonly),
    AccountMeta(address: owner, role: AccountRole.readonly),
    AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getInitializeAccountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeAccount] instruction from raw instruction data.
InitializeAccountInstructionData parseInitializeAccountInstruction(Instruction instruction) {
  return getInitializeAccountInstructionDataDecoder().decode(instruction.data!);
}
