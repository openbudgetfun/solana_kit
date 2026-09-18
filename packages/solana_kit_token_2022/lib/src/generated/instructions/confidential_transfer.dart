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

/// The discriminator field name: 'confidentialTransferDiscriminator'.
/// Offset: 1.

@immutable
class ConfidentialTransferInstructionData {
  const ConfidentialTransferInstructionData({
    required this.newSourceDecryptableAvailableBalance,
    required this.transferAmountAuditorCiphertextLo,
    required this.transferAmountAuditorCiphertextHi,
    required this.equalityProofInstructionOffset,
    required this.ciphertextValidityProofInstructionOffset,
    required this.rangeProofInstructionOffset,
  }) : discriminator = 27,
       confidentialTransferDiscriminator = 7;

  final int discriminator;
  final int confidentialTransferDiscriminator;
  final DecryptableBalance newSourceDecryptableAvailableBalance;
  final EncryptedBalance transferAmountAuditorCiphertextLo;
  final EncryptedBalance transferAmountAuditorCiphertextHi;
  final int equalityProofInstructionOffset;
  final int ciphertextValidityProofInstructionOffset;
  final int rangeProofInstructionOffset;
}

Encoder<ConfidentialTransferInstructionData>
getConfidentialTransferInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
    ('newSourceDecryptableAvailableBalance', getDecryptableBalanceEncoder()),
    ('transferAmountAuditorCiphertextLo', getEncryptedBalanceEncoder()),
    ('transferAmountAuditorCiphertextHi', getEncryptedBalanceEncoder()),
    ('equalityProofInstructionOffset', getI8Encoder()),
    ('ciphertextValidityProofInstructionOffset', getI8Encoder()),
    ('rangeProofInstructionOffset', getI8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ConfidentialTransferInstructionData value) => <String, Object?>{
      'discriminator': 27,
      'confidentialTransferDiscriminator': 7,
      'newSourceDecryptableAvailableBalance':
          value.newSourceDecryptableAvailableBalance,
      'transferAmountAuditorCiphertextLo':
          value.transferAmountAuditorCiphertextLo,
      'transferAmountAuditorCiphertextHi':
          value.transferAmountAuditorCiphertextHi,
      'equalityProofInstructionOffset': value.equalityProofInstructionOffset,
      'ciphertextValidityProofInstructionOffset':
          value.ciphertextValidityProofInstructionOffset,
      'rangeProofInstructionOffset': value.rangeProofInstructionOffset,
    },
  );
}

Decoder<ConfidentialTransferInstructionData>
getConfidentialTransferInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
    ('newSourceDecryptableAvailableBalance', getDecryptableBalanceDecoder()),
    ('transferAmountAuditorCiphertextLo', getEncryptedBalanceDecoder()),
    ('transferAmountAuditorCiphertextHi', getEncryptedBalanceDecoder()),
    ('equalityProofInstructionOffset', getI8Decoder()),
    ('ciphertextValidityProofInstructionOffset', getI8Decoder()),
    ('rangeProofInstructionOffset', getI8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'confidentialTransfer instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ConfidentialTransferInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(27),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(7),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ConfidentialTransferInstructionData(
        newSourceDecryptableAvailableBalance:
            map['newSourceDecryptableAvailableBalance']! as DecryptableBalance,
        transferAmountAuditorCiphertextLo:
            map['transferAmountAuditorCiphertextLo']! as EncryptedBalance,
        transferAmountAuditorCiphertextHi:
            map['transferAmountAuditorCiphertextHi']! as EncryptedBalance,
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
      FixedSizeDecoder<ConfidentialTransferInstructionData>(
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
      VariableSizeDecoder<ConfidentialTransferInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ConfidentialTransferInstructionData, ConfidentialTransferInstructionData>
getConfidentialTransferInstructionDataCodec() {
  return combineCodec(
    getConfidentialTransferInstructionDataEncoder(),
    getConfidentialTransferInstructionDataDecoder(),
  );
}

/// Creates a [ConfidentialTransfer] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getConfidentialTransferInstruction({
  required Address programAddress,
  required Address sourceToken,
  required Address mint,
  required Address destinationToken,
  Address? instructionsSysvar,
  Address? equalityRecord,
  Address? ciphertextValidityRecord,
  Address? rangeRecord,
  required Address authority,
  required DecryptableBalance newSourceDecryptableAvailableBalance,
  required EncryptedBalance transferAmountAuditorCiphertextLo,
  required EncryptedBalance transferAmountAuditorCiphertextHi,
  required int equalityProofInstructionOffset,
  required int ciphertextValidityProofInstructionOffset,
  required int rangeProofInstructionOffset,
  bool authorityIsSigner = true,
}) {
  final instructionData = ConfidentialTransferInstructionData(
    newSourceDecryptableAvailableBalance: newSourceDecryptableAvailableBalance,
    transferAmountAuditorCiphertextLo: transferAmountAuditorCiphertextLo,
    transferAmountAuditorCiphertextHi: transferAmountAuditorCiphertextHi,
    equalityProofInstructionOffset: equalityProofInstructionOffset,
    ciphertextValidityProofInstructionOffset:
        ciphertextValidityProofInstructionOffset,
    rangeProofInstructionOffset: rangeProofInstructionOffset,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: sourceToken, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: destinationToken, role: AccountRole.writable),
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
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getConfidentialTransferInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ConfidentialTransfer] instruction from raw instruction data.
ConfidentialTransferInstructionData parseConfidentialTransferInstruction(
  Instruction instruction,
) {
  return getConfidentialTransferInstructionDataDecoder().decode(
    instruction.data!,
  );
}
