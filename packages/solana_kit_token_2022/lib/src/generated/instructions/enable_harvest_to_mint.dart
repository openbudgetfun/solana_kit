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
class EnableHarvestToMintInstructionData {
  const EnableHarvestToMintInstructionData({
    this.discriminator = 37,
    this.confidentialTransferFeeDiscriminator = 4,
  });

  final int discriminator;
  final int confidentialTransferFeeDiscriminator;
}

Encoder<EnableHarvestToMintInstructionData> getEnableHarvestToMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferFeeDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (EnableHarvestToMintInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialTransferFeeDiscriminator': value.confidentialTransferFeeDiscriminator,
    },
  );
}

Decoder<EnableHarvestToMintInstructionData> getEnableHarvestToMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferFeeDiscriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => EnableHarvestToMintInstructionData(
      discriminator: map['discriminator']! as int,
      confidentialTransferFeeDiscriminator: map['confidentialTransferFeeDiscriminator']! as int,
    ),
  );
}

Codec<EnableHarvestToMintInstructionData, EnableHarvestToMintInstructionData> getEnableHarvestToMintInstructionDataCodec() {
  return combineCodec(getEnableHarvestToMintInstructionDataEncoder(), getEnableHarvestToMintInstructionDataDecoder());
}

/// Creates a [EnableHarvestToMint] instruction.
Instruction getEnableHarvestToMintInstruction({
  required Address programAddress,
  required Address mint,
  required Address authority,

}) {
  final instructionData = EnableHarvestToMintInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getEnableHarvestToMintInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [EnableHarvestToMint] instruction from raw instruction data.
EnableHarvestToMintInstructionData parseEnableHarvestToMintInstruction(Instruction instruction) {
  return getEnableHarvestToMintInstructionDataDecoder().decode(instruction.data!);
}
