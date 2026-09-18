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

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

/// The discriminator field name: 'transferFeeDiscriminator'.
/// Offset: 1.

@immutable
class WithdrawWithheldTokensFromAccountsInstructionData {
  const WithdrawWithheldTokensFromAccountsInstructionData({
    required this.numTokenAccounts,
  }) : discriminator = 26,
       transferFeeDiscriminator = 3;

  final int discriminator;
  final int transferFeeDiscriminator;
  final int numTokenAccounts;
}

Encoder<WithdrawWithheldTokensFromAccountsInstructionData>
getWithdrawWithheldTokensFromAccountsInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('transferFeeDiscriminator', getU8Encoder()),
    ('numTokenAccounts', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (WithdrawWithheldTokensFromAccountsInstructionData value) =>
        <String, Object?>{
          'discriminator': 26,
          'transferFeeDiscriminator': 3,
          'numTokenAccounts': value.numTokenAccounts,
        },
  );
}

Decoder<WithdrawWithheldTokensFromAccountsInstructionData>
getWithdrawWithheldTokensFromAccountsInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('transferFeeDiscriminator', getU8Decoder()),
    ('numTokenAccounts', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'withdrawWithheldTokensFromAccounts instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (WithdrawWithheldTokensFromAccountsInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(26),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(3),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      WithdrawWithheldTokensFromAccountsInstructionData(
        numTokenAccounts: map['numTokenAccounts']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<WithdrawWithheldTokensFromAccountsInstructionData>(
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
      VariableSizeDecoder<WithdrawWithheldTokensFromAccountsInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  WithdrawWithheldTokensFromAccountsInstructionData,
  WithdrawWithheldTokensFromAccountsInstructionData
>
getWithdrawWithheldTokensFromAccountsInstructionDataCodec() {
  return combineCodec(
    getWithdrawWithheldTokensFromAccountsInstructionDataEncoder(),
    getWithdrawWithheldTokensFromAccountsInstructionDataDecoder(),
  );
}

/// Creates a [WithdrawWithheldTokensFromAccounts] instruction.
/// Set [withdrawWithheldAuthorityIsSigner] to false when [withdrawWithheldAuthority] does not sign (for example, a multisig authority).
Instruction getWithdrawWithheldTokensFromAccountsInstruction({
  required Address programAddress,
  required Address mint,
  required Address feeReceiver,
  required Address withdrawWithheldAuthority,
  required int numTokenAccounts,
  bool withdrawWithheldAuthorityIsSigner = true,
}) {
  final instructionData = WithdrawWithheldTokensFromAccountsInstructionData(
    numTokenAccounts: numTokenAccounts,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: feeReceiver, role: AccountRole.writable),
      AccountMeta(
        address: withdrawWithheldAuthority,
        role: withdrawWithheldAuthorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getWithdrawWithheldTokensFromAccountsInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [WithdrawWithheldTokensFromAccounts] instruction from raw instruction data.
WithdrawWithheldTokensFromAccountsInstructionData
parseWithdrawWithheldTokensFromAccountsInstruction(Instruction instruction) {
  return getWithdrawWithheldTokensFromAccountsInstructionDataDecoder().decode(
    instruction.data!,
  );
}
