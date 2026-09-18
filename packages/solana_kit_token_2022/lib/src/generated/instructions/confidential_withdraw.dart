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

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

/// The discriminator field name: 'confidentialTransferDiscriminator'.
/// Offset: 1.

@immutable
class ConfidentialWithdrawInstructionData {
  const ConfidentialWithdrawInstructionData({
    required this.amount,
    required this.decimals,
    required this.newDecryptableAvailableBalance,
    required this.equalityProofInstructionOffset,
    required this.rangeProofInstructionOffset,
  }) : discriminator = 27,
       confidentialTransferDiscriminator = 6;

  final int discriminator;
  final int confidentialTransferDiscriminator;
  final BigInt amount;
  final int decimals;
  final DecryptableBalance newDecryptableAvailableBalance;
  final int equalityProofInstructionOffset;
  final int rangeProofInstructionOffset;
}

Encoder<ConfidentialWithdrawInstructionData>
getConfidentialWithdrawInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
    ('decimals', getU8Encoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceEncoder()),
    ('equalityProofInstructionOffset', getI8Encoder()),
    ('rangeProofInstructionOffset', getI8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ConfidentialWithdrawInstructionData value) => <String, Object?>{
      'discriminator': 27,
      'confidentialTransferDiscriminator': 6,
      'amount': value.amount,
      'decimals': value.decimals,
      'newDecryptableAvailableBalance': value.newDecryptableAvailableBalance,
      'equalityProofInstructionOffset': value.equalityProofInstructionOffset,
      'rangeProofInstructionOffset': value.rangeProofInstructionOffset,
    },
  );
}

Decoder<ConfidentialWithdrawInstructionData>
getConfidentialWithdrawInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
    ('decimals', getU8Decoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceDecoder()),
    ('equalityProofInstructionOffset', getI8Decoder()),
    ('rangeProofInstructionOffset', getI8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'confidentialWithdraw instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ConfidentialWithdrawInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(27),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(6),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ConfidentialWithdrawInstructionData(
        amount: map['amount']! as BigInt,
        decimals: map['decimals']! as int,
        newDecryptableAvailableBalance:
            map['newDecryptableAvailableBalance']! as DecryptableBalance,
        equalityProofInstructionOffset:
            map['equalityProofInstructionOffset']! as int,
        rangeProofInstructionOffset: map['rangeProofInstructionOffset']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ConfidentialWithdrawInstructionData>(
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
      VariableSizeDecoder<ConfidentialWithdrawInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ConfidentialWithdrawInstructionData, ConfidentialWithdrawInstructionData>
getConfidentialWithdrawInstructionDataCodec() {
  return combineCodec(
    getConfidentialWithdrawInstructionDataEncoder(),
    getConfidentialWithdrawInstructionDataDecoder(),
  );
}

/// Creates a [ConfidentialWithdraw] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getConfidentialWithdrawInstruction({
  required Address programAddress,
  required Address token,
  required Address mint,
  Address? instructionsSysvar,
  Address? equalityRecord,
  Address? rangeRecord,
  required Address authority,
  required BigInt amount,
  required int decimals,
  required DecryptableBalance newDecryptableAvailableBalance,
  required int equalityProofInstructionOffset,
  required int rangeProofInstructionOffset,
  bool authorityIsSigner = true,
}) {
  final instructionData = ConfidentialWithdrawInstructionData(
    amount: amount,
    decimals: decimals,
    newDecryptableAvailableBalance: newDecryptableAvailableBalance,
    equalityProofInstructionOffset: equalityProofInstructionOffset,
    rangeProofInstructionOffset: rangeProofInstructionOffset,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
      if (instructionsSysvar != null)
        AccountMeta(address: instructionsSysvar, role: AccountRole.readonly),
      if (equalityRecord != null)
        AccountMeta(address: equalityRecord, role: AccountRole.readonly),
      if (rangeRecord != null)
        AccountMeta(address: rangeRecord, role: AccountRole.readonly),
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getConfidentialWithdrawInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ConfidentialWithdraw] instruction from raw instruction data.
ConfidentialWithdrawInstructionData parseConfidentialWithdrawInstruction(
  Instruction instruction,
) {
  return getConfidentialWithdrawInstructionDataDecoder().decode(
    instruction.data!,
  );
}
