// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/metadata_args.dart';

/// MintV1 instruction data for mpl-bubblegum compressed NFTs.
@immutable
class MintV1InstructionData {
  const MintV1InstructionData({
    this.discriminator = 14,
    required this.metadataArgs,
  });

  final int discriminator;
  final MetadataArgs metadataArgs;
}

/// Creates a [MintV1] instruction.
///
/// Mints a new compressed NFT with V1 metadata. The metadata is serialized
/// using borsh encoding and hashed into the Merkle tree leaf.
///
/// ## Accounts
/// - [treeAuthority] — Writable (the tree authority PDA)
/// - [leafOwner] — Read-only (the new asset owner)
/// - [leafDelegate] — Read-only (optional delegate, usually same as owner)
/// - [merkleTree] — Writable (the compressed NFT tree)
/// - [payer] — Read-only (pays for the transaction)
/// - [treeDelegate] — Read-only (signer, must be tree authority delegate)
/// - [logWrapper] — Read-only (noop program)
/// - [compressionProgram] — Read-only (SPL Account Compression)
/// - [systemProgram] — Read-only (System program)
Instruction getMintV1Instruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address leafOwner,
  required Address leafDelegate,
  required Address merkleTree,
  required Address payer,
  required Address treeDelegate,
  required Address logWrapper,
  required Address compressionProgram,
  required Address systemProgram,
  required MetadataArgs metadataArgs,
}) {
  // Build the instruction data: discriminator (u8) + borsh-encoded MetadataArgs
  final metadataBytes = encodeMetadataArgs(metadataArgs);
  final data = Uint8List(1 + metadataBytes.length);
  data[0] = 14; // discriminator
  data.setRange(1, data.length, metadataBytes);

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.writable),
      AccountMeta(address: leafOwner, role: AccountRole.readonly),
      AccountMeta(address: leafDelegate, role: AccountRole.readonly),
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.readonlySigner),
      AccountMeta(address: treeDelegate, role: AccountRole.readonlySigner),
      AccountMeta(address: logWrapper, role: AccountRole.readonly),
      AccountMeta(address: compressionProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: data,
  );
}