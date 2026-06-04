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
class ResumeSubscriptionInstructionData {
  const ResumeSubscriptionInstructionData({
    this.discriminator = 13,
  });

  final int discriminator;
}

Encoder<ResumeSubscriptionInstructionData>
getResumeSubscriptionInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ResumeSubscriptionInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<ResumeSubscriptionInstructionData>
getResumeSubscriptionInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        ResumeSubscriptionInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

Codec<ResumeSubscriptionInstructionData, ResumeSubscriptionInstructionData>
getResumeSubscriptionInstructionDataCodec() {
  return combineCodec(
    getResumeSubscriptionInstructionDataEncoder(),
    getResumeSubscriptionInstructionDataDecoder(),
  );
}

/// Creates a [ResumeSubscription] instruction.
Instruction getResumeSubscriptionInstruction({
  required Address programAddress,
  required Address subscriber,
  required Address planPda,
  required Address subscriptionPda,
  required Address eventAuthority,
  required Address selfProgram,
}) {
  final instructionData = ResumeSubscriptionInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: subscriber, role: AccountRole.readonlySigner),
      AccountMeta(address: planPda, role: AccountRole.readonly),
      AccountMeta(address: subscriptionPda, role: AccountRole.writable),
      AccountMeta(address: eventAuthority, role: AccountRole.readonly),
      AccountMeta(address: selfProgram, role: AccountRole.readonly),
    ],
    data: getResumeSubscriptionInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ResumeSubscription] instruction from raw instruction data.
ResumeSubscriptionInstructionData parseResumeSubscriptionInstruction(
  Instruction instruction,
) {
  return getResumeSubscriptionInstructionDataDecoder().decode(
    instruction.data!,
  );
}
