// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/metadata_args.dart';

/// updateMetadata instruction data.
/// The Anchor discriminator for the `update_metadata` instruction.
const updateMetadataInstructionDiscriminator = <int>[
  170,
  182,
  43,
  239,
  97,
  78,
  225,
  186,
];

@immutable
class updateMetadataInstructionData {
  const updateMetadataInstructionData({
    this.discriminator = updateMetadataInstructionDiscriminator,
    required this.metadataArgs,
  });

  final List<int> discriminator;
  final MetadataArgs metadataArgs;
}

/// Creates a [updateMetadata] instruction.
Instruction getupdateMetadataInstruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address authority,
  required Address collectionMint,
  required Address collectionMetadata,
  required Address collectionAuthorityRecordPda,
  required Address leafOwner,
  required Address leafDelegate,
  required Address payer,
  required Address merkleTree,
  required Address logWrapper,
  required Address compressionProgram,
  required Address tokenMetadataProgram,
  required Address systemProgram,
  required MetadataArgs metadataArgs,
}) {
  final messageBytes = encodeMetadataArgs(metadataArgs);
  final data = Uint8List(
    updateMetadataInstructionDiscriminator.length + messageBytes.length,
  );
  data.setRange(
    0,
    updateMetadataInstructionDiscriminator.length,
    updateMetadataInstructionDiscriminator,
  );
  data.setRange(
    updateMetadataInstructionDiscriminator.length,
    data.length,
    messageBytes,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.readonly),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: collectionMint, role: AccountRole.readonly),
      AccountMeta(address: collectionMetadata, role: AccountRole.readonly),
      AccountMeta(
        address: collectionAuthorityRecordPda,
        role: AccountRole.readonly,
      ),
      AccountMeta(address: leafOwner, role: AccountRole.readonly),
      AccountMeta(address: leafDelegate, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.readonlySigner),
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: logWrapper, role: AccountRole.readonly),
      AccountMeta(address: compressionProgram, role: AccountRole.readonly),
      AccountMeta(address: tokenMetadataProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: data,
  );
}
