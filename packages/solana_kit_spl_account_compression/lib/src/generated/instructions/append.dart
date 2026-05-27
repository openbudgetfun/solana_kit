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
class AppendInstructionData {
  const AppendInstructionData({this.discriminator = 4, required this.leaf});

  final int discriminator;
  final Uint8List leaf;
}

Encoder<AppendInstructionData> getAppendInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('leaf', getArrayEncoder(getU8Encoder(), size: FixedArraySize(32))),
  ]);

  return transformEncoder(
    structEncoder,
    (AppendInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'leaf': value.leaf,
    },
  );
}

Decoder<AppendInstructionData> getAppendInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('leaf', getArrayDecoder(getU8Decoder(), size: FixedArraySize(32))),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        AppendInstructionData(
          discriminator: map['discriminator']! as int,
          leaf: Uint8List.fromList(map['leaf']! as List<int>),
        ),
  );
}

Codec<AppendInstructionData, AppendInstructionData>
getAppendInstructionDataCodec() {
  return combineCodec(
    getAppendInstructionDataEncoder(),
    getAppendInstructionDataDecoder(),
  );
}

/// Creates a [Append] instruction.
Instruction getAppendInstruction({
  required Address programAddress,
  required Address merkleTree,
  required Address authority,
  required Address noop,

  required Uint8List leaf,
}) {
  final instructionData = AppendInstructionData(leaf: leaf);

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: noop, role: AccountRole.readonly),
    ],
    data: getAppendInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Append] instruction from raw instruction data.
AppendInstructionData parseAppendInstruction(Instruction instruction) {
  return getAppendInstructionDataDecoder().decode(instruction.data!);
}
