// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/account_state.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

/// The discriminator field name: 'defaultAccountStateDiscriminator'.
/// Offset: 1.

@immutable
class UpdateDefaultAccountStateInstructionData {
  const UpdateDefaultAccountStateInstructionData({
    this.discriminator = 28,
    this.defaultAccountStateDiscriminator = 1,
    required this.state,
  });

  final int discriminator;
  final int defaultAccountStateDiscriminator;
  final AccountState state;
}

Encoder<UpdateDefaultAccountStateInstructionData> getUpdateDefaultAccountStateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('defaultAccountStateDiscriminator', getU8Encoder()),
    ('state', getAccountStateEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateDefaultAccountStateInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'defaultAccountStateDiscriminator': value.defaultAccountStateDiscriminator,
      'state': value.state,
    },
  );
}

Decoder<UpdateDefaultAccountStateInstructionData> getUpdateDefaultAccountStateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('defaultAccountStateDiscriminator', getU8Decoder()),
    ('state', getAccountStateDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UpdateDefaultAccountStateInstructionData(
      discriminator: map['discriminator']! as int,
      defaultAccountStateDiscriminator: map['defaultAccountStateDiscriminator']! as int,
      state: map['state']! as AccountState,
    ),
  );
}

Codec<UpdateDefaultAccountStateInstructionData, UpdateDefaultAccountStateInstructionData> getUpdateDefaultAccountStateInstructionDataCodec() {
  return combineCodec(getUpdateDefaultAccountStateInstructionDataEncoder(), getUpdateDefaultAccountStateInstructionDataDecoder());
}

/// Creates a [UpdateDefaultAccountState] instruction.
Instruction getUpdateDefaultAccountStateInstruction({
  required Address programAddress,
  required Address mint,
  required Address freezeAuthority,
  required AccountState state,
}) {
  final instructionData = UpdateDefaultAccountStateInstructionData(
      state: state,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: freezeAuthority, role: AccountRole.readonlySigner),
    ],
    data: getUpdateDefaultAccountStateInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateDefaultAccountState] instruction from raw instruction data.
UpdateDefaultAccountStateInstructionData parseUpdateDefaultAccountStateInstruction(Instruction instruction) {
  return getUpdateDefaultAccountStateInstructionDataDecoder().decode(instruction.data!);
}
