// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// SetTreeDelegate instruction data for mpl-bubblegum compressed NFTs.
/// The Anchor discriminator for the `set_tree_delegate` instruction.
const SetTreeDelegateInstructionDiscriminator = <int>[
  253,
  118,
  66,
  37,
  190,
  49,
  154,
  102,
];

@immutable
class SetTreeDelegateInstructionData {
  const SetTreeDelegateInstructionData({
    this.discriminator = SetTreeDelegateInstructionDiscriminator,
  });

  final List<int> discriminator;
}

Encoder<SetTreeDelegateInstructionData>
getSetTreeDelegateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      getArrayEncoder(getU8Encoder(), size: const FixedArraySize(8)),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (SetTreeDelegateInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<SetTreeDelegateInstructionData>
getSetTreeDelegateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    (
      'discriminator',
      getArrayDecoder(getU8Decoder(), size: const FixedArraySize(8)),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        SetTreeDelegateInstructionData(
          discriminator: map['discriminator']! as List<int>,
        ),
  );
}

Codec<SetTreeDelegateInstructionData, SetTreeDelegateInstructionData>
getSetTreeDelegateInstructionDataCodec() {
  return combineCodec(
    getSetTreeDelegateInstructionDataEncoder(),
    getSetTreeDelegateInstructionDataDecoder(),
  );
}

/// Creates a [SetTreeDelegate] instruction.
Instruction getSetTreeDelegateInstruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address treeCreator,
  required Address newTreeDelegate,
  required Address merkleTree,
  required Address systemProgram,
}) {
  final instructionData = SetTreeDelegateInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.writable),
      AccountMeta(address: treeCreator, role: AccountRole.readonlySigner),
      AccountMeta(address: newTreeDelegate, role: AccountRole.readonly),
      AccountMeta(address: merkleTree, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getSetTreeDelegateInstructionDataEncoder().encode(instructionData),
  );
}
