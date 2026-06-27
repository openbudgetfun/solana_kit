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
class RevokeAbandonedDelegationInstructionData {
  const RevokeAbandonedDelegationInstructionData({
    this.discriminator = 15,
  });

  final int discriminator;
}

Encoder<RevokeAbandonedDelegationInstructionData>
getRevokeAbandonedDelegationInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RevokeAbandonedDelegationInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<RevokeAbandonedDelegationInstructionData>
getRevokeAbandonedDelegationInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        RevokeAbandonedDelegationInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

Codec<
  RevokeAbandonedDelegationInstructionData,
  RevokeAbandonedDelegationInstructionData
>
getRevokeAbandonedDelegationInstructionDataCodec() {
  return combineCodec(
    getRevokeAbandonedDelegationInstructionDataEncoder(),
    getRevokeAbandonedDelegationInstructionDataDecoder(),
  );
}

/// Creates a [RevokeAbandonedDelegation] instruction.
Instruction getRevokeAbandonedDelegationInstruction({
  required Address programAddress,
  required Address payer,
  required Address delegationAccount,
  required Address subscriptionAuthority,
}) {
  final instructionData = RevokeAbandonedDelegationInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: delegationAccount, role: AccountRole.writable),
      AccountMeta(address: subscriptionAuthority, role: AccountRole.readonly),
    ],
    data: getRevokeAbandonedDelegationInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [RevokeAbandonedDelegation] instruction from raw instruction data.
RevokeAbandonedDelegationInstructionData
parseRevokeAbandonedDelegationInstruction(Instruction instruction) {
  return getRevokeAbandonedDelegationInstructionDataDecoder().decode(
    instruction.data!,
  );
}
