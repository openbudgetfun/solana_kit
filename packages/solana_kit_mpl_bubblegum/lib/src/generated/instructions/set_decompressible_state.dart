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

/// SetDecompressibleState instruction data for mpl-bubblegum compressed NFTs.
/// The Anchor discriminator for the `set_decompressible_state` instruction.
const SetDecompressibleStateInstructionDiscriminator = <int>[
  82,
  104,
  152,
  6,
  149,
  111,
  100,
  13,
];

@immutable
class SetDecompressibleStateInstructionData {
  const SetDecompressibleStateInstructionData({
    this.discriminator = SetDecompressibleStateInstructionDiscriminator,
    required this.decompressableState,
  });

  final List<int> discriminator;
  final DecompressibleState decompressableState;
}

Encoder<SetDecompressibleStateInstructionData>
getSetDecompressibleStateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      getArrayEncoder(getU8Encoder(), size: const FixedArraySize(8)),
    ),
    ('decompressableState', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetDecompressibleStateInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'decompressableState': value.decompressableState,
    },
  );
}

Decoder<SetDecompressibleStateInstructionData>
getSetDecompressibleStateInstructionDataDecoder() {
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
        SetDecompressibleStateInstructionData(
          discriminator: map['discriminator']! as List<int>,
          decompressableState:
              map['decompressableState']! as DecompressibleState,
        ),
  );
}

Codec<
  SetDecompressibleStateInstructionData,
  SetDecompressibleStateInstructionData
>
getSetDecompressibleStateInstructionDataCodec() {
  return combineCodec(
    getSetDecompressibleStateInstructionDataEncoder(),
    getSetDecompressibleStateInstructionDataDecoder(),
  );
}

/// Creates a [SetDecompressibleState] instruction.
Instruction getSetDecompressibleStateInstruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address treeCreator,
  required DecompressibleState decompressableState,
}) {
  final instructionData = SetDecompressibleStateInstructionData(
    decompressableState: decompressableState,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.writable),
      AccountMeta(address: treeCreator, role: AccountRole.readonlySigner),
    ],
    data: getSetDecompressibleStateInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}
