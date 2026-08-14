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
/// The Anchor discriminator for the `set_decompressable_state` instruction.
const SetDecompressableStateInstructionDiscriminator = <int>[
  18,
  135,
  238,
  168,
  246,
  195,
  61,
  115,
];

@immutable
class SetDecompressableStateInstructionData {
  const SetDecompressableStateInstructionData({
    this.discriminator = SetDecompressableStateInstructionDiscriminator,
    required this.decompressableState,
  });

  final List<int> discriminator;
  final DecompressibleState decompressableState;
}

Encoder<SetDecompressableStateInstructionData>
getSetDecompressableStateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      getArrayEncoder(getU8Encoder(), size: const FixedArraySize(8)),
    ),
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

Decoder<SetDecompressableStateInstructionData>
getSetDecompressableStateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    (
      'discriminator',
      getArrayDecoder(getU8Decoder(), size: const FixedArraySize(8)),
    ),
    ('decompressableState', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        SetDecompressableStateInstructionData(
          discriminator: map['discriminator']! as List<int>,
          decompressableState:
              map['decompressableState']! as DecompressibleState,
        ),
  );
}

Codec<
  SetDecompressableStateInstructionData,
  SetDecompressableStateInstructionData
>
getSetDecompressableStateInstructionDataCodec() {
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
    data: getSetDecompressableStateInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}
