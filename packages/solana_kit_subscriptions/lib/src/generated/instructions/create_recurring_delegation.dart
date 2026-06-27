// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/create_recurring_delegation_data.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class CreateRecurringDelegationInstructionData {
  const CreateRecurringDelegationInstructionData({
    this.discriminator = 2,
    required this.recurringDelegation,
  });

  final int discriminator;
  final CreateRecurringDelegationData recurringDelegation;
}

Encoder<CreateRecurringDelegationInstructionData> getCreateRecurringDelegationInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('recurringDelegation', getCreateRecurringDelegationDataEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateRecurringDelegationInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'recurringDelegation': value.recurringDelegation,
    },
  );
}

Decoder<CreateRecurringDelegationInstructionData> getCreateRecurringDelegationInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('recurringDelegation', getCreateRecurringDelegationDataDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => CreateRecurringDelegationInstructionData(
      discriminator: map['discriminator']! as int,
      recurringDelegation: map['recurringDelegation']! as CreateRecurringDelegationData,
    ),
  );
}

Codec<CreateRecurringDelegationInstructionData, CreateRecurringDelegationInstructionData> getCreateRecurringDelegationInstructionDataCodec() {
  return combineCodec(getCreateRecurringDelegationInstructionDataEncoder(), getCreateRecurringDelegationInstructionDataDecoder());
}

/// Creates a [CreateRecurringDelegation] instruction.
Instruction getCreateRecurringDelegationInstruction({
  required Address programAddress,
  required Address delegator,
  required Address subscriptionAuthority,
  required Address delegationAccount,
  required Address delegatee,
  required Address systemProgram,
  Address? payer,
  required CreateRecurringDelegationData recurringDelegation,
}) {
  final instructionData = CreateRecurringDelegationInstructionData(
      recurringDelegation: recurringDelegation,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: delegator, role: AccountRole.writableSigner),
    AccountMeta(address: subscriptionAuthority, role: AccountRole.readonly),
    AccountMeta(address: delegationAccount, role: AccountRole.writable),
    AccountMeta(address: delegatee, role: AccountRole.readonly),
    AccountMeta(address: systemProgram, role: AccountRole.readonly),
    if (payer != null) AccountMeta(address: payer, role: AccountRole.writableSigner),
    ],
    data: getCreateRecurringDelegationInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CreateRecurringDelegation] instruction from raw instruction data.
CreateRecurringDelegationInstructionData parseCreateRecurringDelegationInstruction(Instruction instruction) {
  return getCreateRecurringDelegationInstructionDataDecoder().decode(instruction.data!);
}
