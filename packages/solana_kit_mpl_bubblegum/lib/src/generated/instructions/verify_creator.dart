// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/metadata_args.dart';

/// verifyCreator instruction data.
@immutable
class verifyCreatorInstructionData {
  const verifyCreatorInstructionData({
    this.discriminator = 34,
    required this.metadataArgs,
  });

  final int discriminator;
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
  final data = Uint8List(1 + messageBytes.length);
  data[0] = 34;
  data.setRange(1, data.length, messageBytes);

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
