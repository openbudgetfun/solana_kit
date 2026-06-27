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
class RevokeAbandonedSubscriptionInstructionData {
  const RevokeAbandonedSubscriptionInstructionData({
    this.discriminator = 16,
  });

  final int discriminator;
}

Encoder<RevokeAbandonedSubscriptionInstructionData> getRevokeAbandonedSubscriptionInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RevokeAbandonedSubscriptionInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<RevokeAbandonedSubscriptionInstructionData> getRevokeAbandonedSubscriptionInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => RevokeAbandonedSubscriptionInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<RevokeAbandonedSubscriptionInstructionData, RevokeAbandonedSubscriptionInstructionData> getRevokeAbandonedSubscriptionInstructionDataCodec() {
  return combineCodec(getRevokeAbandonedSubscriptionInstructionDataEncoder(), getRevokeAbandonedSubscriptionInstructionDataDecoder());
}

/// Creates a [RevokeAbandonedSubscription] instruction.
Instruction getRevokeAbandonedSubscriptionInstruction({
  required Address programAddress,
  required Address payer,
  required Address subscriptionAccount,
  required Address subscriptionAuthority,
  required Address planPda,

}) {
  final instructionData = RevokeAbandonedSubscriptionInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: payer, role: AccountRole.writableSigner),
    AccountMeta(address: subscriptionAccount, role: AccountRole.writable),
    AccountMeta(address: subscriptionAuthority, role: AccountRole.readonly),
    AccountMeta(address: planPda, role: AccountRole.readonly),
    ],
    data: getRevokeAbandonedSubscriptionInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [RevokeAbandonedSubscription] instruction from raw instruction data.
RevokeAbandonedSubscriptionInstructionData parseRevokeAbandonedSubscriptionInstruction(Instruction instruction) {
  return getRevokeAbandonedSubscriptionInstructionDataDecoder().decode(instruction.data!);
}
