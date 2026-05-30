// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/lockup_params.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class SetLockupInstructionData {
  const SetLockupInstructionData({this.discriminator = 6, required this.arg0});

  final int discriminator;
  final LockupParams arg0;
}

Encoder<SetLockupInstructionData> getSetLockupInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('arg0', getLockupParamsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetLockupInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'arg0': value.arg0,
    },
  );
}

Decoder<SetLockupInstructionData> getSetLockupInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('arg0', getLockupParamsDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        SetLockupInstructionData(
          discriminator: map['discriminator']! as int,
          arg0: map['arg0']! as LockupParams,
        ),
  );
}

Codec<SetLockupInstructionData, SetLockupInstructionData>
getSetLockupInstructionDataCodec() {
  return combineCodec(
    getSetLockupInstructionDataEncoder(),
    getSetLockupInstructionDataDecoder(),
  );
}

/// Creates a [SetLockup] instruction.
Instruction getSetLockupInstruction({
  required Address programAddress,
  required Address stake,
  required Address authority,
  required LockupParams arg0,
}) {
  final instructionData = SetLockupInstructionData(arg0: arg0);

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: stake, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getSetLockupInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [SetLockup] instruction from raw instruction data.
SetLockupInstructionData parseSetLockupInstruction(Instruction instruction) {
  return getSetLockupInstructionDataDecoder().decode(instruction.data!);
}
