/// Leaf asset ID PDA derivation for mpl-bubblegum V2 compressed NFTs.
///
/// The leaf asset ID is a PDA derived from the Merkle tree address and
/// the leaf index, used as a unique identifier for compressed NFT assets
/// in the DAS (Digital Asset Standard) API.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_mpl_bubblegum/src/program_address.dart';

/// Writes an int64 value in little-endian format.
///
/// This is a helper for encoding leaf indices as 8-byte LE values.
Uint8List _writeUInt64LE(int value) {
  final buffer = Uint8List(8);
  for (var i = 0; i < 8; i++) {
    // ignore: avoid_js_rounding
    buffer[i] = (value >> (8 * i)) & 0xFF;
  }
  return buffer;
}

/// Derives the leaf asset ID PDA for a given Merkle tree and leaf index.
///
/// In Bubblegum V2, each compressed NFT is identified by a PDA derived
/// from the Merkle tree address and the leaf index within that tree.
/// This PDA is used as the asset ID when interacting with the DAS API.
///
/// The PDA is derived using seeds `[merkleTree, leafIndexAsU64LE]` and
/// the Bubblegum program ID.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
///
/// void main() async {
///   final merkleTree = Address('...merkle tree address...');
///   final (assetId, bump) = await findLeafAssetIdPda(
///     merkleTree: merkleTree,
///     leafIndex: 42,
///   );
///   print(assetId); // The derived leaf asset ID
/// }
/// ```
Future<ProgramDerivedAddress> findLeafAssetIdPda({
  required Address merkleTree,
  required int leafIndex,
}) {
  final leafIndexBuffer = _writeUInt64LE(leafIndex);

  return getProgramDerivedAddress(
    programAddress: mplBubblegumProgramAddressObject,
    seeds: [getAddressEncoder().encode(merkleTree), leafIndexBuffer],
  );
}
