// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/create_fixed_delegation_data.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class CreateFixedDelegationInstructionData {
  const CreateFixedDelegationInstructionData({
    this.discriminator = 1,
    required this.fixedDelegation,
  });

  final int discriminator;
  final CreateFixedDelegationData fixedDelegation;
}

Encoder<CreateFixedDelegationInstructionData>
getCreateFixedDelegationInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('fixedDelegation', getCreateFixedDelegationDataEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateFixedDelegationInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'fixedDelegation': value.fixedDelegation,
    },
  );
}

Decoder<CreateFixedDelegationInstructionData>
getCreateFixedDelegationInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('fixedDelegation', getCreateFixedDelegationDataDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CreateFixedDelegationInstructionData(
          discriminator: map['discriminator']! as int,
          fixedDelegation: map['fixedDelegation']! as CreateFixedDelegationData,
        ),
  );
}

Codec<
  CreateFixedDelegationInstructionData,
  CreateFixedDelegationInstructionData
>
getCreateFixedDelegationInstructionDataCodec() {
  return combineCodec(
    getCreateFixedDelegationInstructionDataEncoder(),
    getCreateFixedDelegationInstructionDataDecoder(),
  );
}

/// Creates a [CreateFixedDelegation] instruction.
Instruction getCreateFixedDelegationInstruction({
  required Address programAddress,
  required Address delegator,
  required Address subscriptionAuthority,
  required Address delegationAccount,
  required Address delegatee,
  required Address systemProgram,
  required CreateFixedDelegationData fixedDelegation,
}) {
  final instructionData = CreateFixedDelegationInstructionData(
    fixedDelegation: fixedDelegation,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: delegator, role: AccountRole.writableSigner),
      AccountMeta(address: subscriptionAuthority, role: AccountRole.readonly),
      AccountMeta(address: delegationAccount, role: AccountRole.writable),
      AccountMeta(address: delegatee, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getCreateFixedDelegationInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [CreateFixedDelegation] instruction from raw instruction data.
CreateFixedDelegationInstructionData parseCreateFixedDelegationInstruction(
  Instruction instruction,
) {
  return getCreateFixedDelegationInstructionDataDecoder().decode(
    instruction.data!,
  );
}
