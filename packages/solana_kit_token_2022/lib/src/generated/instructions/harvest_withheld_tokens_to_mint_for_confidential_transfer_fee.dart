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

/// The discriminator field name: 'confidentialTransferFeeDiscriminator'.
/// Offset: 1.

@immutable
class HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData {
  const HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData({
    this.discriminator = 37,
    this.confidentialTransferFeeDiscriminator = 3,
  });

  final int discriminator;
  final int confidentialTransferFeeDiscriminator;
}

Encoder<HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData> getHarvestWithheldTokensToMintForConfidentialTransferFeeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferFeeDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialTransferFeeDiscriminator': value.confidentialTransferFeeDiscriminator,
    },
  );
}

Decoder<HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData> getHarvestWithheldTokensToMintForConfidentialTransferFeeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferFeeDiscriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData(
      discriminator: map['discriminator']! as int,
      confidentialTransferFeeDiscriminator: map['confidentialTransferFeeDiscriminator']! as int,
    ),
  );
}

Codec<HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData, HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData> getHarvestWithheldTokensToMintForConfidentialTransferFeeInstructionDataCodec() {
  return combineCodec(getHarvestWithheldTokensToMintForConfidentialTransferFeeInstructionDataEncoder(), getHarvestWithheldTokensToMintForConfidentialTransferFeeInstructionDataDecoder());
}

/// Creates a [HarvestWithheldTokensToMintForConfidentialTransferFee] instruction.
Instruction getHarvestWithheldTokensToMintForConfidentialTransferFeeInstruction({
  required Address programAddress,
  required Address mint,

}) {
  final instructionData = HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getHarvestWithheldTokensToMintForConfidentialTransferFeeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [HarvestWithheldTokensToMintForConfidentialTransferFee] instruction from raw instruction data.
HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData parseHarvestWithheldTokensToMintForConfidentialTransferFeeInstruction(Instruction instruction) {
  return getHarvestWithheldTokensToMintForConfidentialTransferFeeInstructionDataDecoder().decode(instruction.data!);
}
