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
class AdvanceNonceAccountInstructionData {
  const AdvanceNonceAccountInstructionData({
    this.discriminator = 4,
  });

  final int discriminator;
}

Encoder<AdvanceNonceAccountInstructionData> getAdvanceNonceAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AdvanceNonceAccountInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<AdvanceNonceAccountInstructionData> getAdvanceNonceAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => AdvanceNonceAccountInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<AdvanceNonceAccountInstructionData, AdvanceNonceAccountInstructionData> getAdvanceNonceAccountInstructionDataCodec() {
  return combineCodec(getAdvanceNonceAccountInstructionDataEncoder(), getAdvanceNonceAccountInstructionDataDecoder());
}

/// Creates a [AdvanceNonceAccount] instruction.
Instruction getAdvanceNonceAccountInstruction({
  required Address programAddress,
  required Address nonceAccount,
  required Address recentBlockhashesSysvar,
  required Address nonceAuthority,

}) {
  final instructionData = AdvanceNonceAccountInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: nonceAccount, role: AccountRole.writable),
    AccountMeta(address: recentBlockhashesSysvar, role: AccountRole.readonly),
    AccountMeta(address: nonceAuthority, role: AccountRole.readonlySigner),
    ],
    data: getAdvanceNonceAccountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [AdvanceNonceAccount] instruction from raw instruction data.
AdvanceNonceAccountInstructionData parseAdvanceNonceAccountInstruction(Instruction instruction) {
  return getAdvanceNonceAccountInstructionDataDecoder().decode(instruction.data!);
}
