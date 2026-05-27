// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/enums.dart';

/// Voucher account data for mpl-bubblegum.
///
/// This account stores the leaf schema data for a decompressed NFT.
/// It is created when a compressed NFT is decompressed.
@immutable
class VoucherAccount {
  const VoucherAccount({
    required this.leafSchema,
    required this.index,
    required this.merkleTree,
  });

  /// The leaf schema data.
  final LeafSchemaData leafSchema;

  /// The index of the leaf in the Merkle tree.
  final int index;

  /// The address of the Merkle tree.
  final Address merkleTree;

  /// Size of the serialized account data (excluding discriminator).
  static const int size = 169; // 1(variant) + 6*32 + 8 + 32 + 4 + 32 + padding
}

/// Leaf schema data (V1 or V2).
@immutable
class LeafSchemaData {
  const LeafSchemaData({
    required this.version,
    required this.id,
    required this.owner,
    required this.delegate,
    required this.nonce,
    required this.dataHash,
    required this.creatorHash,
    this.flags,
  });

  /// The leaf schema version.
  final LeafSchemaVersion version;

  /// The asset ID (leaf asset ID PDA).
  final Address id;

  /// The owner of the leaf.
  final Address owner;

  /// The delegate of the leaf.
  final Address delegate;

  /// The nonce (sequence number).
  final int nonce;

  /// The data hash.
  final Uint8List dataHash;

  /// The creator hash.
  final Uint8List creatorHash;

  /// V2 only: flags byte.
  final int? flags;
}

/// Decodes a Voucher account from raw bytes.
///
/// The input should include the 8-byte Anchor discriminator prefix.
VoucherAccount decodeVoucherAccount(Uint8List data) {
  if (data.length < 8 + VoucherAccount.size) {
    throw ArgumentError(
      'Invalid Voucher account data: expected at least ${8 + VoucherAccount.size} bytes, '
      'got ${data.length}',
    );
  }

  // Skip 8-byte discriminator
  var offset = 8;

  // leafSchema (enum variant)
  final versionByte = data[offset];
  final version = versionByte == 0 ? LeafSchemaVersion.v1 : LeafSchemaVersion.v2;
  offset += 1;

  // id (32 bytes)
  final id = Address(_bytesToBase58(data.sublist(offset, offset + 32)));
  offset += 32;

  // owner (32 bytes)
  final owner = Address(_bytesToBase58(data.sublist(offset, offset + 32)));
  offset += 32;

  // delegate (32 bytes)
  final delegate = Address(_bytesToBase58(data.sublist(offset, offset + 32)));
  offset += 32;

  // nonce (u64 LE)
  final nonce = _readU64LE(data, offset);
  offset += 8;

  // dataHash (32 bytes)
  final dataHash = Uint8List.fromList(data.sublist(offset, offset + 32));
  offset += 32;

  // creatorHash (32 bytes)
  final creatorHash = Uint8List.fromList(data.sublist(offset, offset + 32));
  offset += 32;

  // V2: flags (u8, optional)
  int? flags;
  if (version == LeafSchemaVersion.v2 && offset < data.length) {
    flags = data[offset];
    offset += 1;
  }

  final leafSchema = LeafSchemaData(
    version: version,
    id: id,
    owner: owner,
    delegate: delegate,
    nonce: nonce,
    dataHash: dataHash,
    creatorHash: creatorHash,
    flags: flags,
  );

  // index (u32 LE)
  final index = data[offset] |
      (data[offset + 1] << 8) |
      (data[offset + 2] << 16) |
      (data[offset + 3] << 24);
  offset += 4;

  // merkleTree (32 bytes)
  final merkleTree = Address(_bytesToBase58(data.sublist(offset, offset + 32)));

  return VoucherAccount(
    leafSchema: leafSchema,
    index: index,
    merkleTree: merkleTree,
  );
}

int _readU64LE(Uint8List data, int offset) {
  var value = 0;
  for (var i = 0; i < 8; i++) {
    value |= data[offset + i] << (8 * i);
  }
  return value;
}

String _bytesToBase58(List<int> bytes) {
  const alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  if (bytes.isEmpty) return '';

  var leadingZeros = 0;
  for (var i = 0; i < bytes.length && bytes[i] == 0; i++) {
    leadingZeros++;
  }

  final result = <int>[];
  var num = BigInt.zero;
  for (final byte in bytes) {
    num = num * BigInt.from(256) + BigInt.from(byte);
  }

  while (num > BigInt.zero) {
    final (quotient, remainder) = (num ~/ BigInt.from(58), num % BigInt.from(58));
    result.add(alphabet.codeUnitAt(remainder.toInt()));
    num = quotient;
  }

  for (var i = 0; i < leadingZeros; i++) {
    result.add(alphabet.codeUnitAt(0));
  }

  return String.fromCharCodes(result.reversed);
}