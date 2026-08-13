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

/// The discriminator field name: 'transferFeeDiscriminator'.
/// Offset: 1.

@immutable
class HarvestWithheldTokensToMintInstructionData {
  const HarvestWithheldTokensToMintInstructionData({
    this.discriminator = 26,
    this.transferFeeDiscriminator = 4,
  });

  final int discriminator;
  final int transferFeeDiscriminator;
}

Encoder<HarvestWithheldTokensToMintInstructionData> getHarvestWithheldTokensToMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('transferFeeDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (HarvestWithheldTokensToMintInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'transferFeeDiscriminator': value.transferFeeDiscriminator,
    },
  );
}

Decoder<HarvestWithheldTokensToMintInstructionData> getHarvestWithheldTokensToMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('transferFeeDiscriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => HarvestWithheldTokensToMintInstructionData(
      discriminator: map['discriminator']! as int,
      transferFeeDiscriminator: map['transferFeeDiscriminator']! as int,
    ),
  );
}

Codec<HarvestWithheldTokensToMintInstructionData, HarvestWithheldTokensToMintInstructionData> getHarvestWithheldTokensToMintInstructionDataCodec() {
  return combineCodec(getHarvestWithheldTokensToMintInstructionDataEncoder(), getHarvestWithheldTokensToMintInstructionDataDecoder());
}

/// Creates a [HarvestWithheldTokensToMint] instruction.
Instruction getHarvestWithheldTokensToMintInstruction({
  required Address programAddress,
  required Address mint,

}) {
  final instructionData = HarvestWithheldTokensToMintInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getHarvestWithheldTokensToMintInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [HarvestWithheldTokensToMint] instruction from raw instruction data.
HarvestWithheldTokensToMintInstructionData parseHarvestWithheldTokensToMintInstruction(Instruction instruction) {
  return getHarvestWithheldTokensToMintInstructionDataDecoder().decode(instruction.data!);
}
