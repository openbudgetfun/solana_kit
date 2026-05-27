/// Keccak-256 hashing utilities for mpl-bubblegum compressed NFTs.
///
/// The Bubblegum program uses Keccak-256 (not SHA3-256) for all hashing
/// operations. This module provides the core `hash` function and the
/// higher-level `hashMetadata`/`hashMetadataV2` functions used to compute
/// leaf hashes for V1 and V2 compressed NFTs.
///
/// ## Keccak-256 vs SHA3-256
///
/// Keccak-256 uses padding byte `0x01`, while SHA3-256 uses `0x06`.
/// The [keccak256] function from `solana_kit_codecs_core` implements the
/// correct Keccak-256 variant.
library;

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

/// Computes a Keccak-256 hash of the input.
///
/// If [input] is a single [Uint8List], hashes it directly.
/// If [input] is a list of [Uint8List]s, concatenates them first.
///
/// This is the fundamental hash function used by the Bubblegum program
/// for leaf hashing, Merkle tree node computation, and metadata hashing.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';
///
/// void main() {
///   final result = bubblegumHash([Uint8List.fromList([1, 2, 3])]);
///   print(result); // 32-byte Keccak-256 digest
/// }
/// ```
Uint8List bubblegumHash(List<Uint8List> input) {
  if (input.length == 1) {
    return keccak256(input.first);
  }
  return keccak256(
    input.fold<Uint8List>(
      Uint8List(0),
      (acc, chunk) => Uint8List.fromList([...acc, ...chunk]),
    ),
  );
}
