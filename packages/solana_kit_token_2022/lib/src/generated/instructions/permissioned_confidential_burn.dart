// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
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
    required this.newDecryptableAvailableBalance,
    required this.burnAmountAuditorCiphertextLo,
    required this.burnAmountAuditorCiphertextHi,
    required this.equalityProofInstructionOffset,
    required this.ciphertextValidityProofInstructionOffset,
    required this.rangeProofInstructionOffset,
  }) : discriminator = 46,
       permissionedBurnDiscriminator = 3;

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
      'discriminator': 46,
      'permissionedBurnDiscriminator': 3,
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

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'permissionedConfidentialBurn instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (PermissionedConfidentialBurnInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(46),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(3),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      PermissionedConfidentialBurnInstructionData(
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
        rangeProofInstructionOffset: map['rangeProofInstructionOffset']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<PermissionedConfidentialBurnInstructionData>(
        fixedSize: structDecoder.fixedSize,
        read: (bytes, offset) {
          final bytesLength = bytes.length - offset;
          if (bytesLength != structDecoder.fixedSize) {
            throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
          }
          return readTopLevel(bytes, offset);
        },
      ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<PermissionedConfidentialBurnInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
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
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
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
  bool authorityIsSigner = true,
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
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
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
