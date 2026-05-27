// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// CloseTreeV2 instruction data for mpl-bubblegum compressed NFTs.
@immutable
class CloseTreeV2InstructionData {
  const CloseTreeV2InstructionData({
    this.discriminator = 3,
  });

  final int discriminator;

}

Encoder<CloseTreeV2InstructionData> getCloseTreeV2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[

  ]);

  return transformEncoder(
    structEncoder,
    (CloseTreeV2InstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,

    },
  );
}

Decoder<CloseTreeV2InstructionData> getCloseTreeV2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),

  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => CloseTreeV2InstructionData(
          discriminator: map['discriminator']! as int,

        ),
  );
}

Codec<CloseTreeV2InstructionData, CloseTreeV2InstructionData> getCloseTreeV2InstructionDataCodec() {
  return combineCodec(
    getCloseTreeV2InstructionDataEncoder(),
    getCloseTreeV2InstructionDataDecoder(),
  );
}

/// Creates a [CloseTreeV2] instruction.
Instruction getCloseTreeV2Instruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address authority,
  required Address merkleTree,
  required Address recipient,
  required Address compressionProgram,
  required Address logWrapper,
  required Address systemProgram,
}) {
  final instructionData = CloseTreeV2InstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: recipient, role: AccountRole.writable),
      AccountMeta(address: compressionProgram, role: AccountRole.readonly),
      AccountMeta(address: logWrapper, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getCloseTreeV2InstructionDataEncoder().encode(instructionData),
  );
}
