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
class InitializeImmutableOwnerInstructionData {
  const InitializeImmutableOwnerInstructionData({
    this.discriminator = 22,
  });

  final int discriminator;
}

Encoder<InitializeImmutableOwnerInstructionData> getInitializeImmutableOwnerInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeImmutableOwnerInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<InitializeImmutableOwnerInstructionData> getInitializeImmutableOwnerInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeImmutableOwnerInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<InitializeImmutableOwnerInstructionData, InitializeImmutableOwnerInstructionData> getInitializeImmutableOwnerInstructionDataCodec() {
  return combineCodec(getInitializeImmutableOwnerInstructionDataEncoder(), getInitializeImmutableOwnerInstructionDataDecoder());
}

/// Creates a [InitializeImmutableOwner] instruction.
Instruction getInitializeImmutableOwnerInstruction({
  required Address programAddress,
  required Address account,

}) {
  final instructionData = InitializeImmutableOwnerInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: account, role: AccountRole.writable),
    ],
    data: getInitializeImmutableOwnerInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeImmutableOwner] instruction from raw instruction data.
InitializeImmutableOwnerInstructionData parseInitializeImmutableOwnerInstruction(Instruction instruction) {
  return getInitializeImmutableOwnerInstructionDataDecoder().decode(instruction.data!);
}
