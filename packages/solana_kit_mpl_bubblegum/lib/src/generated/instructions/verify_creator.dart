// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/metadata_args.dart';

/// verifyCreator instruction data.
/// The Anchor discriminator for the `verify_creator` instruction.
const verifyCreatorInstructionDiscriminator = <int>[
  52,
  17,
  96,
  132,
  71,
  4,
  85,
  194,
];

@immutable
class verifyCreatorInstructionData {
  const verifyCreatorInstructionData({
    this.discriminator = verifyCreatorInstructionDiscriminator,
    required this.metadataArgs,
  });

  final List<int> discriminator;
  final MetadataArgs metadataArgs;
}

/// Creates a [verifyCreator] instruction.
Instruction getverifyCreatorInstruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address leafOwner,
  required Address leafDelegate,
  required Address merkleTree,
  required Address payer,
  required Address creator,
  required Address logWrapper,
  required Address compressionProgram,
  required Address systemProgram,
  required MetadataArgs metadataArgs,
}) {
  final messageBytes = encodeMetadataArgs(metadataArgs);
  final data = Uint8List(
    verifyCreatorInstructionDiscriminator.length + messageBytes.length,
  );
  data.setRange(
    0,
    verifyCreatorInstructionDiscriminator.length,
    verifyCreatorInstructionDiscriminator,
  );
  data.setRange(
    verifyCreatorInstructionDiscriminator.length,
    data.length,
    messageBytes,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.readonly),
      AccountMeta(address: leafOwner, role: AccountRole.readonly),
      AccountMeta(address: leafDelegate, role: AccountRole.readonly),
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.readonlySigner),
      AccountMeta(address: creator, role: AccountRole.readonlySigner),
      AccountMeta(address: logWrapper, role: AccountRole.readonly),
      AccountMeta(address: compressionProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: data,
  );
}
