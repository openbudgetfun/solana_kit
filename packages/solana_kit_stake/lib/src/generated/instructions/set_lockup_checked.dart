// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/lockup_checked_params.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class SetLockupCheckedInstructionData {
  const SetLockupCheckedInstructionData({
    this.discriminator = 12,
    required this.arg0,
  });

  final int discriminator;
  final LockupCheckedParams arg0;
}

Encoder<SetLockupCheckedInstructionData>
getSetLockupCheckedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('arg0', getLockupCheckedParamsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetLockupCheckedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'arg0': value.arg0,
    },
  );
}

Decoder<SetLockupCheckedInstructionData>
getSetLockupCheckedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('arg0', getLockupCheckedParamsDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        SetLockupCheckedInstructionData(
          discriminator: map['discriminator']! as int,
          arg0: map['arg0']! as LockupCheckedParams,
        ),
  );
}

Codec<SetLockupCheckedInstructionData, SetLockupCheckedInstructionData>
getSetLockupCheckedInstructionDataCodec() {
  return combineCodec(
    getSetLockupCheckedInstructionDataEncoder(),
    getSetLockupCheckedInstructionDataDecoder(),
  );
}

/// Creates a [SetLockupChecked] instruction.
Instruction getSetLockupCheckedInstruction({
  required Address programAddress,
  required Address stake,
  required Address authority,
  Address? newAuthority,
  required LockupCheckedParams arg0,
}) {
  final instructionData = SetLockupCheckedInstructionData(arg0: arg0);

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: stake, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      if (newAuthority != null)
        AccountMeta(address: newAuthority, role: AccountRole.readonlySigner),
    ],
    data: getSetLockupCheckedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [SetLockupChecked] instruction from raw instruction data.
SetLockupCheckedInstructionData parseSetLockupCheckedInstruction(
  Instruction instruction,
) {
  return getSetLockupCheckedInstructionDataDecoder().decode(instruction.data!);
}
