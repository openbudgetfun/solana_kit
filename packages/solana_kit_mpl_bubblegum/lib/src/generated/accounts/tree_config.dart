// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/enums.dart';

/// TreeConfig account data for mpl-bubblegum.
///
/// This account stores the configuration for a compressed NFT Merkle tree.
/// It is derived from the tree address and the Bubblegum program ID.
@immutable
class TreeConfigAccount {
  const TreeConfigAccount({
    required this.treeCreator,
    required this.treeDelegate,
    required this.totalMintCapacity,
    required this.numMinted,
    required this.isPublic,
    required this.isDecompressible,
    required this.version,
  });

  /// The creator/owner of the tree.
  final Address treeCreator;

  /// The delegate who can perform operations on the tree.
  final Address treeDelegate;

  /// The total mint capacity (2^maxDepth).
  final int totalMintCapacity;

  /// The number of NFTs minted so far.
  final int numMinted;

  /// Whether the tree is public (anyone can mint) or private (only delegate).
  final bool isPublic;

  /// Whether the tree supports decompression.
  final DecompressibleState isDecompressible;

  /// The version of the tree config (V1 or V2).
  final Version version;

  /// Size of the serialized account data (excluding discriminator).
  static const int size = 89; // 32 + 32 + 8 + 8 + 1 + 1 + 1 + 6 (padding)
}

/// Decodes a TreeConfig account from raw bytes.
///
/// The input should include the 8-byte Anchor discriminator prefix.
TreeConfigAccount decodeTreeConfigAccount(Uint8List data) {
  if (data.length < 8 + TreeConfigAccount.size) {
    throw ArgumentError(
      'Invalid TreeConfig account data: expected at least ${8 + TreeConfigAccount.size} bytes, '
      'got ${data.length}',
    );
  }

  // Skip 8-byte discriminator
  var offset = 8;

  // treeCreator (32 bytes)
  final treeCreator = Address(
    _bytesToBase58(data.sublist(offset, offset + 32)),
  );
  offset += 32;

  // treeDelegate (32 bytes)
  final treeDelegate = Address(
    _bytesToBase58(data.sublist(offset, offset + 32)),
  );
  offset += 32;

  // totalMintCapacity (u64 LE)
  final totalMintCapacity = _readU64LE(data, offset);
  offset += 8;

  // numMinted (u64 LE)
  final numMinted = _readU64LE(data, offset);
  offset += 8;

  // isPublic (bool)
  final isPublic = data[offset] != 0;
  offset += 1;

  // isDecompressible (u8 enum)
  final decompressibleValue = data[offset];
  final isDecompressible = decompressibleValue == 0
      ? DecompressibleState.enabled
      : DecompressibleState.disabled;
  offset += 1;

  // version (u8 enum)
  final versionValue = data[offset];
  final version = versionValue == 0 ? Version.v1 : Version.v2;

  return TreeConfigAccount(
    treeCreator: treeCreator,
    treeDelegate: treeDelegate,
    totalMintCapacity: totalMintCapacity,
    numMinted: numMinted,
    isPublic: isPublic,
    isDecompressible: isDecompressible,
    version: version,
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

  // Count leading zeros
  var leadingZeros = 0;
  for (var i = 0; i < bytes.length && bytes[i] == 0; i++) {
    leadingZeros++;
  }

  // Convert to base58
  final result = <int>[];
  var num = BigInt.zero;
  for (final byte in bytes) {
    num = num * BigInt.from(256) + BigInt.from(byte);
  }

  while (num > BigInt.zero) {
    final (quotient, remainder) = (
      num ~/ BigInt.from(58),
      num % BigInt.from(58),
    );
    result.add(alphabet.codeUnitAt(remainder.toInt()));
    num = quotient;
  }

  // Add leading '1's for leading zeros
  for (var i = 0; i < leadingZeros; i++) {
    result.add(alphabet.codeUnitAt(0));
  }

  return String.fromCharCodes(result.reversed);
}
