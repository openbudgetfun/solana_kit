// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/metadata_args.dart';

/// mintToCollectionV1 instruction data.
@immutable
class mintToCollectionV1InstructionData {
  const mintToCollectionV1InstructionData({
    this.discriminator = 13,
    required this.metadataArgs,
  });

  final int discriminator;
  final MetadataArgs metadataArgs;
}

/// Creates a [mintToCollectionV1] instruction.
Instruction getmintToCollectionV1Instruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address leafOwner,
  required Address leafDelegate,
  required Address merkleTree,
  required Address payer,
  required Address treeDelegate,
  required Address collectionAuthority,
  required Address collectionAuthorityRecordPda,
  required Address collectionMint,
  required Address collectionMetadata,
  required Address editionAccount,
  required Address bubblegumSigner,
  required Address logWrapper,
  required Address compressionProgram,
  required Address tokenMetadataProgram,
  required Address systemProgram,
  required MetadataArgs metadataArgs,
}) {
  final messageBytes = encodeMetadataArgs(metadataArgs);
  final data = Uint8List(1 + messageBytes.length);
  data[0] = 13;
  data.setRange(1, data.length, messageBytes);

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.writable),
      AccountMeta(address: leafOwner, role: AccountRole.readonly),
      AccountMeta(address: leafDelegate, role: AccountRole.readonly),
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.readonlySigner),
      AccountMeta(address: treeDelegate, role: AccountRole.readonlySigner),
      AccountMeta(address: collectionAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: collectionAuthorityRecordPda, role: AccountRole.readonly),
      AccountMeta(address: collectionMint, role: AccountRole.readonly),
      AccountMeta(address: collectionMetadata, role: AccountRole.writable),
      AccountMeta(address: editionAccount, role: AccountRole.readonly),
      AccountMeta(address: bubblegumSigner, role: AccountRole.readonly),
      AccountMeta(address: logWrapper, role: AccountRole.readonly),
      AccountMeta(address: compressionProgram, role: AccountRole.readonly),
      AccountMeta(address: tokenMetadataProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: data,
  );
}
