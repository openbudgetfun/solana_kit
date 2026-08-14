// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/cancel_subscription_now_data.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class CancelSubscriptionNowInstructionData {
  const CancelSubscriptionNowInstructionData({
    this.discriminator = 17,
    required this.cancelSubscriptionNowData,
  });

  final int discriminator;
  final CancelSubscriptionNowData cancelSubscriptionNowData;
}

Encoder<CancelSubscriptionNowInstructionData>
getCancelSubscriptionNowInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('cancelSubscriptionNowData', getCancelSubscriptionNowDataEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CancelSubscriptionNowInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'cancelSubscriptionNowData': value.cancelSubscriptionNowData,
    },
  );
}

Decoder<CancelSubscriptionNowInstructionData>
getCancelSubscriptionNowInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('cancelSubscriptionNowData', getCancelSubscriptionNowDataDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CancelSubscriptionNowInstructionData(
          discriminator: map['discriminator']! as int,
          cancelSubscriptionNowData:
              map['cancelSubscriptionNowData']! as CancelSubscriptionNowData,
        ),
  );
}

Codec<
  CancelSubscriptionNowInstructionData,
  CancelSubscriptionNowInstructionData
>
getCancelSubscriptionNowInstructionDataCodec() {
  return combineCodec(
    getCancelSubscriptionNowInstructionDataEncoder(),
    getCancelSubscriptionNowInstructionDataDecoder(),
  );
}

/// Creates a [CancelSubscriptionNow] instruction.
Instruction getCancelSubscriptionNowInstruction({
  required Address programAddress,
  required Address subscriber,
  required Address merchant,
  required Address planPda,
  required Address subscriptionPda,
  required Address eventAuthority,
  required Address selfProgram,
  required CancelSubscriptionNowData cancelSubscriptionNowData,
}) {
  final instructionData = CancelSubscriptionNowInstructionData(
    cancelSubscriptionNowData: cancelSubscriptionNowData,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: subscriber, role: AccountRole.readonlySigner),
      AccountMeta(address: merchant, role: AccountRole.readonlySigner),
      AccountMeta(address: planPda, role: AccountRole.readonly),
      AccountMeta(address: subscriptionPda, role: AccountRole.writable),
      AccountMeta(address: eventAuthority, role: AccountRole.readonly),
      AccountMeta(address: selfProgram, role: AccountRole.readonly),
    ],
    data: getCancelSubscriptionNowInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [CancelSubscriptionNow] instruction from raw instruction data.
CancelSubscriptionNowInstructionData parseCancelSubscriptionNowInstruction(
  Instruction instruction,
) {
  return getCancelSubscriptionNowInstructionDataDecoder().decode(
    instruction.data!,
  );
}
