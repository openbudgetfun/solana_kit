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
class ConfidentialMintInstructionData {
  const ConfidentialMintInstructionData({
    this.discriminator = 42,
    this.confidentialMintBurnDiscriminator = 3,
    required this.newDecryptableSupply,
    required this.mintAmountAuditorCiphertextLo,
    required this.mintAmountAuditorCiphertextHi,
    required this.equalityProofInstructionOffset,
    required this.ciphertextValidityProofInstructionOffset,
    required this.rangeProofInstructionOffset,
  });

  final int discriminator;
  final int confidentialMintBurnDiscriminator;
  final DecryptableBalance newDecryptableSupply;
  final EncryptedBalance mintAmountAuditorCiphertextLo;
  final EncryptedBalance mintAmountAuditorCiphertextHi;
  final int equalityProofInstructionOffset;
  final int ciphertextValidityProofInstructionOffset;
  final int rangeProofInstructionOffset;
}

Encoder<ConfidentialMintInstructionData>
getConfidentialMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialMintBurnDiscriminator', getU8Encoder()),
    ('newDecryptableSupply', getDecryptableBalanceEncoder()),
    ('mintAmountAuditorCiphertextLo', getEncryptedBalanceEncoder()),
    ('mintAmountAuditorCiphertextHi', getEncryptedBalanceEncoder()),
    ('equalityProofInstructionOffset', getI8Encoder()),
    ('ciphertextValidityProofInstructionOffset', getI8Encoder()),
    ('rangeProofInstructionOffset', getI8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ConfidentialMintInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialMintBurnDiscriminator':
          value.confidentialMintBurnDiscriminator,
      'newDecryptableSupply': value.newDecryptableSupply,
      'mintAmountAuditorCiphertextLo': value.mintAmountAuditorCiphertextLo,
      'mintAmountAuditorCiphertextHi': value.mintAmountAuditorCiphertextHi,
      'equalityProofInstructionOffset': value.equalityProofInstructionOffset,
      'ciphertextValidityProofInstructionOffset':
          value.ciphertextValidityProofInstructionOffset,
      'rangeProofInstructionOffset': value.rangeProofInstructionOffset,
    },
  );
}

Decoder<ConfidentialMintInstructionData>
getConfidentialMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialMintBurnDiscriminator', getU8Decoder()),
    ('newDecryptableSupply', getDecryptableBalanceDecoder()),
    ('mintAmountAuditorCiphertextLo', getEncryptedBalanceDecoder()),
    ('mintAmountAuditorCiphertextHi', getEncryptedBalanceDecoder()),
    ('equalityProofInstructionOffset', getI8Decoder()),
    ('ciphertextValidityProofInstructionOffset', getI8Decoder()),
    ('rangeProofInstructionOffset', getI8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (
      Map<String, Object?> map,
      Uint8List bytes,
      int offset,
    ) => ConfidentialMintInstructionData(
      discriminator: map['discriminator']! as int,
      confidentialMintBurnDiscriminator:
          map['confidentialMintBurnDiscriminator']! as int,
      newDecryptableSupply: map['newDecryptableSupply']! as DecryptableBalance,
      mintAmountAuditorCiphertextLo:
          map['mintAmountAuditorCiphertextLo']! as EncryptedBalance,
      mintAmountAuditorCiphertextHi:
          map['mintAmountAuditorCiphertextHi']! as EncryptedBalance,
      equalityProofInstructionOffset:
          map['equalityProofInstructionOffset']! as int,
      ciphertextValidityProofInstructionOffset:
          map['ciphertextValidityProofInstructionOffset']! as int,
      rangeProofInstructionOffset: map['rangeProofInstructionOffset']! as int,
    ),
  );
}

Codec<ConfidentialMintInstructionData, ConfidentialMintInstructionData>
getConfidentialMintInstructionDataCodec() {
  return combineCodec(
    getConfidentialMintInstructionDataEncoder(),
    getConfidentialMintInstructionDataDecoder(),
  );
}

/// Creates a [ConfidentialMint] instruction.
Instruction getConfidentialMintInstruction({
  required Address programAddress,
  required Address token,
  required Address mint,
  Address? instructionsSysvar,
  Address? equalityRecord,
  Address? ciphertextValidityRecord,
  Address? rangeRecord,
  required Address authority,
  required DecryptableBalance newDecryptableSupply,
  required EncryptedBalance mintAmountAuditorCiphertextLo,
  required EncryptedBalance mintAmountAuditorCiphertextHi,
  required int equalityProofInstructionOffset,
  required int ciphertextValidityProofInstructionOffset,
  required int rangeProofInstructionOffset,
}) {
  final instructionData = ConfidentialMintInstructionData(
    newDecryptableSupply: newDecryptableSupply,
    mintAmountAuditorCiphertextLo: mintAmountAuditorCiphertextLo,
    mintAmountAuditorCiphertextHi: mintAmountAuditorCiphertextHi,
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
    data: getConfidentialMintInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ConfidentialMint] instruction from raw instruction data.
ConfidentialMintInstructionData parseConfidentialMintInstruction(
  Instruction instruction,
) {
  return getConfidentialMintInstructionDataDecoder().decode(instruction.data!);
}
