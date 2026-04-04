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

/// The discriminator field name: 'confidentialTransferFeeDiscriminator'.
/// Offset: 1.

@immutable
class WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData {
  const WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData({
    this.discriminator = 37,
    this.confidentialTransferFeeDiscriminator = 1,
    required this.proofInstructionOffset,
    required this.newDecryptableAvailableBalance,
  });

  final int discriminator;
  final int confidentialTransferFeeDiscriminator;
  final int proofInstructionOffset;
  final DecryptableBalance newDecryptableAvailableBalance;
}

Encoder<WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData> getWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferFeeDiscriminator', getU8Encoder()),
    ('proofInstructionOffset', getI8Encoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialTransferFeeDiscriminator': value.confidentialTransferFeeDiscriminator,
      'proofInstructionOffset': value.proofInstructionOffset,
      'newDecryptableAvailableBalance': value.newDecryptableAvailableBalance,
    },
  );
}

Decoder<WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData> getWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferFeeDiscriminator', getU8Decoder()),
    ('proofInstructionOffset', getI8Decoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData(
      discriminator: map['discriminator']! as int,
      confidentialTransferFeeDiscriminator: map['confidentialTransferFeeDiscriminator']! as int,
      proofInstructionOffset: map['proofInstructionOffset']! as int,
      newDecryptableAvailableBalance: map['newDecryptableAvailableBalance']! as DecryptableBalance,
    ),
  );
}

Codec<WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData, WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData> getWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionDataCodec() {
  return combineCodec(getWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionDataEncoder(), getWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionDataDecoder());
}

/// Creates a [WithdrawWithheldTokensFromMintForConfidentialTransferFee] instruction.
Instruction getWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstruction({
  required Address programAddress,
  required Address mint,
  required Address destination,
  required Address instructionsSysvarOrContextState,
  Address? record,
  required Address authority,
  required int proofInstructionOffset,
  required DecryptableBalance newDecryptableAvailableBalance,
}) {
  final instructionData = WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData(
      proofInstructionOffset: proofInstructionOffset,
      newDecryptableAvailableBalance: newDecryptableAvailableBalance,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: destination, role: AccountRole.writable),
    AccountMeta(address: instructionsSysvarOrContextState, role: AccountRole.readonly),
    if (record != null) AccountMeta(address: record, role: AccountRole.readonly),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [WithdrawWithheldTokensFromMintForConfidentialTransferFee] instruction from raw instruction data.
WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData parseWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstruction(Instruction instruction) {
  return getWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionDataDecoder().decode(instruction.data!);
}
