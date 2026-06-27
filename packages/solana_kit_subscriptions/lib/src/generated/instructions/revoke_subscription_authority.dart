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
class RevokeSubscriptionAuthorityInstructionData {
  const RevokeSubscriptionAuthorityInstructionData({
    this.discriminator = 14,
  });

  final int discriminator;
}

Encoder<RevokeSubscriptionAuthorityInstructionData> getRevokeSubscriptionAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RevokeSubscriptionAuthorityInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<RevokeSubscriptionAuthorityInstructionData> getRevokeSubscriptionAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => RevokeSubscriptionAuthorityInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<RevokeSubscriptionAuthorityInstructionData, RevokeSubscriptionAuthorityInstructionData> getRevokeSubscriptionAuthorityInstructionDataCodec() {
  return combineCodec(getRevokeSubscriptionAuthorityInstructionDataEncoder(), getRevokeSubscriptionAuthorityInstructionDataDecoder());
}

/// Creates a [RevokeSubscriptionAuthority] instruction.
Instruction getRevokeSubscriptionAuthorityInstruction({
  required Address programAddress,
  required Address user,
  required Address userAta,
  required Address tokenMint,
  required Address tokenProgram,
  required Address subscriptionAuthority,
  Address? receiver,

}) {
  final instructionData = RevokeSubscriptionAuthorityInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: user, role: AccountRole.writableSigner),
    AccountMeta(address: userAta, role: AccountRole.writable),
    AccountMeta(address: tokenMint, role: AccountRole.readonly),
    AccountMeta(address: tokenProgram, role: AccountRole.readonly),
    AccountMeta(address: subscriptionAuthority, role: AccountRole.writable),
    if (receiver != null) AccountMeta(address: receiver, role: AccountRole.writable),
    ],
    data: getRevokeSubscriptionAuthorityInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [RevokeSubscriptionAuthority] instruction from raw instruction data.
RevokeSubscriptionAuthorityInstructionData parseRevokeSubscriptionAuthorityInstruction(Instruction instruction) {
  return getRevokeSubscriptionAuthorityInstructionDataDecoder().decode(instruction.data!);
}
