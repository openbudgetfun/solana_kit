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
import '../types/encrypted_balance.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

/// The discriminator field name: 'confidentialMintBurnDiscriminator'.
/// Offset: 1.

@immutable
class ConfidentialBurnInstructionData {
  const ConfidentialBurnInstructionData({
    this.discriminator = 42,
    this.confidentialMintBurnDiscriminator = 4,
    required this.newDecryptableAvailableBalance,
    required this.burnAmountAuditorCiphertextLo,
    required this.burnAmountAuditorCiphertextHi,
    required this.equalityProofInstructionOffset,
    required this.ciphertextValidityProofInstructionOffset,
    required this.rangeProofInstructionOffset,
  });

  final int discriminator;
  final int confidentialMintBurnDiscriminator;
  final DecryptableBalance newDecryptableAvailableBalance;
  final EncryptedBalance burnAmountAuditorCiphertextLo;
  final EncryptedBalance burnAmountAuditorCiphertextHi;
  final int equalityProofInstructionOffset;
  final int ciphertextValidityProofInstructionOffset;
  final int rangeProofInstructionOffset;
}

Encoder<ConfidentialBurnInstructionData>
getConfidentialBurnInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialMintBurnDiscriminator', getU8Encoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceEncoder()),
    ('burnAmountAuditorCiphertextLo', getEncryptedBalanceEncoder()),
    ('burnAmountAuditorCiphertextHi', getEncryptedBalanceEncoder()),
    ('equalityProofInstructionOffset', getI8Encoder()),
    ('ciphertextValidityProofInstructionOffset', getI8Encoder()),
    ('rangeProofInstructionOffset', getI8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ConfidentialBurnInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialMintBurnDiscriminator':
          value.confidentialMintBurnDiscriminator,
      'newDecryptableAvailableBalance': value.newDecryptableAvailableBalance,
      'burnAmountAuditorCiphertextLo': value.burnAmountAuditorCiphertextLo,
      'burnAmountAuditorCiphertextHi': value.burnAmountAuditorCiphertextHi,
      'equalityProofInstructionOffset': value.equalityProofInstructionOffset,
      'ciphertextValidityProofInstructionOffset':
          value.ciphertextValidityProofInstructionOffset,
      'rangeProofInstructionOffset': value.rangeProofInstructionOffset,
    },
  );
}

Decoder<ConfidentialBurnInstructionData>
getConfidentialBurnInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialMintBurnDiscriminator', getU8Decoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceDecoder()),
    ('burnAmountAuditorCiphertextLo', getEncryptedBalanceDecoder()),
    ('burnAmountAuditorCiphertextHi', getEncryptedBalanceDecoder()),
    ('equalityProofInstructionOffset', getI8Decoder()),
    ('ciphertextValidityProofInstructionOffset', getI8Decoder()),
    ('rangeProofInstructionOffset', getI8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        ConfidentialBurnInstructionData(
          discriminator: map['discriminator']! as int,
          confidentialMintBurnDiscriminator:
              map['confidentialMintBurnDiscriminator']! as int,
          newDecryptableAvailableBalance:
              map['newDecryptableAvailableBalance']! as DecryptableBalance,
          burnAmountAuditorCiphertextLo:
              map['burnAmountAuditorCiphertextLo']! as EncryptedBalance,
          burnAmountAuditorCiphertextHi:
              map['burnAmountAuditorCiphertextHi']! as EncryptedBalance,
          equalityProofInstructionOffset:
              map['equalityProofInstructionOffset']! as int,
          ciphertextValidityProofInstructionOffset:
              map['ciphertextValidityProofInstructionOffset']! as int,
          rangeProofInstructionOffset:
              map['rangeProofInstructionOffset']! as int,
        ),
  );
}

Codec<ConfidentialBurnInstructionData, ConfidentialBurnInstructionData>
getConfidentialBurnInstructionDataCodec() {
  return combineCodec(
    getConfidentialBurnInstructionDataEncoder(),
    getConfidentialBurnInstructionDataDecoder(),
  );
}

/// Creates a [ConfidentialBurn] instruction.
Instruction getConfidentialBurnInstruction({
  required Address programAddress,
  required Address token,
  required Address mint,
  Address? instructionsSysvar,
  Address? equalityRecord,
  Address? ciphertextValidityRecord,
  Address? rangeRecord,
  required Address authority,
  required DecryptableBalance newDecryptableAvailableBalance,
  required EncryptedBalance burnAmountAuditorCiphertextLo,
  required EncryptedBalance burnAmountAuditorCiphertextHi,
  required int equalityProofInstructionOffset,
  required int ciphertextValidityProofInstructionOffset,
  required int rangeProofInstructionOffset,
}) {
  final instructionData = ConfidentialBurnInstructionData(
    newDecryptableAvailableBalance: newDecryptableAvailableBalance,
    burnAmountAuditorCiphertextLo: burnAmountAuditorCiphertextLo,
    burnAmountAuditorCiphertextHi: burnAmountAuditorCiphertextHi,
    equalityProofInstructionOffset: equalityProofInstructionOffset,
    ciphertextValidityProofInstructionOffset:
        ciphertextValidityProofInstructionOffset,
    rangeProofInstructionOffset: rangeProofInstructionOffset,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.writable),
      if (instructionsSysvar != null)
        AccountMeta(address: instructionsSysvar, role: AccountRole.readonly),
      if (equalityRecord != null)
        AccountMeta(address: equalityRecord, role: AccountRole.readonly),
      if (ciphertextValidityRecord != null)
        AccountMeta(
          address: ciphertextValidityRecord,
          role: AccountRole.readonly,
        ),
      if (rangeRecord != null)
        AccountMeta(address: rangeRecord, role: AccountRole.readonly),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getConfidentialBurnInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ConfidentialBurn] instruction from raw instruction data.
ConfidentialBurnInstructionData parseConfidentialBurnInstruction(
  Instruction instruction,
) {
  return getConfidentialBurnInstructionDataDecoder().decode(instruction.data!);
}
