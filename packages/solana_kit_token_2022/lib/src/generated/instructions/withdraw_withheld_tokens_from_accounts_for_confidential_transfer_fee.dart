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
class WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData {
  const WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData({
    required this.numTokenAccounts,
    required this.proofInstructionOffset,
    required this.newDecryptableAvailableBalance,
  }) : discriminator = 37,
       confidentialTransferFeeDiscriminator = 2;

  final int discriminator;
  final int confidentialTransferFeeDiscriminator;
  final int numTokenAccounts;
  final int proofInstructionOffset;
  final DecryptableBalance newDecryptableAvailableBalance;
}

Encoder<
  WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData
>
getWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferFeeDiscriminator', getU8Encoder()),
    ('numTokenAccounts', getU8Encoder()),
    ('proofInstructionOffset', getI8Encoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (
      WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData
      value,
    ) => <String, Object?>{
      'discriminator': 37,
      'confidentialTransferFeeDiscriminator': 2,
      'numTokenAccounts': value.numTokenAccounts,
      'proofInstructionOffset': value.proofInstructionOffset,
      'newDecryptableAvailableBalance': value.newDecryptableAvailableBalance,
    },
  );
}

Decoder<
  WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData
>
getWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferFeeDiscriminator', getU8Decoder()),
    ('numTokenAccounts', getU8Decoder()),
    ('proofInstructionOffset', getI8Decoder()),
    ('newDecryptableAvailableBalance', getDecryptableBalanceDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'withdrawWithheldTokensFromAccountsForConfidentialTransferFee instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (
    WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData,
    int,
  )
  readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(37),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(2),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData(
        numTokenAccounts: map['numTokenAccounts']! as int,
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
        WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData
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
        WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData
      >(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData,
  WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData
>
getWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionDataCodec() {
  return combineCodec(
    getWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionDataEncoder(),
    getWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionDataDecoder(),
  );
}

/// Creates a [WithdrawWithheldTokensFromAccountsForConfidentialTransferFee] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction
getWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstruction({
  required Address programAddress,
  required Address mint,
  required Address destination,
  required Address instructionsSysvarOrContextState,
  required Address authority,
  required int numTokenAccounts,
  required int proofInstructionOffset,
  required DecryptableBalance newDecryptableAvailableBalance,
  bool authorityIsSigner = true,
}) {
  final instructionData =
      WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData(
        numTokenAccounts: numTokenAccounts,
        proofInstructionOffset: proofInstructionOffset,
        newDecryptableAvailableBalance: newDecryptableAvailableBalance,
      );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.readonly),
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
        getWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionDataEncoder()
            .encode(instructionData),
  );
}

/// Parses a [WithdrawWithheldTokensFromAccountsForConfidentialTransferFee] instruction from raw instruction data.
WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData
parseWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstruction(
  Instruction instruction,
) {
  return getWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionDataDecoder()
      .decode(instruction.data!);
}
