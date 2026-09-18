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
class ApplyConfidentialPendingBalanceInstructionData {
  const ApplyConfidentialPendingBalanceInstructionData({
    required this.expectedPendingBalanceCreditCounter,
    required this.newDecryptableAvailableBalance,
  }) : discriminator = 27,
       confidentialTransferDiscriminator = 8;

  final int discriminator;
  final int confidentialTransferDiscriminator;
  final BigInt expectedPendingBalanceCreditCounter;
  final DecryptableBalance newDecryptableAvailableBalance;
}

Encoder<ApplyConfidentialPendingBalanceInstructionData>
getApplyConfidentialPendingBalanceInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
    ('expectedPendingBalanceCreditCounter', getU64Encoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ApplyConfidentialPendingBalanceInstructionData value) => <String, Object?>{
      'discriminator': 27,
      'confidentialTransferDiscriminator': 8,
      'expectedPendingBalanceCreditCounter':
          value.expectedPendingBalanceCreditCounter,
      'newDecryptableAvailableBalance': value.newDecryptableAvailableBalance,
    },
  );
}

Decoder<ApplyConfidentialPendingBalanceInstructionData>
getApplyConfidentialPendingBalanceInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
    ('expectedPendingBalanceCreditCounter', getU64Decoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'applyConfidentialPendingBalance instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ApplyConfidentialPendingBalanceInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(27),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(8),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ApplyConfidentialPendingBalanceInstructionData(
        expectedPendingBalanceCreditCounter:
            map['expectedPendingBalanceCreditCounter']! as BigInt,
        newDecryptableAvailableBalance:
            map['newDecryptableAvailableBalance']! as DecryptableBalance,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ApplyConfidentialPendingBalanceInstructionData>(
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
      VariableSizeDecoder<ApplyConfidentialPendingBalanceInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  ApplyConfidentialPendingBalanceInstructionData,
  ApplyConfidentialPendingBalanceInstructionData
>
getApplyConfidentialPendingBalanceInstructionDataCodec() {
  return combineCodec(
    getApplyConfidentialPendingBalanceInstructionDataEncoder(),
    getApplyConfidentialPendingBalanceInstructionDataDecoder(),
  );
}

/// Creates a [ApplyConfidentialPendingBalance] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getApplyConfidentialPendingBalanceInstruction({
  required Address programAddress,
  required Address token,
  required Address authority,
  required BigInt expectedPendingBalanceCreditCounter,
  required DecryptableBalance newDecryptableAvailableBalance,
  bool authorityIsSigner = true,
}) {
  final instructionData = ApplyConfidentialPendingBalanceInstructionData(
    expectedPendingBalanceCreditCounter: expectedPendingBalanceCreditCounter,
    newDecryptableAvailableBalance: newDecryptableAvailableBalance,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getApplyConfidentialPendingBalanceInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ApplyConfidentialPendingBalance] instruction from raw instruction data.
ApplyConfidentialPendingBalanceInstructionData
parseApplyConfidentialPendingBalanceInstruction(Instruction instruction) {
  return getApplyConfidentialPendingBalanceInstructionDataDecoder().decode(
    instruction.data!,
  );
}
