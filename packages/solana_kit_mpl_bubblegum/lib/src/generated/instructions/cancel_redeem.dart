// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// CancelRedeem instruction data for mpl-bubblegum compressed NFTs.
/// The Anchor discriminator for the `cancel_redeem` instruction.
const CancelRedeemInstructionDiscriminator = <int>[
  111,
  76,
  232,
  50,
  39,
  175,
  48,
  242,
];

@immutable
class CancelRedeemInstructionData {
  const CancelRedeemInstructionData({
    this.discriminator = CancelRedeemInstructionDiscriminator,
    required this.root,
  });

  final List<int> discriminator;
  final List<int> root;
}

Encoder<CancelRedeemInstructionData> getCancelRedeemInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      getArrayEncoder(getU8Encoder(), size: const FixedArraySize(8)),
    ),
    ('root', getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32))),
  ]);

  return transformEncoder(
    structEncoder,
    (CancelRedeemInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'root': Uint8List.fromList(value.root),
    },
  );
}

Decoder<CancelRedeemInstructionData> getCancelRedeemInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    (
      'discriminator',
      getArrayDecoder(getU8Decoder(), size: const FixedArraySize(8)),
    ),
    ('root', getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32))),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CancelRedeemInstructionData(
          discriminator: map['discriminator']! as List<int>,
          root: map['root']! as List<int>,
        ),
  );
}

Codec<CancelRedeemInstructionData, CancelRedeemInstructionData>
getCancelRedeemInstructionDataCodec() {
  return combineCodec(
    getCancelRedeemInstructionDataEncoder(),
    getCancelRedeemInstructionDataDecoder(),
  );
}

/// Creates a [CancelRedeem] instruction.
Instruction getCancelRedeemInstruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address leafOwner,
  required Address merkleTree,
  required Address voucher,
  required Address logWrapper,
  required Address compressionProgram,
  required Address systemProgram,
  required List<int> root,
}) {
  final instructionData = CancelRedeemInstructionData(root: root);

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.readonly),
      AccountMeta(address: leafOwner, role: AccountRole.writableSigner),
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: voucher, role: AccountRole.writable),
      AccountMeta(address: logWrapper, role: AccountRole.readonly),
      AccountMeta(address: compressionProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getCancelRedeemInstructionDataEncoder().encode(instructionData),
  );
}
