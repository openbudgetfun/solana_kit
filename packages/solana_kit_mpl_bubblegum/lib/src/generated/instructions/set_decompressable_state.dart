// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/enums.dart';

/// SetDecompressableState instruction data for mpl-bubblegum compressed NFTs.
@immutable
class SetDecompressableStateInstructionData {
  const SetDecompressableStateInstructionData({
    this.discriminator = 19,
    required this.decompressableState,
  });

  final int discriminator;
  final DecompressibleState decompressableState;
}

Encoder<SetDecompressableStateInstructionData> getSetDecompressableStateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
      ('decompressableState', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetDecompressableStateInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'decompressableState': value.decompressableState,
    },
  );
}

Decoder<SetDecompressableStateInstructionData> getSetDecompressableStateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
      ('decompressableState', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => SetDecompressableStateInstructionData(
          discriminator: map['discriminator']! as int,
          decompressableState: map['decompressableState']! as DecompressibleState,
        ),
  );
}

Codec<SetDecompressableStateInstructionData, SetDecompressableStateInstructionData> getSetDecompressableStateInstructionDataCodec() {
  return combineCodec(
    getSetDecompressableStateInstructionDataEncoder(),
    getSetDecompressableStateInstructionDataDecoder(),
  );
}

/// Creates a [SetDecompressableState] instruction.
Instruction getSetDecompressableStateInstruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address treeCreator,
  required DecompressibleState decompressableState,
}) {
  final instructionData = SetDecompressableStateInstructionData(
      decompressableState: decompressableState,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.writable),
      AccountMeta(address: treeCreator, role: AccountRole.readonlySigner),
    ],
    data: getSetDecompressableStateInstructionDataEncoder().encode(instructionData),
  );
}
