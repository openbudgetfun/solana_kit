// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/metadata_args.dart';

/// mintToCollectionV1 instruction data.
/// The Anchor discriminator for the `mint_to_collection_v1` instruction.
const mintToCollectionV1InstructionDiscriminator = <int>[
  153,
  18,
  178,
  47,
  197,
  158,
  86,
  15,
];

@immutable
class mintToCollectionV1InstructionData {
  const mintToCollectionV1InstructionData({
    this.discriminator = mintToCollectionV1InstructionDiscriminator,
    required this.metadataArgs,
  });

  final List<int> discriminator;
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
  final data = Uint8List(
    mintToCollectionV1InstructionDiscriminator.length + messageBytes.length,
  );
  data.setRange(
    0,
    mintToCollectionV1InstructionDiscriminator.length,
    mintToCollectionV1InstructionDiscriminator,
  );
  data.setRange(
    mintToCollectionV1InstructionDiscriminator.length,
    data.length,
    messageBytes,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.writable),
      AccountMeta(address: leafOwner, role: AccountRole.readonly),
      AccountMeta(address: leafDelegate, role: AccountRole.readonly),
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.readonlySigner),
      AccountMeta(address: treeDelegate, role: AccountRole.readonlySigner),
      AccountMeta(
        address: collectionAuthority,
        role: AccountRole.readonlySigner,
      ),
      AccountMeta(
        address: collectionAuthorityRecordPda,
        role: AccountRole.readonly,
      ),
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
