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

/// The discriminator field name: 'confidentialMintBurnDiscriminator'.
/// Offset: 1.

@immutable
class ApplyConfidentialPendingBurnInstructionData {
  const ApplyConfidentialPendingBurnInstructionData({
    this.discriminator = 42,
    this.confidentialMintBurnDiscriminator = 5,
  });

  final int discriminator;
  final int confidentialMintBurnDiscriminator;
}

Encoder<ApplyConfidentialPendingBurnInstructionData>
getApplyConfidentialPendingBurnInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialMintBurnDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ApplyConfidentialPendingBurnInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialMintBurnDiscriminator':
          value.confidentialMintBurnDiscriminator,
    },
  );
}

Decoder<ApplyConfidentialPendingBurnInstructionData>
getApplyConfidentialPendingBurnInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialMintBurnDiscriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        ApplyConfidentialPendingBurnInstructionData(
          discriminator: map['discriminator']! as int,
          confidentialMintBurnDiscriminator:
              map['confidentialMintBurnDiscriminator']! as int,
        ),
  );
}

Codec<
  ApplyConfidentialPendingBurnInstructionData,
  ApplyConfidentialPendingBurnInstructionData
>
getApplyConfidentialPendingBurnInstructionDataCodec() {
  return combineCodec(
    getApplyConfidentialPendingBurnInstructionDataEncoder(),
    getApplyConfidentialPendingBurnInstructionDataDecoder(),
  );
}

/// Creates a [ApplyConfidentialPendingBurn] instruction.
Instruction getApplyConfidentialPendingBurnInstruction({
  required Address programAddress,
  required Address mint,
  required Address authority,
}) {
  final instructionData = ApplyConfidentialPendingBurnInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getApplyConfidentialPendingBurnInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ApplyConfidentialPendingBurn] instruction from raw instruction data.
ApplyConfidentialPendingBurnInstructionData
parseApplyConfidentialPendingBurnInstruction(Instruction instruction) {
  return getApplyConfidentialPendingBurnInstructionDataDecoder().decode(
    instruction.data!,
  );
}
