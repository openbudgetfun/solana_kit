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
class CloseSubscriptionAuthorityInstructionData {
  const CloseSubscriptionAuthorityInstructionData({
    this.discriminator = 6,
  });

  final int discriminator;
}

Encoder<CloseSubscriptionAuthorityInstructionData> getCloseSubscriptionAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CloseSubscriptionAuthorityInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<CloseSubscriptionAuthorityInstructionData> getCloseSubscriptionAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => CloseSubscriptionAuthorityInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<CloseSubscriptionAuthorityInstructionData, CloseSubscriptionAuthorityInstructionData> getCloseSubscriptionAuthorityInstructionDataCodec() {
  return combineCodec(getCloseSubscriptionAuthorityInstructionDataEncoder(), getCloseSubscriptionAuthorityInstructionDataDecoder());
}

/// Creates a [CloseSubscriptionAuthority] instruction.
Instruction getCloseSubscriptionAuthorityInstruction({
  required Address programAddress,
  required Address user,
  required Address subscriptionAuthority,
  Address? receiver,

}) {
  final instructionData = CloseSubscriptionAuthorityInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: user, role: AccountRole.writableSigner),
    AccountMeta(address: subscriptionAuthority, role: AccountRole.writable),
    if (receiver != null) AccountMeta(address: receiver, role: AccountRole.writable),
    ],
    data: getCloseSubscriptionAuthorityInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CloseSubscriptionAuthority] instruction from raw instruction data.
CloseSubscriptionAuthorityInstructionData parseCloseSubscriptionAuthorityInstruction(Instruction instruction) {
  return getCloseSubscriptionAuthorityInstructionDataDecoder().decode(instruction.data!);
}
