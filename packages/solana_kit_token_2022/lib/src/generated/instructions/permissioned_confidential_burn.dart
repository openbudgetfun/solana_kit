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

/// The discriminator field name: 'permissionedBurnDiscriminator'.
/// Offset: 1.

@immutable
class PermissionedConfidentialBurnInstructionData {
  const PermissionedConfidentialBurnInstructionData({
    this.discriminator = 46,
    this.permissionedBurnDiscriminator = 3,
    required this.newDecryptableAvailableBalance,
    required this.burnAmountAuditorCiphertextLo,
    required this.burnAmountAuditorCiphertextHi,
    required this.equalityProofInstructionOffset,
    required this.ciphertextValidityProofInstructionOffset,
    required this.rangeProofInstructionOffset,
  });

  final int discriminator;
  final int permissionedBurnDiscriminator;
  final DecryptableBalance newDecryptableAvailableBalance;
  final EncryptedBalance burnAmountAuditorCiphertextLo;
  final EncryptedBalance burnAmountAuditorCiphertextHi;
  final int equalityProofInstructionOffset;
  final int ciphertextValidityProofInstructionOffset;
  final int rangeProofInstructionOffset;
}

Encoder<PermissionedConfidentialBurnInstructionData>
getPermissionedConfidentialBurnInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('permissionedBurnDiscriminator', getU8Encoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceEncoder()),
    ('burnAmountAuditorCiphertextLo', getEncryptedBalanceEncoder()),
    ('burnAmountAuditorCiphertextHi', getEncryptedBalanceEncoder()),
    ('equalityProofInstructionOffset', getI8Encoder()),
    ('ciphertextValidityProofInstructionOffset', getI8Encoder()),
    ('rangeProofInstructionOffset', getI8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (PermissionedConfidentialBurnInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'permissionedBurnDiscriminator': value.permissionedBurnDiscriminator,
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

Decoder<PermissionedConfidentialBurnInstructionData>
getPermissionedConfidentialBurnInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('permissionedBurnDiscriminator', getU8Decoder()),
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
        PermissionedConfidentialBurnInstructionData(
          discriminator: map['discriminator']! as int,
          permissionedBurnDiscriminator:
              map['permissionedBurnDiscriminator']! as int,
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

Codec<
  PermissionedConfidentialBurnInstructionData,
  PermissionedConfidentialBurnInstructionData
>
getPermissionedConfidentialBurnInstructionDataCodec() {
  return combineCodec(
    getPermissionedConfidentialBurnInstructionDataEncoder(),
    getPermissionedConfidentialBurnInstructionDataDecoder(),
  );
}

/// Creates a [PermissionedConfidentialBurn] instruction.
Instruction getPermissionedConfidentialBurnInstruction({
  required Address programAddress,
  required Address token,
  required Address mint,
  Address? instructionsSysvar,
  Address? equalityRecord,
  Address? ciphertextValidityRecord,
  Address? rangeRecord,
  required Address permissionedBurnAuthority,
  required Address authority,
  required DecryptableBalance newDecryptableAvailableBalance,
  required EncryptedBalance burnAmountAuditorCiphertextLo,
  required EncryptedBalance burnAmountAuditorCiphertextHi,
  required int equalityProofInstructionOffset,
  required int ciphertextValidityProofInstructionOffset,
  required int rangeProofInstructionOffset,
}) {
  final instructionData = PermissionedConfidentialBurnInstructionData(
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
      AccountMeta(
        address: permissionedBurnAuthority,
        role: AccountRole.readonlySigner,
      ),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getPermissionedConfidentialBurnInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [PermissionedConfidentialBurn] instruction from raw instruction data.
PermissionedConfidentialBurnInstructionData
parsePermissionedConfidentialBurnInstruction(Instruction instruction) {
  return getPermissionedConfidentialBurnInstructionDataDecoder().decode(
    instruction.data!,
  );
}
