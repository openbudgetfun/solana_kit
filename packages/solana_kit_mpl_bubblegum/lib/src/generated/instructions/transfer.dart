// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Transfer instruction data for mpl-bubblegum compressed NFTs.
@immutable
class TransferInstructionData {
  const TransferInstructionData({
    this.discriminator = 25,
    required this.root,
    required this.dataHash,
    required this.creatorHash,
    required this.nonce,
    required this.index,
  });

  final int discriminator;
  final List<int> root;
  final List<int> dataHash;
  final List<int> creatorHash;
  final int nonce;
  final int index;
}

/// Returns the encoder for [TransferInstructionData].
Encoder<TransferInstructionData> getTransferInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('root', getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32))),
    ('dataHash', getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32))),
    ('creatorHash', getArrayEncoder(getU8Encoder(), size: const FixedArraySize(32))),
    ('nonce', getU64Encoder()),
    ('index', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TransferInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'root': Uint8List.fromList(value.root),
      'dataHash': Uint8List.fromList(value.dataHash),
      'creatorHash': Uint8List.fromList(value.creatorHash),
      'nonce': value.nonce,
      'index': value.index,
    },
  );
}

/// Returns the decoder for [TransferInstructionData].
Decoder<TransferInstructionData> getTransferInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('root', getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32))),
    ('dataHash', getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32))),
    ('creatorHash', getArrayDecoder(getU8Decoder(), size: const FixedArraySize(32))),
    ('nonce', getU64Decoder()),
    ('index', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        TransferInstructionData(
          discriminator: map['discriminator']! as int,
          root: (map['root']! as List<int>).toList(),
          dataHash: (map['dataHash']! as List<int>).toList(),
          creatorHash: (map['creatorHash']! as List<int>).toList(),
          nonce: map['nonce']! as int,
          index: map['index']! as int,
        ),
  );
}

/// Returns the codec for [TransferInstructionData].
Codec<TransferInstructionData, TransferInstructionData>
    getTransferInstructionDataCodec() {
  return combineCodec(
    getTransferInstructionDataEncoder(),
    getTransferInstructionDataDecoder(),
  );
}

/// Creates a [Transfer] instruction.
///
/// Transfers ownership of a compressed NFT. The transaction must be
/// signed by either the leaf owner or leaf delegate.
///
/// ## Accounts
/// - [treeAuthority] — Read-only
/// - [leafOwner] — Read-only (the current asset owner)
/// - [leafDelegate] — Read-only (if delegated, else same as leafOwner)
/// - [newLeafOwner] — Read-only (the new asset owner)
/// - [merkleTree] — Writable
/// - [logWrapper] — Read-only (noop program)
/// - [compressionProgram] — Read-only
/// - [systemProgram] — Read-only
Instruction getTransferInstruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address leafOwner,
  required Address leafDelegate,
  required Address newLeafOwner,
  required Address merkleTree,
  required Address logWrapper,
  required Address compressionProgram,
  required Address systemProgram,
  required List<int> root,
  required List<int> dataHash,
  required List<int> creatorHash,
  required int nonce,
  required int index,
}) {
  final instructionData = TransferInstructionData(
    root: root,
    dataHash: dataHash,
    creatorHash: creatorHash,
    nonce: nonce,
    index: index,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.readonly),
      AccountMeta(address: leafOwner, role: AccountRole.readonly),
      AccountMeta(address: leafDelegate, role: AccountRole.readonly),
      AccountMeta(address: newLeafOwner, role: AccountRole.readonly),
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: logWrapper, role: AccountRole.readonly),
      AccountMeta(address: compressionProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getTransferInstructionDataEncoder().encode(instructionData),
  );
}