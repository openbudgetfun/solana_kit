// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/resume_data.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class ResumeSubscriptionInstructionData {
  const ResumeSubscriptionInstructionData({
    this.discriminator = 13,
    required this.resumeData,
  });

  final int discriminator;
  final ResumeData resumeData;
}

Encoder<ResumeSubscriptionInstructionData>
getResumeSubscriptionInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('resumeData', getResumeDataEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ResumeSubscriptionInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'resumeData': value.resumeData,
    },
  );
}

Decoder<ResumeSubscriptionInstructionData>
getResumeSubscriptionInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('resumeData', getResumeDataDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        ResumeSubscriptionInstructionData(
          discriminator: map['discriminator']! as int,
          resumeData: map['resumeData']! as ResumeData,
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
  required Address subscriptionAuthority,
  required Address eventAuthority,
  required Address selfProgram,
  required ResumeData resumeData,
}) {
  final instructionData = ResumeSubscriptionInstructionData(
    resumeData: resumeData,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: subscriber, role: AccountRole.readonlySigner),
      AccountMeta(address: planPda, role: AccountRole.readonly),
      AccountMeta(address: subscriptionPda, role: AccountRole.writable),
      AccountMeta(address: subscriptionAuthority, role: AccountRole.readonly),
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
