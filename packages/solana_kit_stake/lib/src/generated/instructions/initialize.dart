// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/authorized.dart';
import '../types/lockup.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class InitializeInstructionData {
  const InitializeInstructionData({
    this.discriminator = 0,
    required this.arg0,
    required this.arg1,
  });

  final int discriminator;
  final Authorized arg0;
  final Lockup arg1;
}

Encoder<InitializeInstructionData> getInitializeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('arg0', getAuthorizedEncoder()),
    ('arg1', getLockupEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'arg0': value.arg0,
      'arg1': value.arg1,
    },
  );
}

Decoder<InitializeInstructionData> getInitializeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('arg0', getAuthorizedDecoder()),
    ('arg1', getLockupDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        InitializeInstructionData(
          discriminator: map['discriminator']! as int,
          arg0: map['arg0']! as Authorized,
          arg1: map['arg1']! as Lockup,
        ),
  );
}

Codec<InitializeInstructionData, InitializeInstructionData>
getInitializeInstructionDataCodec() {
  return combineCodec(
    getInitializeInstructionDataEncoder(),
    getInitializeInstructionDataDecoder(),
  );
}

/// Creates a [Initialize] instruction.
Instruction getInitializeInstruction({
  required Address programAddress,
  required Address stake,
  required Address rentSysvar,
  required Authorized arg0,
  required Lockup arg1,
}) {
  final instructionData = InitializeInstructionData(arg0: arg0, arg1: arg1);

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: stake, role: AccountRole.writable),
      AccountMeta(address: rentSysvar, role: AccountRole.readonly),
    ],
    data: getInitializeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Initialize] instruction from raw instruction data.
InitializeInstructionData parseInitializeInstruction(Instruction instruction) {
  return getInitializeInstructionDataDecoder().decode(instruction.data!);
}
