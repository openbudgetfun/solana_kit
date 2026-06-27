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
class CancelSubscriptionInstructionData {
  const CancelSubscriptionInstructionData({
    this.discriminator = 12,
  });

  final int discriminator;
}

Encoder<CancelSubscriptionInstructionData> getCancelSubscriptionInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CancelSubscriptionInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<CancelSubscriptionInstructionData> getCancelSubscriptionInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => CancelSubscriptionInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<CancelSubscriptionInstructionData, CancelSubscriptionInstructionData> getCancelSubscriptionInstructionDataCodec() {
  return combineCodec(getCancelSubscriptionInstructionDataEncoder(), getCancelSubscriptionInstructionDataDecoder());
}

/// Creates a [CancelSubscription] instruction.
Instruction getCancelSubscriptionInstruction({
  required Address programAddress,
  required Address subscriber,
  required Address planPda,
  required Address subscriptionPda,
  required Address eventAuthority,
  required Address selfProgram,

}) {
  final instructionData = CancelSubscriptionInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: subscriber, role: AccountRole.readonlySigner),
    AccountMeta(address: planPda, role: AccountRole.readonly),
    AccountMeta(address: subscriptionPda, role: AccountRole.writable),
    AccountMeta(address: eventAuthority, role: AccountRole.readonly),
    AccountMeta(address: selfProgram, role: AccountRole.readonly),
    ],
    data: getCancelSubscriptionInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CancelSubscription] instruction from raw instruction data.
CancelSubscriptionInstructionData parseCancelSubscriptionInstruction(Instruction instruction) {
  return getCancelSubscriptionInstructionDataDecoder().decode(instruction.data!);
}
