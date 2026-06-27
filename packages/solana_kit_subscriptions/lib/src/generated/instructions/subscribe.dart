// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/subscribe_data.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class SubscribeInstructionData {
  const SubscribeInstructionData({
    this.discriminator = 11,
    required this.subscribeData,
  });

  final int discriminator;
  final SubscribeData subscribeData;
}

Encoder<SubscribeInstructionData> getSubscribeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('subscribeData', getSubscribeDataEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SubscribeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'subscribeData': value.subscribeData,
    },
  );
}

Decoder<SubscribeInstructionData> getSubscribeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('subscribeData', getSubscribeDataDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        SubscribeInstructionData(
          discriminator: map['discriminator']! as int,
          subscribeData: map['subscribeData']! as SubscribeData,
        ),
  );
}

Codec<SubscribeInstructionData, SubscribeInstructionData>
getSubscribeInstructionDataCodec() {
  return combineCodec(
    getSubscribeInstructionDataEncoder(),
    getSubscribeInstructionDataDecoder(),
  );
}

/// Creates a [Subscribe] instruction.
Instruction getSubscribeInstruction({
  required Address programAddress,
  required Address subscriber,
  required Address merchant,
  required Address planPda,
  required Address subscriptionPda,
  required Address subscriptionAuthorityPda,
  required Address systemProgram,
  required Address eventAuthority,
  required Address selfProgram,
  Address? payer,
  required SubscribeData subscribeData,
}) {
  final instructionData = SubscribeInstructionData(
    subscribeData: subscribeData,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: subscriber, role: AccountRole.writableSigner),
      AccountMeta(address: merchant, role: AccountRole.readonly),
      AccountMeta(address: planPda, role: AccountRole.readonly),
      AccountMeta(address: subscriptionPda, role: AccountRole.writable),
      AccountMeta(
        address: subscriptionAuthorityPda,
        role: AccountRole.readonly,
      ),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: eventAuthority, role: AccountRole.readonly),
      AccountMeta(address: selfProgram, role: AccountRole.readonly),
      if (payer != null)
        AccountMeta(address: payer, role: AccountRole.writableSigner),
    ],
    data: getSubscribeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Subscribe] instruction from raw instruction data.
SubscribeInstructionData parseSubscribeInstruction(Instruction instruction) {
  return getSubscribeInstructionDataDecoder().decode(instruction.data!);
}
