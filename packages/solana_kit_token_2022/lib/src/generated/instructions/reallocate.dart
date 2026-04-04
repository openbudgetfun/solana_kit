// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/extension_type.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class ReallocateInstructionData {
  const ReallocateInstructionData({
    this.discriminator = 29,
    required this.newExtensionTypes,
  });

  final int discriminator;
  final List<ExtensionType> newExtensionTypes;
}

Encoder<ReallocateInstructionData> getReallocateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('newExtensionTypes', getArrayEncoder(getExtensionTypeEncoder(), size: RemainderArraySize())),
  ]);

  return transformEncoder(
    structEncoder,
    (ReallocateInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'newExtensionTypes': value.newExtensionTypes,
    },
  );
}

Decoder<ReallocateInstructionData> getReallocateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('newExtensionTypes', getArrayDecoder(getExtensionTypeDecoder(), size: RemainderArraySize())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => ReallocateInstructionData(
      discriminator: map['discriminator']! as int,
      newExtensionTypes: map['newExtensionTypes']! as List<ExtensionType>,
    ),
  );
}

Codec<ReallocateInstructionData, ReallocateInstructionData> getReallocateInstructionDataCodec() {
  return combineCodec(getReallocateInstructionDataEncoder(), getReallocateInstructionDataDecoder());
}

/// Creates a [Reallocate] instruction.
Instruction getReallocateInstruction({
  required Address programAddress,
  required Address token,
  required Address payer,
  required Address systemProgram,
  required Address owner,
  required List<ExtensionType> newExtensionTypes,
}) {
  final instructionData = ReallocateInstructionData(
      newExtensionTypes: newExtensionTypes,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: token, role: AccountRole.writable),
    AccountMeta(address: payer, role: AccountRole.writableSigner),
    AccountMeta(address: systemProgram, role: AccountRole.readonly),
    AccountMeta(address: owner, role: AccountRole.readonlySigner),
    ],
    data: getReallocateInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Reallocate] instruction from raw instruction data.
ReallocateInstructionData parseReallocateInstruction(Instruction instruction) {
  return getReallocateInstructionDataDecoder().decode(instruction.data!);
}
