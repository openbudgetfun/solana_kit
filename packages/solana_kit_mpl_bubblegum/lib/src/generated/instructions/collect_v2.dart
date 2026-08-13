// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// CollectV2 instruction data for mpl-bubblegum compressed NFTs.
/// The Anchor discriminator for the `collect_v2` instruction.
const CollectV2InstructionDiscriminator = <int>[
  21,
  11,
  159,
  47,
  4,
  195,
  106,
  56,
];

@immutable
class CollectV2InstructionData {
  const CollectV2InstructionData({
    this.discriminator = CollectV2InstructionDiscriminator,
  });

  final List<int> discriminator;
}

Encoder<CollectV2InstructionData> getCollectV2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      getArrayEncoder(getU8Encoder(), size: const FixedArraySize(8)),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (CollectV2InstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<CollectV2InstructionData> getCollectV2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    (
      'discriminator',
      getArrayDecoder(getU8Decoder(), size: const FixedArraySize(8)),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CollectV2InstructionData(
          discriminator: map['discriminator']! as List<int>,
        ),
  );
}

Codec<CollectV2InstructionData, CollectV2InstructionData>
getCollectV2InstructionDataCodec() {
  return combineCodec(
    getCollectV2InstructionDataEncoder(),
    getCollectV2InstructionDataDecoder(),
  );
}

/// Creates a [CollectV2] instruction.
Instruction getCollectV2Instruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address destination,
}) {
  final instructionData = CollectV2InstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.writable),
      AccountMeta(address: destination, role: AccountRole.writable),
    ],
    data: getCollectV2InstructionDataEncoder().encode(instructionData),
  );
}
