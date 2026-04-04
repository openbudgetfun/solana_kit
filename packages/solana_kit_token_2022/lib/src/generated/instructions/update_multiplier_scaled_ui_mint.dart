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

/// The discriminator field name: 'scaledUiAmountMintDiscriminator'.
/// Offset: 1.

@immutable
class UpdateMultiplierScaledUiMintInstructionData {
  const UpdateMultiplierScaledUiMintInstructionData({
    this.discriminator = 43,
    this.scaledUiAmountMintDiscriminator = 1,
    required this.multiplier,
    required this.effectiveTimestamp,
  });

  final int discriminator;
  final int scaledUiAmountMintDiscriminator;
  final double multiplier;
  final BigInt effectiveTimestamp;
}

Encoder<UpdateMultiplierScaledUiMintInstructionData> getUpdateMultiplierScaledUiMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('scaledUiAmountMintDiscriminator', getU8Encoder()),
    ('multiplier', getF64Encoder()),
    ('effectiveTimestamp', getI64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateMultiplierScaledUiMintInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'scaledUiAmountMintDiscriminator': value.scaledUiAmountMintDiscriminator,
      'multiplier': value.multiplier,
      'effectiveTimestamp': value.effectiveTimestamp,
    },
  );
}

Decoder<UpdateMultiplierScaledUiMintInstructionData> getUpdateMultiplierScaledUiMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('scaledUiAmountMintDiscriminator', getU8Decoder()),
    ('multiplier', getF64Decoder()),
    ('effectiveTimestamp', getI64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UpdateMultiplierScaledUiMintInstructionData(
      discriminator: map['discriminator']! as int,
      scaledUiAmountMintDiscriminator: map['scaledUiAmountMintDiscriminator']! as int,
      multiplier: map['multiplier']! as double,
      effectiveTimestamp: map['effectiveTimestamp']! as BigInt,
    ),
  );
}

Codec<UpdateMultiplierScaledUiMintInstructionData, UpdateMultiplierScaledUiMintInstructionData> getUpdateMultiplierScaledUiMintInstructionDataCodec() {
  return combineCodec(getUpdateMultiplierScaledUiMintInstructionDataEncoder(), getUpdateMultiplierScaledUiMintInstructionDataDecoder());
}

/// Creates a [UpdateMultiplierScaledUiMint] instruction.
Instruction getUpdateMultiplierScaledUiMintInstruction({
  required Address programAddress,
  required Address mint,
  required Address authority,
  required double multiplier,
  required BigInt effectiveTimestamp,
}) {
  final instructionData = UpdateMultiplierScaledUiMintInstructionData(
      multiplier: multiplier,
      effectiveTimestamp: effectiveTimestamp,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.writableSigner),
    ],
    data: getUpdateMultiplierScaledUiMintInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateMultiplierScaledUiMint] instruction from raw instruction data.
UpdateMultiplierScaledUiMintInstructionData parseUpdateMultiplierScaledUiMintInstruction(Instruction instruction) {
  return getUpdateMultiplierScaledUiMintInstructionDataDecoder().decode(instruction.data!);
}
