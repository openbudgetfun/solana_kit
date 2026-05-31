// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Compress instruction data for mpl-bubblegum compressed NFTs.
@immutable
class CompressInstructionData {
  const CompressInstructionData({this.discriminator = 5});

  final int discriminator;
}

Encoder<CompressInstructionData> getCompressInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[]);

  return transformEncoder(
    structEncoder,
    (CompressInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<CompressInstructionData> getCompressInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CompressInstructionData(discriminator: map['discriminator']! as int),
  );
}

Codec<CompressInstructionData, CompressInstructionData>
getCompressInstructionDataCodec() {
  return combineCodec(
    getCompressInstructionDataEncoder(),
    getCompressInstructionDataDecoder(),
  );
}

/// Creates a [Compress] instruction.
Instruction getCompressInstruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address leafOwner,
  required Address leafDelegate,
  required Address merkleTree,
  required Address tokenAccount,
  required Address mint,
  required Address metadata,
  required Address masterEdition,
  required Address payer,
  required Address logWrapper,
  required Address compressionProgram,
  required Address tokenProgram,
  required Address tokenMetadataProgram,
  required Address systemProgram,
}) {
  final instructionData = CompressInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.readonly),
      AccountMeta(address: leafOwner, role: AccountRole.readonlySigner),
      AccountMeta(address: leafDelegate, role: AccountRole.readonly),
      AccountMeta(address: merkleTree, role: AccountRole.readonly),
      AccountMeta(address: tokenAccount, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: masterEdition, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: logWrapper, role: AccountRole.readonly),
      AccountMeta(address: compressionProgram, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: tokenMetadataProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getCompressInstructionDataEncoder().encode(instructionData),
  );
}
