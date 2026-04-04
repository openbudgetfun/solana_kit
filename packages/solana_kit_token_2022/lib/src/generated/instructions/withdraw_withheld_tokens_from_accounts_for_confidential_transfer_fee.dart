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
class WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData {
  const WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData({
    this.discriminator = 37,
    this.confidentialTransferFeeDiscriminator = 2,
    required this.numTokenAccounts,
    required this.proofInstructionOffset,
    required this.newDecryptableAvailableBalance,
  });

  final int discriminator;
  final int confidentialTransferFeeDiscriminator;
  final int numTokenAccounts;
  final int proofInstructionOffset;
  final DecryptableBalance newDecryptableAvailableBalance;
}

Encoder<WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData> getWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferFeeDiscriminator', getU8Encoder()),
    ('numTokenAccounts', getU8Encoder()),
    ('proofInstructionOffset', getI8Encoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialTransferFeeDiscriminator': value.confidentialTransferFeeDiscriminator,
      'numTokenAccounts': value.numTokenAccounts,
      'proofInstructionOffset': value.proofInstructionOffset,
      'newDecryptableAvailableBalance': value.newDecryptableAvailableBalance,
    },
  );
}

Decoder<WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData> getWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferFeeDiscriminator', getU8Decoder()),
    ('numTokenAccounts', getU8Decoder()),
    ('proofInstructionOffset', getI8Decoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData(
      discriminator: map['discriminator']! as int,
      confidentialTransferFeeDiscriminator: map['confidentialTransferFeeDiscriminator']! as int,
      numTokenAccounts: map['numTokenAccounts']! as int,
      proofInstructionOffset: map['proofInstructionOffset']! as int,
      newDecryptableAvailableBalance: map['newDecryptableAvailableBalance']! as DecryptableBalance,
    ),
  );
}

Codec<WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData, WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData> getWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionDataCodec() {
  return combineCodec(getWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionDataEncoder(), getWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionDataDecoder());
}

/// Creates a [WithdrawWithheldTokensFromAccountsForConfidentialTransferFee] instruction.
Instruction getWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstruction({
  required Address programAddress,
  required Address mint,
  required Address destination,
  required Address instructionsSysvarOrContextState,
  Address? record,
  required Address authority,
  required int numTokenAccounts,
  required int proofInstructionOffset,
  required DecryptableBalance newDecryptableAvailableBalance,
}) {
  final instructionData = WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData(
      numTokenAccounts: numTokenAccounts,
      proofInstructionOffset: proofInstructionOffset,
      newDecryptableAvailableBalance: newDecryptableAvailableBalance,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.readonly),
    AccountMeta(address: destination, role: AccountRole.writable),
    AccountMeta(address: instructionsSysvarOrContextState, role: AccountRole.readonly),
    if (record != null) AccountMeta(address: record, role: AccountRole.readonly),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [WithdrawWithheldTokensFromAccountsForConfidentialTransferFee] instruction from raw instruction data.
WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData parseWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstruction(Instruction instruction) {
  return getWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionDataDecoder().decode(instruction.data!);
}
