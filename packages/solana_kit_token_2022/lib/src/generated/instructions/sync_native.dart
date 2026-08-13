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
class SyncNativeInstructionData {
  const SyncNativeInstructionData({
    this.discriminator = 17,
  });

  final int discriminator;
}

Encoder<SyncNativeInstructionData> getSyncNativeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SyncNativeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<SyncNativeInstructionData> getSyncNativeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => SyncNativeInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<SyncNativeInstructionData, SyncNativeInstructionData> getSyncNativeInstructionDataCodec() {
  return combineCodec(getSyncNativeInstructionDataEncoder(), getSyncNativeInstructionDataDecoder());
}

/// Creates a [SyncNative] instruction.
Instruction getSyncNativeInstruction({
  required Address programAddress,
  required Address account,
  Address? rent,

}) {
  final instructionData = SyncNativeInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: account, role: AccountRole.writable),
    if (rent != null) AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getSyncNativeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [SyncNative] instruction from raw instruction data.
SyncNativeInstructionData parseSyncNativeInstruction(Instruction instruction) {
  return getSyncNativeInstructionDataDecoder().decode(instruction.data!);
}
