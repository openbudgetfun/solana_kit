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
class EmptyConfidentialTransferAccountInstructionData {
  const EmptyConfidentialTransferAccountInstructionData({
    this.discriminator = 27,
    this.confidentialTransferDiscriminator = 4,
    required this.proofInstructionOffset,
  });

  final int discriminator;
  final int confidentialTransferDiscriminator;
  final int proofInstructionOffset;
}

Encoder<EmptyConfidentialTransferAccountInstructionData> getEmptyConfidentialTransferAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
    ('proofInstructionOffset', getI8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (EmptyConfidentialTransferAccountInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialTransferDiscriminator': value.confidentialTransferDiscriminator,
      'proofInstructionOffset': value.proofInstructionOffset,
    },
  );
}

Decoder<EmptyConfidentialTransferAccountInstructionData> getEmptyConfidentialTransferAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
    ('proofInstructionOffset', getI8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => EmptyConfidentialTransferAccountInstructionData(
      discriminator: map['discriminator']! as int,
      confidentialTransferDiscriminator: map['confidentialTransferDiscriminator']! as int,
      proofInstructionOffset: map['proofInstructionOffset']! as int,
    ),
  );
}

Codec<EmptyConfidentialTransferAccountInstructionData, EmptyConfidentialTransferAccountInstructionData> getEmptyConfidentialTransferAccountInstructionDataCodec() {
  return combineCodec(getEmptyConfidentialTransferAccountInstructionDataEncoder(), getEmptyConfidentialTransferAccountInstructionDataDecoder());
}

/// Creates a [EmptyConfidentialTransferAccount] instruction.
Instruction getEmptyConfidentialTransferAccountInstruction({
  required Address programAddress,
  required Address token,
  required Address instructionsSysvarOrContextState,
  Address? record,
  required Address authority,
  required int proofInstructionOffset,
}) {
  final instructionData = EmptyConfidentialTransferAccountInstructionData(
      proofInstructionOffset: proofInstructionOffset,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: token, role: AccountRole.writable),
    AccountMeta(address: instructionsSysvarOrContextState, role: AccountRole.readonly),
    if (record != null) AccountMeta(address: record, role: AccountRole.readonly),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getEmptyConfidentialTransferAccountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [EmptyConfidentialTransferAccount] instruction from raw instruction data.
EmptyConfidentialTransferAccountInstructionData parseEmptyConfidentialTransferAccountInstruction(Instruction instruction) {
  return getEmptyConfidentialTransferAccountInstructionDataDecoder().decode(instruction.data!);
}
