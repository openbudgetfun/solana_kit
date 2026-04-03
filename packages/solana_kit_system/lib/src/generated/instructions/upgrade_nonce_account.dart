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
class UpgradeNonceAccountInstructionData {
  const UpgradeNonceAccountInstructionData({
    this.discriminator = 12,
  });

  final int discriminator;
}

Encoder<UpgradeNonceAccountInstructionData> getUpgradeNonceAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpgradeNonceAccountInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<UpgradeNonceAccountInstructionData> getUpgradeNonceAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UpgradeNonceAccountInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<UpgradeNonceAccountInstructionData, UpgradeNonceAccountInstructionData> getUpgradeNonceAccountInstructionDataCodec() {
  return combineCodec(getUpgradeNonceAccountInstructionDataEncoder(), getUpgradeNonceAccountInstructionDataDecoder());
}

/// Creates a [UpgradeNonceAccount] instruction.
Instruction getUpgradeNonceAccountInstruction({
  required Address programAddress,
  required Address nonceAccount,

}) {
  final instructionData = UpgradeNonceAccountInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: nonceAccount, role: AccountRole.writable),
    ],
    data: getUpgradeNonceAccountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpgradeNonceAccount] instruction from raw instruction data.
UpgradeNonceAccountInstructionData parseUpgradeNonceAccountInstruction(Instruction instruction) {
  return getUpgradeNonceAccountInstructionDataDecoder().decode(instruction.data!);
}
