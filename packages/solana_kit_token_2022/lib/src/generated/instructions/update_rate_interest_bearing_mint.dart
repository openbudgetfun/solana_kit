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

/// The discriminator field name: 'interestBearingMintDiscriminator'.
/// Offset: 1.

@immutable
class UpdateRateInterestBearingMintInstructionData {
  const UpdateRateInterestBearingMintInstructionData({
    this.discriminator = 33,
    this.interestBearingMintDiscriminator = 1,
    required this.rate,
  });

  final int discriminator;
  final int interestBearingMintDiscriminator;
  final int rate;
}

Encoder<UpdateRateInterestBearingMintInstructionData> getUpdateRateInterestBearingMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('interestBearingMintDiscriminator', getU8Encoder()),
    ('rate', getI16Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateRateInterestBearingMintInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'interestBearingMintDiscriminator': value.interestBearingMintDiscriminator,
      'rate': value.rate,
    },
  );
}

Decoder<UpdateRateInterestBearingMintInstructionData> getUpdateRateInterestBearingMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('interestBearingMintDiscriminator', getU8Decoder()),
    ('rate', getI16Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UpdateRateInterestBearingMintInstructionData(
      discriminator: map['discriminator']! as int,
      interestBearingMintDiscriminator: map['interestBearingMintDiscriminator']! as int,
      rate: map['rate']! as int,
    ),
  );
}

Codec<UpdateRateInterestBearingMintInstructionData, UpdateRateInterestBearingMintInstructionData> getUpdateRateInterestBearingMintInstructionDataCodec() {
  return combineCodec(getUpdateRateInterestBearingMintInstructionDataEncoder(), getUpdateRateInterestBearingMintInstructionDataDecoder());
}

/// Creates a [UpdateRateInterestBearingMint] instruction.
Instruction getUpdateRateInterestBearingMintInstruction({
  required Address programAddress,
  required Address mint,
  required Address rateAuthority,
  required int rate,
}) {
  final instructionData = UpdateRateInterestBearingMintInstructionData(
      rate: rate,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: rateAuthority, role: AccountRole.writableSigner),
    ],
    data: getUpdateRateInterestBearingMintInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateRateInterestBearingMint] instruction from raw instruction data.
UpdateRateInterestBearingMintInstructionData parseUpdateRateInterestBearingMintInstruction(Instruction instruction) {
  return getUpdateRateInterestBearingMintInstructionDataDecoder().decode(instruction.data!);
}
