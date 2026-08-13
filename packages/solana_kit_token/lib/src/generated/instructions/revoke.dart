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
class RevokeInstructionData {
  const RevokeInstructionData({
    this.discriminator = 5,
  });

  final int discriminator;
}

Encoder<RevokeInstructionData> getRevokeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RevokeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<RevokeInstructionData> getRevokeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => RevokeInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<RevokeInstructionData, RevokeInstructionData> getRevokeInstructionDataCodec() {
  return combineCodec(getRevokeInstructionDataEncoder(), getRevokeInstructionDataDecoder());
}

/// Creates a [Revoke] instruction.
Instruction getRevokeInstruction({
  required Address programAddress,
  required Address source,
  required Address owner,

}) {
  final instructionData = RevokeInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: source, role: AccountRole.writable),
    AccountMeta(address: owner, role: AccountRole.readonlySigner),
    ],
    data: getRevokeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Revoke] instruction from raw instruction data.
RevokeInstructionData parseRevokeInstruction(Instruction instruction) {
  return getRevokeInstructionDataDecoder().decode(instruction.data!);
}
