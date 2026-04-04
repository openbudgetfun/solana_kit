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
class InitializeDefaultAccountStateInstructionData {
  const InitializeDefaultAccountStateInstructionData({
    this.discriminator = 28,
    this.defaultAccountStateDiscriminator = 0,
    required this.state,
  });

  final int discriminator;
  final int defaultAccountStateDiscriminator;
  final AccountState state;
}

Encoder<InitializeDefaultAccountStateInstructionData> getInitializeDefaultAccountStateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('defaultAccountStateDiscriminator', getU8Encoder()),
    ('state', getAccountStateEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeDefaultAccountStateInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'defaultAccountStateDiscriminator': value.defaultAccountStateDiscriminator,
      'state': value.state,
    },
  );
}

Decoder<InitializeDefaultAccountStateInstructionData> getInitializeDefaultAccountStateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('defaultAccountStateDiscriminator', getU8Decoder()),
    ('state', getAccountStateDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeDefaultAccountStateInstructionData(
      discriminator: map['discriminator']! as int,
      defaultAccountStateDiscriminator: map['defaultAccountStateDiscriminator']! as int,
      state: map['state']! as AccountState,
    ),
  );
}

Codec<InitializeDefaultAccountStateInstructionData, InitializeDefaultAccountStateInstructionData> getInitializeDefaultAccountStateInstructionDataCodec() {
  return combineCodec(getInitializeDefaultAccountStateInstructionDataEncoder(), getInitializeDefaultAccountStateInstructionDataDecoder());
}

/// Creates a [InitializeDefaultAccountState] instruction.
Instruction getInitializeDefaultAccountStateInstruction({
  required Address programAddress,
  required Address mint,
  required AccountState state,
}) {
  final instructionData = InitializeDefaultAccountStateInstructionData(
      state: state,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeDefaultAccountStateInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeDefaultAccountState] instruction from raw instruction data.
InitializeDefaultAccountStateInstructionData parseInitializeDefaultAccountStateInstruction(Instruction instruction) {
  return getInitializeDefaultAccountStateInstructionDataDecoder().decode(instruction.data!);
}
