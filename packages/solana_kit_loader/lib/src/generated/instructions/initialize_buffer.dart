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
class InitializeBufferInstructionData {
  const InitializeBufferInstructionData({
    this.discriminator = 0,
  });

  final int discriminator;
}

Encoder<InitializeBufferInstructionData>
getInitializeBufferInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeBufferInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<InitializeBufferInstructionData>
getInitializeBufferInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        InitializeBufferInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

Codec<InitializeBufferInstructionData, InitializeBufferInstructionData>
getInitializeBufferInstructionDataCodec() {
  return combineCodec(
    getInitializeBufferInstructionDataEncoder(),
    getInitializeBufferInstructionDataDecoder(),
  );
}

/// Creates a [InitializeBuffer] instruction.
Instruction getInitializeBufferInstruction({
  required Address programAddress,
  required Address sourceAccount,
  required Address bufferAuthority,
}) {
  final instructionData = InitializeBufferInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: sourceAccount, role: AccountRole.writable),
      AccountMeta(address: bufferAuthority, role: AccountRole.readonly),
    ],
    data: getInitializeBufferInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeBuffer] instruction from raw instruction data.
InitializeBufferInstructionData parseInitializeBufferInstruction(
  Instruction instruction,
) {
  return getInitializeBufferInstructionDataDecoder().decode(instruction.data!);
}
