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

@immutable
class InitSubscriptionAuthorityInstructionData {
  const InitSubscriptionAuthorityInstructionData({
    this.discriminator = 0,
  });

  final int discriminator;
}

Encoder<InitSubscriptionAuthorityInstructionData> getInitSubscriptionAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitSubscriptionAuthorityInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<InitSubscriptionAuthorityInstructionData> getInitSubscriptionAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitSubscriptionAuthorityInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<InitSubscriptionAuthorityInstructionData, InitSubscriptionAuthorityInstructionData> getInitSubscriptionAuthorityInstructionDataCodec() {
  return combineCodec(getInitSubscriptionAuthorityInstructionDataEncoder(), getInitSubscriptionAuthorityInstructionDataDecoder());
}

/// Creates a [InitSubscriptionAuthority] instruction.
Instruction getInitSubscriptionAuthorityInstruction({
  required Address programAddress,
  required Address owner,
  required Address subscriptionAuthority,
  required Address tokenMint,
  required Address userAta,
  required Address systemProgram,
  required Address tokenProgram,
  Address? payer,

}) {
  final instructionData = InitSubscriptionAuthorityInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: owner, role: AccountRole.writableSigner),
    AccountMeta(address: subscriptionAuthority, role: AccountRole.writable),
    AccountMeta(address: tokenMint, role: AccountRole.readonly),
    AccountMeta(address: userAta, role: AccountRole.writable),
    AccountMeta(address: systemProgram, role: AccountRole.readonly),
    AccountMeta(address: tokenProgram, role: AccountRole.readonly),
    if (payer != null) AccountMeta(address: payer, role: AccountRole.writableSigner),
    ],
    data: getInitSubscriptionAuthorityInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitSubscriptionAuthority] instruction from raw instruction data.
InitSubscriptionAuthorityInstructionData parseInitSubscriptionAuthorityInstruction(Instruction instruction) {
  return getInitSubscriptionAuthorityInstructionDataDecoder().decode(instruction.data!);
}
