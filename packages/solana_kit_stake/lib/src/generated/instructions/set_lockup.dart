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
class SetLockupInstructionData {
  const SetLockupInstructionData({
    this.discriminator = 6,
    required this.unixTimestamp,
    required this.epoch,
    required this.custodian,
  });

  final int discriminator;
  final UnixTimestamp? unixTimestamp;
  final Epoch? epoch;
  final Address? custodian;
}

Encoder<SetLockupInstructionData> getSetLockupInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    (
      'unixTimestamp',
      getNullableEncoder<UnixTimestamp>(getUnixTimestampEncoder()),
    ),
    ('epoch', getNullableEncoder<Epoch>(getEpochEncoder())),
    ('custodian', getNullableEncoder<Address>(getAddressEncoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (SetLockupInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'unixTimestamp': value.unixTimestamp,
      'epoch': value.epoch,
      'custodian': value.custodian,
    },
  );
}

Decoder<SetLockupInstructionData> getSetLockupInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    (
      'unixTimestamp',
      getNullableDecoder<UnixTimestamp>(getUnixTimestampDecoder()),
    ),
    ('epoch', getNullableDecoder<Epoch>(getEpochDecoder())),
    ('custodian', getNullableDecoder<Address>(getAddressDecoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        SetLockupInstructionData(
          discriminator: map['discriminator']! as int,
          unixTimestamp: map['unixTimestamp'] as UnixTimestamp?,
          epoch: map['epoch'] as Epoch?,
          custodian: map['custodian'] as Address?,
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
  required UnixTimestamp? unixTimestamp,
  required Epoch? epoch,
  required Address? custodian,
}) {
  final instructionData = SetLockupInstructionData(
    unixTimestamp: unixTimestamp,
    epoch: epoch,
    custodian: custodian,
  );

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
