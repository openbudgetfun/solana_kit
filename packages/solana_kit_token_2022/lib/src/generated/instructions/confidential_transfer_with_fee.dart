// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/decryptable_balance.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

/// The discriminator field name: 'confidentialTransferDiscriminator'.
/// Offset: 1.

@immutable
class ConfidentialTransferWithFeeInstructionData {
  const ConfidentialTransferWithFeeInstructionData({
    this.discriminator = 27,
    this.confidentialTransferDiscriminator = 13,
    required this.newSourceDecryptableAvailableBalance,
    required this.equalityProofInstructionOffset,
    required this.transferAmountCiphertextValidityProofInstructionOffset,
    required this.feeSigmaProofInstructionOffset,
    required this.feeCiphertextValidityProofInstructionOffset,
    required this.rangeProofInstructionOffset,
  });

  final int discriminator;
  final int confidentialTransferDiscriminator;
  final DecryptableBalance newSourceDecryptableAvailableBalance;
  final int equalityProofInstructionOffset;
  final int transferAmountCiphertextValidityProofInstructionOffset;
  final int feeSigmaProofInstructionOffset;
  final int feeCiphertextValidityProofInstructionOffset;
  final int rangeProofInstructionOffset;
}

Encoder<ConfidentialTransferWithFeeInstructionData> getConfidentialTransferWithFeeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
    ('newSourceDecryptableAvailableBalance', getDecryptableBalanceEncoder()),
    ('equalityProofInstructionOffset', getI8Encoder()),
    ('transferAmountCiphertextValidityProofInstructionOffset', getI8Encoder()),
    ('feeSigmaProofInstructionOffset', getI8Encoder()),
    ('feeCiphertextValidityProofInstructionOffset', getI8Encoder()),
    ('rangeProofInstructionOffset', getI8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ConfidentialTransferWithFeeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialTransferDiscriminator': value.confidentialTransferDiscriminator,
      'newSourceDecryptableAvailableBalance': value.newSourceDecryptableAvailableBalance,
      'equalityProofInstructionOffset': value.equalityProofInstructionOffset,
      'transferAmountCiphertextValidityProofInstructionOffset': value.transferAmountCiphertextValidityProofInstructionOffset,
      'feeSigmaProofInstructionOffset': value.feeSigmaProofInstructionOffset,
      'feeCiphertextValidityProofInstructionOffset': value.feeCiphertextValidityProofInstructionOffset,
      'rangeProofInstructionOffset': value.rangeProofInstructionOffset,
    },
  );
}

Decoder<ConfidentialTransferWithFeeInstructionData> getConfidentialTransferWithFeeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
    ('newSourceDecryptableAvailableBalance', getDecryptableBalanceDecoder()),
    ('equalityProofInstructionOffset', getI8Decoder()),
    ('transferAmountCiphertextValidityProofInstructionOffset', getI8Decoder()),
    ('feeSigmaProofInstructionOffset', getI8Decoder()),
    ('feeCiphertextValidityProofInstructionOffset', getI8Decoder()),
    ('rangeProofInstructionOffset', getI8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => ConfidentialTransferWithFeeInstructionData(
      discriminator: map['discriminator']! as int,
      confidentialTransferDiscriminator: map['confidentialTransferDiscriminator']! as int,
      newSourceDecryptableAvailableBalance: map['newSourceDecryptableAvailableBalance']! as DecryptableBalance,
      equalityProofInstructionOffset: map['equalityProofInstructionOffset']! as int,
      transferAmountCiphertextValidityProofInstructionOffset: map['transferAmountCiphertextValidityProofInstructionOffset']! as int,
      feeSigmaProofInstructionOffset: map['feeSigmaProofInstructionOffset']! as int,
      feeCiphertextValidityProofInstructionOffset: map['feeCiphertextValidityProofInstructionOffset']! as int,
      rangeProofInstructionOffset: map['rangeProofInstructionOffset']! as int,
    ),
  );
}

Codec<ConfidentialTransferWithFeeInstructionData, ConfidentialTransferWithFeeInstructionData> getConfidentialTransferWithFeeInstructionDataCodec() {
  return combineCodec(getConfidentialTransferWithFeeInstructionDataEncoder(), getConfidentialTransferWithFeeInstructionDataDecoder());
}

/// Creates a [ConfidentialTransferWithFee] instruction.
Instruction getConfidentialTransferWithFeeInstruction({
  required Address programAddress,
  required Address sourceToken,
  required Address mint,
  required Address destinationToken,
  Address? instructionsSysvar,
  Address? equalityRecord,
  Address? transferAmountCiphertextValidityRecord,
  Address? feeSigmaRecord,
  Address? feeCiphertextValidityRecord,
  Address? rangeRecord,
  required Address authority,
  required DecryptableBalance newSourceDecryptableAvailableBalance,
  required int equalityProofInstructionOffset,
  required int transferAmountCiphertextValidityProofInstructionOffset,
  required int feeSigmaProofInstructionOffset,
  required int feeCiphertextValidityProofInstructionOffset,
  required int rangeProofInstructionOffset,
}) {
  final instructionData = ConfidentialTransferWithFeeInstructionData(
      newSourceDecryptableAvailableBalance: newSourceDecryptableAvailableBalance,
      equalityProofInstructionOffset: equalityProofInstructionOffset,
      transferAmountCiphertextValidityProofInstructionOffset: transferAmountCiphertextValidityProofInstructionOffset,
      feeSigmaProofInstructionOffset: feeSigmaProofInstructionOffset,
      feeCiphertextValidityProofInstructionOffset: feeCiphertextValidityProofInstructionOffset,
      rangeProofInstructionOffset: rangeProofInstructionOffset,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: sourceToken, role: AccountRole.writable),
    AccountMeta(address: mint, role: AccountRole.readonly),
    AccountMeta(address: destinationToken, role: AccountRole.writable),
    if (instructionsSysvar != null) AccountMeta(address: instructionsSysvar, role: AccountRole.readonly),
    if (equalityRecord != null) AccountMeta(address: equalityRecord, role: AccountRole.readonly),
    if (transferAmountCiphertextValidityRecord != null) AccountMeta(address: transferAmountCiphertextValidityRecord, role: AccountRole.readonly),
    if (feeSigmaRecord != null) AccountMeta(address: feeSigmaRecord, role: AccountRole.readonly),
    if (feeCiphertextValidityRecord != null) AccountMeta(address: feeCiphertextValidityRecord, role: AccountRole.readonly),
    if (rangeRecord != null) AccountMeta(address: rangeRecord, role: AccountRole.readonly),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getConfidentialTransferWithFeeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ConfidentialTransferWithFee] instruction from raw instruction data.
ConfidentialTransferWithFeeInstructionData parseConfidentialTransferWithFeeInstruction(Instruction instruction) {
  return getConfidentialTransferWithFeeInstructionDataDecoder().decode(instruction.data!);
}
