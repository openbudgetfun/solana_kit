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
class WithdrawWithheldTokensFromMintInstructionData {
  const WithdrawWithheldTokensFromMintInstructionData({
    this.discriminator = 26,
    this.transferFeeDiscriminator = 2,
  });

  final int discriminator;
  final int transferFeeDiscriminator;
}

Encoder<WithdrawWithheldTokensFromMintInstructionData> getWithdrawWithheldTokensFromMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('transferFeeDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (WithdrawWithheldTokensFromMintInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'transferFeeDiscriminator': value.transferFeeDiscriminator,
    },
  );
}

Decoder<WithdrawWithheldTokensFromMintInstructionData> getWithdrawWithheldTokensFromMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('transferFeeDiscriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => WithdrawWithheldTokensFromMintInstructionData(
      discriminator: map['discriminator']! as int,
      transferFeeDiscriminator: map['transferFeeDiscriminator']! as int,
    ),
  );
}

Codec<WithdrawWithheldTokensFromMintInstructionData, WithdrawWithheldTokensFromMintInstructionData> getWithdrawWithheldTokensFromMintInstructionDataCodec() {
  return combineCodec(getWithdrawWithheldTokensFromMintInstructionDataEncoder(), getWithdrawWithheldTokensFromMintInstructionDataDecoder());
}

/// Creates a [WithdrawWithheldTokensFromMint] instruction.
Instruction getWithdrawWithheldTokensFromMintInstruction({
  required Address programAddress,
  required Address mint,
  required Address feeReceiver,
  required Address withdrawWithheldAuthority,

}) {
  final instructionData = WithdrawWithheldTokensFromMintInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: feeReceiver, role: AccountRole.writable),
    AccountMeta(address: withdrawWithheldAuthority, role: AccountRole.readonlySigner),
    ],
    data: getWithdrawWithheldTokensFromMintInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [WithdrawWithheldTokensFromMint] instruction from raw instruction data.
WithdrawWithheldTokensFromMintInstructionData parseWithdrawWithheldTokensFromMintInstruction(Instruction instruction) {
  return getWithdrawWithheldTokensFromMintInstructionDataDecoder().decode(instruction.data!);
}
