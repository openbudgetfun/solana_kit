import 'dart:typed_data';

import 'package:solana_kit_privacy_rings/src/exception.dart';
import 'package:solana_kit_privacy_rings/src/poseidon/poseidon.dart';

/// Algorithm tag of an Ed25519 or PDA owner identity, `'S'`.
const solanaOwnerTag = 0x53;

/// `"TXOS"`: the seed every transact output blinding derives from.
const domainTransactOutputBlindingSeed = 0x54584f53;

/// `"TXOB"`: one transact output blinding per output slot.
const domainTransactOutputBlinding = 0x54584f42;

/// `"TXPB"`: the blinding that keeps the private transaction hash unguessable.
const domainPrivateTxBlinding = 0x54585042;

/// Packs [bytes] into 31-byte fields and folds them like Rust `hash_bytes`.
///
/// An empty input is 32 zero bytes. Each chunk is right-aligned into a
/// field element. Later chunks are `Poseidon(previous, chunk)`.
Uint8List hashBytes(List<int> bytes) {
  if (bytes.isEmpty) return Uint8List(32);
  var offset = 0;
  var result = rightAlign(
    bytes.sublist(0, bytes.length < 31 ? bytes.length : 31),
  );
  offset = 31;
  while (offset < bytes.length) {
    final end = offset + 31 < bytes.length ? offset + 31 : bytes.length;
    result = poseidonHash([result, rightAlign(bytes.sublist(offset, end))]);
    offset += 31;
  }
  return result;
}

/// Hashes the Solana owner tag with a 32-byte identity key.
Uint8List solanaOwnerIdentity(List<int> key) {
  if (key.length != 32) {
    throw PrivacyRingsException(
      'an owner identity takes a 32-byte key',
      code: 'invalid_length',
    );
  }
  return hashBytes([solanaOwnerTag, ...key]);
}

/// `Poseidon(ownerProofInputHash, nullifierPublicKey)`.
Uint8List ownerHash(
  Uint8List ownerProofInputHash,
  Uint8List nullifierPublicKey,
) {
  return poseidonHash([ownerProofInputHash, nullifierPublicKey]);
}

/// `Poseidon("TXOS", firstNullifier, blindingSeed)`.
Uint8List outputBlindingSeed(Uint8List firstNullifier, Uint8List blindingSeed) {
  return poseidonHash([
    fieldU32(domainTransactOutputBlindingSeed),
    firstNullifier,
    blindingSeed,
  ]);
}

/// `Poseidon("TXPB", firstNullifier, secret)`.
Uint8List privateTxBlinding(Uint8List firstNullifier, Uint8List secret) {
  return poseidonHash([
    fieldU32(domainPrivateTxBlinding),
    firstNullifier,
    secret,
  ]);
}

/// `Poseidon("TXOB", firstNullifier, outputBlindingSeed, index)`.
Uint8List transactOutputBlinding(
  Uint8List firstNullifier,
  Uint8List outputSeed,
  int index,
) {
  return poseidonHash([
    fieldU32(domainTransactOutputBlinding),
    firstNullifier,
    outputSeed,
    fieldU32(index),
  ]);
}

/// Commitment of one note, matching `Utxo::hash_with` in
/// `sdk-libs/transaction/src/circuit/utxo.rs`.
///
/// The seventh input is `Poseidon(ringDataHash, ringProgramId)` and the
/// eighth is `Poseidon(owner, blinding)`. [assetHash] is [hashBytes] of
/// the mint. Every field is 32 bytes.
Uint8List utxoCommitment({
  required Uint8List domain,
  required Uint8List treeId,
  required Uint8List assetHash,
  required Uint8List amount,
  required Uint8List dataHash,
  required Uint8List ringDataHash,
  required Uint8List ringProgramId,
  required Uint8List owner,
  required Uint8List blinding,
}) {
  return poseidonHash([
    domain,
    treeId,
    assetHash,
    amount,
    dataHash,
    poseidonHash([ringDataHash, ringProgramId]),
    poseidonHash([owner, blinding]),
  ]);
}
