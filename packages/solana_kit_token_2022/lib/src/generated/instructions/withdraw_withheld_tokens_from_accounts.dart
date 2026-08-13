// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

/// The discriminator field name: 'transferFeeDiscriminator'.
/// Offset: 1.

@immutable
class WithdrawWithheldTokensFromAccountsInstructionData {
  const WithdrawWithheldTokensFromAccountsInstructionData({
    this.discriminator = 26,
    this.transferFeeDiscriminator = 3,
    required this.numTokenAccounts,
  });

  final int discriminator;
  final int transferFeeDiscriminator;
  final int numTokenAccounts;
}

Encoder<WithdrawWithheldTokensFromAccountsInstructionData> getWithdrawWithheldTokensFromAccountsInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('transferFeeDiscriminator', getU8Encoder()),
    ('numTokenAccounts', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (WithdrawWithheldTokensFromAccountsInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'transferFeeDiscriminator': value.transferFeeDiscriminator,
      'numTokenAccounts': value.numTokenAccounts,
    },
  );
}

Decoder<WithdrawWithheldTokensFromAccountsInstructionData> getWithdrawWithheldTokensFromAccountsInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('transferFeeDiscriminator', getU8Decoder()),
    ('numTokenAccounts', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => WithdrawWithheldTokensFromAccountsInstructionData(
      discriminator: map['discriminator']! as int,
      transferFeeDiscriminator: map['transferFeeDiscriminator']! as int,
      numTokenAccounts: map['numTokenAccounts']! as int,
    ),
  );
}

Codec<WithdrawWithheldTokensFromAccountsInstructionData, WithdrawWithheldTokensFromAccountsInstructionData> getWithdrawWithheldTokensFromAccountsInstructionDataCodec() {
  return combineCodec(getWithdrawWithheldTokensFromAccountsInstructionDataEncoder(), getWithdrawWithheldTokensFromAccountsInstructionDataDecoder());
}

/// Creates a [WithdrawWithheldTokensFromAccounts] instruction.
Instruction getWithdrawWithheldTokensFromAccountsInstruction({
  required Address programAddress,
  required Address mint,
  required Address feeReceiver,
  required Address withdrawWithheldAuthority,
  required int numTokenAccounts,
}) {
  final instructionData = WithdrawWithheldTokensFromAccountsInstructionData(
      numTokenAccounts: numTokenAccounts,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.readonly),
    AccountMeta(address: feeReceiver, role: AccountRole.writable),
    AccountMeta(address: withdrawWithheldAuthority, role: AccountRole.readonlySigner),
    ],
    data: getWithdrawWithheldTokensFromAccountsInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [WithdrawWithheldTokensFromAccounts] instruction from raw instruction data.
WithdrawWithheldTokensFromAccountsInstructionData parseWithdrawWithheldTokensFromAccountsInstruction(Instruction instruction) {
  return getWithdrawWithheldTokensFromAccountsInstructionDataDecoder().decode(instruction.data!);
}
