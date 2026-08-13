// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/epoch.dart';
import '../types/unix_timestamp.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class SetLockupCheckedInstructionData {
  const SetLockupCheckedInstructionData({
    this.discriminator = 12,
    required this.unixTimestamp,
    required this.epoch,
  });

  final int discriminator;
  final UnixTimestamp? unixTimestamp;
  final Epoch? epoch;
}

Encoder<SetLockupCheckedInstructionData>
getSetLockupCheckedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    (
      'unixTimestamp',
      getNullableEncoder<UnixTimestamp>(getUnixTimestampEncoder()),
    ),
    ('epoch', getNullableEncoder<Epoch>(getEpochEncoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (SetLockupCheckedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'unixTimestamp': value.unixTimestamp,
      'epoch': value.epoch,
    },
  );
}

Decoder<SetLockupCheckedInstructionData>
getSetLockupCheckedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    (
      'unixTimestamp',
      getNullableDecoder<UnixTimestamp>(getUnixTimestampDecoder()),
    ),
    ('epoch', getNullableDecoder<Epoch>(getEpochDecoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        SetLockupCheckedInstructionData(
          discriminator: map['discriminator']! as int,
          unixTimestamp: map['unixTimestamp'] as UnixTimestamp?,
          epoch: map['epoch'] as Epoch?,
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
  required UnixTimestamp? unixTimestamp,
  required Epoch? epoch,
}) {
  final instructionData = SetLockupCheckedInstructionData(
    unixTimestamp: unixTimestamp,
    epoch: epoch,
  );

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
