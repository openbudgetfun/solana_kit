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
class ApplyConfidentialPendingBalanceInstructionData {
  const ApplyConfidentialPendingBalanceInstructionData({
    this.discriminator = 27,
    this.confidentialTransferDiscriminator = 8,
    required this.expectedPendingBalanceCreditCounter,
    required this.newDecryptableAvailableBalance,
  });

  final int discriminator;
  final int confidentialTransferDiscriminator;
  final BigInt expectedPendingBalanceCreditCounter;
  final DecryptableBalance newDecryptableAvailableBalance;
}

Encoder<ApplyConfidentialPendingBalanceInstructionData> getApplyConfidentialPendingBalanceInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
    ('expectedPendingBalanceCreditCounter', getU64Encoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ApplyConfidentialPendingBalanceInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialTransferDiscriminator': value.confidentialTransferDiscriminator,
      'expectedPendingBalanceCreditCounter': value.expectedPendingBalanceCreditCounter,
      'newDecryptableAvailableBalance': value.newDecryptableAvailableBalance,
    },
  );
}

Decoder<ApplyConfidentialPendingBalanceInstructionData> getApplyConfidentialPendingBalanceInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
    ('expectedPendingBalanceCreditCounter', getU64Decoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => ApplyConfidentialPendingBalanceInstructionData(
      discriminator: map['discriminator']! as int,
      confidentialTransferDiscriminator: map['confidentialTransferDiscriminator']! as int,
      expectedPendingBalanceCreditCounter: map['expectedPendingBalanceCreditCounter']! as BigInt,
      newDecryptableAvailableBalance: map['newDecryptableAvailableBalance']! as DecryptableBalance,
    ),
  );
}

Codec<ApplyConfidentialPendingBalanceInstructionData, ApplyConfidentialPendingBalanceInstructionData> getApplyConfidentialPendingBalanceInstructionDataCodec() {
  return combineCodec(getApplyConfidentialPendingBalanceInstructionDataEncoder(), getApplyConfidentialPendingBalanceInstructionDataDecoder());
}

/// Creates a [ApplyConfidentialPendingBalance] instruction.
Instruction getApplyConfidentialPendingBalanceInstruction({
  required Address programAddress,
  required Address token,
  required Address authority,
  required BigInt expectedPendingBalanceCreditCounter,
  required DecryptableBalance newDecryptableAvailableBalance,
}) {
  final instructionData = ApplyConfidentialPendingBalanceInstructionData(
      expectedPendingBalanceCreditCounter: expectedPendingBalanceCreditCounter,
      newDecryptableAvailableBalance: newDecryptableAvailableBalance,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: token, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getApplyConfidentialPendingBalanceInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ApplyConfidentialPendingBalance] instruction from raw instruction data.
ApplyConfidentialPendingBalanceInstructionData parseApplyConfidentialPendingBalanceInstruction(Instruction instruction) {
  return getApplyConfidentialPendingBalanceInstructionDataDecoder().decode(instruction.data!);
}
