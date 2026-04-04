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
class ApproveConfidentialTransferAccountInstructionData {
  const ApproveConfidentialTransferAccountInstructionData({
    this.discriminator = 27,
    this.confidentialTransferDiscriminator = 3,
  });

  final int discriminator;
  final int confidentialTransferDiscriminator;
}

Encoder<ApproveConfidentialTransferAccountInstructionData> getApproveConfidentialTransferAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ApproveConfidentialTransferAccountInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialTransferDiscriminator': value.confidentialTransferDiscriminator,
    },
  );
}

Decoder<ApproveConfidentialTransferAccountInstructionData> getApproveConfidentialTransferAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => ApproveConfidentialTransferAccountInstructionData(
      discriminator: map['discriminator']! as int,
      confidentialTransferDiscriminator: map['confidentialTransferDiscriminator']! as int,
    ),
  );
}

Codec<ApproveConfidentialTransferAccountInstructionData, ApproveConfidentialTransferAccountInstructionData> getApproveConfidentialTransferAccountInstructionDataCodec() {
  return combineCodec(getApproveConfidentialTransferAccountInstructionDataEncoder(), getApproveConfidentialTransferAccountInstructionDataDecoder());
}

/// Creates a [ApproveConfidentialTransferAccount] instruction.
Instruction getApproveConfidentialTransferAccountInstruction({
  required Address programAddress,
  required Address token,
  required Address mint,
  required Address authority,

}) {
  final instructionData = ApproveConfidentialTransferAccountInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: token, role: AccountRole.writable),
    AccountMeta(address: mint, role: AccountRole.readonly),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getApproveConfidentialTransferAccountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ApproveConfidentialTransferAccount] instruction from raw instruction data.
ApproveConfidentialTransferAccountInstructionData parseApproveConfidentialTransferAccountInstruction(Instruction instruction) {
  return getApproveConfidentialTransferAccountInstructionDataDecoder().decode(instruction.data!);
}
