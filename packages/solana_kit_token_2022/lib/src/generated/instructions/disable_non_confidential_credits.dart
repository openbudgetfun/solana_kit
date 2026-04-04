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
class DisableNonConfidentialCreditsInstructionData {
  const DisableNonConfidentialCreditsInstructionData({
    this.discriminator = 27,
    this.confidentialTransferDiscriminator = 12,
  });

  final int discriminator;
  final int confidentialTransferDiscriminator;
}

Encoder<DisableNonConfidentialCreditsInstructionData> getDisableNonConfidentialCreditsInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DisableNonConfidentialCreditsInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialTransferDiscriminator': value.confidentialTransferDiscriminator,
    },
  );
}

Decoder<DisableNonConfidentialCreditsInstructionData> getDisableNonConfidentialCreditsInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => DisableNonConfidentialCreditsInstructionData(
      discriminator: map['discriminator']! as int,
      confidentialTransferDiscriminator: map['confidentialTransferDiscriminator']! as int,
    ),
  );
}

Codec<DisableNonConfidentialCreditsInstructionData, DisableNonConfidentialCreditsInstructionData> getDisableNonConfidentialCreditsInstructionDataCodec() {
  return combineCodec(getDisableNonConfidentialCreditsInstructionDataEncoder(), getDisableNonConfidentialCreditsInstructionDataDecoder());
}

/// Creates a [DisableNonConfidentialCredits] instruction.
Instruction getDisableNonConfidentialCreditsInstruction({
  required Address programAddress,
  required Address token,
  required Address authority,

}) {
  final instructionData = DisableNonConfidentialCreditsInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: token, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getDisableNonConfidentialCreditsInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [DisableNonConfidentialCredits] instruction from raw instruction data.
DisableNonConfidentialCreditsInstructionData parseDisableNonConfidentialCreditsInstruction(Instruction instruction) {
  return getDisableNonConfidentialCreditsInstructionDataDecoder().decode(instruction.data!);
}
