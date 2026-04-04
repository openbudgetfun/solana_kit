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
class UpdateTokenGroupMaxSizeInstructionData {
  UpdateTokenGroupMaxSizeInstructionData({
    Uint8List? discriminator,
    required this.maxSize,
  }) :
      discriminator = discriminator ?? Uint8List.fromList([108, 37, 171, 143, 248, 30, 18, 110]);

  final Uint8List discriminator;
  final BigInt maxSize;
}

Encoder<UpdateTokenGroupMaxSizeInstructionData> getUpdateTokenGroupMaxSizeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getBytesEncoder()),
    ('maxSize', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateTokenGroupMaxSizeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'maxSize': value.maxSize,
    },
  );
}

Decoder<UpdateTokenGroupMaxSizeInstructionData> getUpdateTokenGroupMaxSizeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getBytesDecoder()),
    ('maxSize', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UpdateTokenGroupMaxSizeInstructionData(
      discriminator: map['discriminator']! as Uint8List,
      maxSize: map['maxSize']! as BigInt,
    ),
  );
}

Codec<UpdateTokenGroupMaxSizeInstructionData, UpdateTokenGroupMaxSizeInstructionData> getUpdateTokenGroupMaxSizeInstructionDataCodec() {
  return combineCodec(getUpdateTokenGroupMaxSizeInstructionDataEncoder(), getUpdateTokenGroupMaxSizeInstructionDataDecoder());
}

/// Creates a [UpdateTokenGroupMaxSize] instruction.
Instruction getUpdateTokenGroupMaxSizeInstruction({
  required Address programAddress,
  required Address group,
  required Address updateAuthority,
  required BigInt maxSize,
}) {
  final instructionData = UpdateTokenGroupMaxSizeInstructionData(
      maxSize: maxSize,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: group, role: AccountRole.writable),
    AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
    ],
    data: getUpdateTokenGroupMaxSizeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateTokenGroupMaxSize] instruction from raw instruction data.
UpdateTokenGroupMaxSizeInstructionData parseUpdateTokenGroupMaxSizeInstruction(Instruction instruction) {
  return getUpdateTokenGroupMaxSizeInstructionDataDecoder().decode(instruction.data!);
}
