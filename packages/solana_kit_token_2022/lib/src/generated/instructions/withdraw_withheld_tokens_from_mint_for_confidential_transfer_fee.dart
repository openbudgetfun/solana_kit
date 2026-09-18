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

/// The discriminator field name: 'confidentialTransferFeeDiscriminator'.
/// Offset: 1.

@immutable
class WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData {
  const WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData({
    required this.proofInstructionOffset,
    required this.newDecryptableAvailableBalance,
  }) : discriminator = 37,
       confidentialTransferFeeDiscriminator = 1;

  final int discriminator;
  final int confidentialTransferFeeDiscriminator;
  final int proofInstructionOffset;
  final DecryptableBalance newDecryptableAvailableBalance;
}

Encoder<WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData>
getWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferFeeDiscriminator', getU8Encoder()),
    ('proofInstructionOffset', getI8Encoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (
      WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData
      value,
    ) => <String, Object?>{
      'discriminator': 37,
      'confidentialTransferFeeDiscriminator': 1,
      'proofInstructionOffset': value.proofInstructionOffset,
      'newDecryptableAvailableBalance': value.newDecryptableAvailableBalance,
    },
  );
}

Decoder<WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData>
getWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferFeeDiscriminator', getU8Decoder()),
    ('proofInstructionOffset', getI8Decoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'withdrawWithheldTokensFromMintForConfidentialTransferFee instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData, int)
  readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(37),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(1),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData(
        proofInstructionOffset: map['proofInstructionOffset']! as int,
        newDecryptableAvailableBalance:
            map['newDecryptableAvailableBalance']! as DecryptableBalance,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<
        WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData
      >(
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
      VariableSizeDecoder<
        WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData
      >(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData,
  WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData
>
getWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionDataCodec() {
  return combineCodec(
    getWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionDataEncoder(),
    getWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionDataDecoder(),
  );
}

/// Creates a [WithdrawWithheldTokensFromMintForConfidentialTransferFee] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction
getWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstruction({
  required Address programAddress,
  required Address mint,
  required Address destination,
  required Address instructionsSysvarOrContextState,
  required Address authority,
  required int proofInstructionOffset,
  required DecryptableBalance newDecryptableAvailableBalance,
  bool authorityIsSigner = true,
}) {
  final instructionData =
      WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData(
        proofInstructionOffset: proofInstructionOffset,
        newDecryptableAvailableBalance: newDecryptableAvailableBalance,
      );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: destination, role: AccountRole.writable),
      AccountMeta(
        address: instructionsSysvarOrContextState,
        role: AccountRole.readonly,
      ),
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data:
        getWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionDataEncoder()
            .encode(instructionData),
  );
}

/// Parses a [WithdrawWithheldTokensFromMintForConfidentialTransferFee] instruction from raw instruction data.
WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData
parseWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstruction(
  Instruction instruction,
) {
  return getWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionDataDecoder()
      .decode(instruction.data!);
}
