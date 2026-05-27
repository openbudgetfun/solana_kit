// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/metadata_args.dart';

/// decompressV1 instruction data.
@immutable
class decompressV1InstructionData {
  const decompressV1InstructionData({
    this.discriminator = 8,
    required this.metadataArgs,
  });

  final int discriminator;
  final MetadataArgs metadataArgs;
}

/// Creates a [decompressV1] instruction.
Instruction getdecompressV1Instruction({
  required Address programAddress,
  required Address voucher,
  required Address leafOwner,
  required Address tokenAccount,
  required Address mint,
  required Address mintAuthority,
  required Address metadata,
  required Address masterEdition,
  required Address systemProgram,
  required Address sysvarRent,
  required Address tokenMetadataProgram,
  required Address tokenProgram,
  required Address associatedTokenProgram,
  required Address logWrapper,
  required MetadataArgs metadataArgs,
}) {
  final messageBytes = encodeMetadataArgs(metadataArgs);
  final data = Uint8List(1 + messageBytes.length);
  data[0] = 8;
  data.setRange(1, data.length, messageBytes);

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: voucher, role: AccountRole.writable),
      AccountMeta(address: leafOwner, role: AccountRole.writableSigner),
      AccountMeta(address: tokenAccount, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: mintAuthority, role: AccountRole.writable),
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: masterEdition, role: AccountRole.writable),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: sysvarRent, role: AccountRole.readonly),
      AccountMeta(address: tokenMetadataProgram, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: associatedTokenProgram, role: AccountRole.readonly),
      AccountMeta(address: logWrapper, role: AccountRole.readonly),
    ],
    data: data,
  );
}
