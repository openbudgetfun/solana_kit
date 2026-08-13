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

/// The discriminator field name: 'confidentialTransferDiscriminator'.
/// Offset: 1.

@immutable
class EnableNonConfidentialCreditsInstructionData {
  const EnableNonConfidentialCreditsInstructionData({
    this.discriminator = 27,
    this.confidentialTransferDiscriminator = 11,
  });

  final int discriminator;
  final int confidentialTransferDiscriminator;
}

Encoder<EnableNonConfidentialCreditsInstructionData> getEnableNonConfidentialCreditsInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (EnableNonConfidentialCreditsInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialTransferDiscriminator': value.confidentialTransferDiscriminator,
    },
  );
}

Decoder<EnableNonConfidentialCreditsInstructionData> getEnableNonConfidentialCreditsInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => EnableNonConfidentialCreditsInstructionData(
      discriminator: map['discriminator']! as int,
      confidentialTransferDiscriminator: map['confidentialTransferDiscriminator']! as int,
    ),
  );
}

Codec<EnableNonConfidentialCreditsInstructionData, EnableNonConfidentialCreditsInstructionData> getEnableNonConfidentialCreditsInstructionDataCodec() {
  return combineCodec(getEnableNonConfidentialCreditsInstructionDataEncoder(), getEnableNonConfidentialCreditsInstructionDataDecoder());
}

/// Creates a [EnableNonConfidentialCredits] instruction.
Instruction getEnableNonConfidentialCreditsInstruction({
  required Address programAddress,
  required Address token,
  required Address authority,

}) {
  final instructionData = EnableNonConfidentialCreditsInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: token, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getEnableNonConfidentialCreditsInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [EnableNonConfidentialCredits] instruction from raw instruction data.
EnableNonConfidentialCreditsInstructionData parseEnableNonConfidentialCreditsInstruction(Instruction instruction) {
  return getEnableNonConfidentialCreditsInstructionDataDecoder().decode(instruction.data!);
}
