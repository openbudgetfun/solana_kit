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
class ConfigureConfidentialTransferAccountInstructionData {
  const ConfigureConfidentialTransferAccountInstructionData({
    this.discriminator = 27,
    this.confidentialTransferDiscriminator = 2,
    required this.decryptableZeroBalance,
    required this.maximumPendingBalanceCreditCounter,
    required this.proofInstructionOffset,
  });

  final int discriminator;
  final int confidentialTransferDiscriminator;
  final DecryptableBalance decryptableZeroBalance;
  final BigInt maximumPendingBalanceCreditCounter;
  final int proofInstructionOffset;
}

Encoder<ConfigureConfidentialTransferAccountInstructionData> getConfigureConfidentialTransferAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
    ('decryptableZeroBalance', getDecryptableBalanceEncoder()),
    ('maximumPendingBalanceCreditCounter', getU64Encoder()),
    ('proofInstructionOffset', getI8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ConfigureConfidentialTransferAccountInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialTransferDiscriminator': value.confidentialTransferDiscriminator,
      'decryptableZeroBalance': value.decryptableZeroBalance,
      'maximumPendingBalanceCreditCounter': value.maximumPendingBalanceCreditCounter,
      'proofInstructionOffset': value.proofInstructionOffset,
    },
  );
}

Decoder<ConfigureConfidentialTransferAccountInstructionData> getConfigureConfidentialTransferAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
    ('decryptableZeroBalance', getDecryptableBalanceDecoder()),
    ('maximumPendingBalanceCreditCounter', getU64Decoder()),
    ('proofInstructionOffset', getI8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => ConfigureConfidentialTransferAccountInstructionData(
      discriminator: map['discriminator']! as int,
      confidentialTransferDiscriminator: map['confidentialTransferDiscriminator']! as int,
      decryptableZeroBalance: map['decryptableZeroBalance']! as DecryptableBalance,
      maximumPendingBalanceCreditCounter: map['maximumPendingBalanceCreditCounter']! as BigInt,
      proofInstructionOffset: map['proofInstructionOffset']! as int,
    ),
  );
}

Codec<ConfigureConfidentialTransferAccountInstructionData, ConfigureConfidentialTransferAccountInstructionData> getConfigureConfidentialTransferAccountInstructionDataCodec() {
  return combineCodec(getConfigureConfidentialTransferAccountInstructionDataEncoder(), getConfigureConfidentialTransferAccountInstructionDataDecoder());
}

/// Creates a [ConfigureConfidentialTransferAccount] instruction.
Instruction getConfigureConfidentialTransferAccountInstruction({
  required Address programAddress,
  required Address token,
  required Address mint,
  required Address instructionsSysvarOrContextState,
  Address? record,
  required Address authority,
  required DecryptableBalance decryptableZeroBalance,
  required BigInt maximumPendingBalanceCreditCounter,
  required int proofInstructionOffset,
}) {
  final instructionData = ConfigureConfidentialTransferAccountInstructionData(
      decryptableZeroBalance: decryptableZeroBalance,
      maximumPendingBalanceCreditCounter: maximumPendingBalanceCreditCounter,
      proofInstructionOffset: proofInstructionOffset,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: token, role: AccountRole.writable),
    AccountMeta(address: mint, role: AccountRole.readonly),
    AccountMeta(address: instructionsSysvarOrContextState, role: AccountRole.readonly),
    if (record != null) AccountMeta(address: record, role: AccountRole.readonly),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getConfigureConfidentialTransferAccountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ConfigureConfidentialTransferAccount] instruction from raw instruction data.
ConfigureConfidentialTransferAccountInstructionData parseConfigureConfidentialTransferAccountInstruction(Instruction instruction) {
  return getConfigureConfidentialTransferAccountInstructionDataDecoder().decode(instruction.data!);
}
