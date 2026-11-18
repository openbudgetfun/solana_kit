import 'dart:typed_data';

import 'package:solana_kit_privacy_rings/src/exception.dart';
import 'package:solana_kit_privacy_rings/src/poseidon/poseidon.dart';

/// Tree slots a transact proof publishes. Mirrors `INPUT_TREES`.
const inputTreeCount = 5;

/// One public tree slot: a `u16` id and the two roots the proof opens.
class ProofTreeSlot {
  /// Creates a slot. Both roots are 32 bytes.
  ProofTreeSlot({
    required this.id,
    required List<int> utxoRoot,
    required List<int> nullifierRoot,
  }) : utxoRoot = _field(utxoRoot, 'utxo root'),
       nullifierRoot = _field(nullifierRoot, 'nullifier root') {
    if (id < 0 || id > 0xffff) {
      throw PrivacyRingsException(
        'tree id $id is outside 0..65535',
        code: 'integer_range',
      );
    }
  }

  /// Raw tree id.
  final int id;

  /// UTXO root the proof opens against.
  final Uint8List utxoRoot;

  /// Nullifier root the proof opens against.
  final Uint8List nullifierRoot;

  /// Prover JSON for this slot.
  Map<String, Object?> toJson() {
    return {
      'id': fieldHex(treeIdField(id)),
      'utxoRoot': fieldHex(utxoRoot),
      'nullifierRoot': fieldHex(nullifierRoot),
    };
  }
}

/// Right-aligned big-endian encoding of a `u16` tree id.
Uint8List treeIdField(int treeId) {
  if (treeId < 0 || treeId > 0xffff) {
    throw PrivacyRingsException(
      'tree id $treeId is outside 0..65535',
      code: 'integer_range',
    );
  }
  return rightAlign([(treeId >> 8) & 0xff, treeId & 0xff]);
}

/// `Poseidon(tree_id, utxo_root, nullifier_root)`.
Uint8List treeSlotHash(ProofTreeSlot slot) {
  return poseidonHash([
    treeIdField(slot.id),
    slot.utxoRoot,
    slot.nullifierRoot,
  ]);
}

/// Right fold of exactly [inputTreeCount] slot hashes.
///
/// `tree_slots_hash_chain`. The verifier starts from a precomputed
/// all-zero suffix, so the fold runs from the last slot toward the first.
Uint8List treeSlotsHashChain(List<ProofTreeSlot> slots) {
  if (slots.length != inputTreeCount) {
    throw PrivacyRingsException(
      'a tree slot chain takes $inputTreeCount slots, received ${slots.length}',
      code: 'invalid_length',
    );
  }
  final hashes = [for (final slot in slots) treeSlotHash(slot)];
  var chain = hashes[inputTreeCount - 1];
  for (var index = inputTreeCount - 2; index >= 0; index--) {
    chain = poseidonHash([hashes[index], chain]);
  }
  return chain;
}

/// Folds three elements per Poseidon call, left to right.
///
/// `hash_chain_4`. An empty list is zero. The fold carries no length tag.
Uint8List hashChain4(List<Uint8List> values) {
  if (values.isEmpty) return Uint8List(32);
  var result = _field(values.first, 'hash chain');
  for (var index = 1; index < values.length; index += 3) {
    result = poseidonHash([
      result,
      _at(values, index),
      _at(values, index + 1),
      _at(values, index + 2),
    ]);
  }
  return result;
}

/// Folds one element per Poseidon call from the right.
///
/// `create_right_hash_chain`. An empty list is zero.
Uint8List rightHashChain(List<Uint8List> values) {
  if (values.isEmpty) return Uint8List(32);
  var result = _field(values.last, 'hash chain');
  for (var index = values.length - 2; index >= 0; index--) {
    result = poseidonHash([_field(values[index], 'hash chain'), result]);
  }
  return result;
}

/// Folds three elements per Poseidon call from the right.
///
/// `create_right_hash_chain_4`. The short group is the leftmost one and
/// stays left-aligned beside the running hash.
Uint8List rightHashChain4(List<Uint8List> values) {
  if (values.isEmpty) return Uint8List(32);
  var result = _field(values.last, 'hash chain');
  var end = values.length - 1;
  while (end > 0) {
    final start = end - 3 < 0 ? 0 : end - 3;
    final group = <Uint8List>[
      Uint8List(32),
      Uint8List(32),
      Uint8List(32),
      result,
    ];
    for (var index = start; index < end; index++) {
      group[index - start] = _field(values[index], 'hash chain');
    }
    result = poseidonHash(group);
    end = start;
  }
  return result;
}

/// Public inputs of a confidential transfer, before the tree-slot fold.
///
/// `transfer_public_inputs`. [publishedOutputOwnerPublicKeyHashes] null
/// omits the owner chain and the cache fields. A shorter owner list is
/// padded with zeros out to [outputHashes].
List<Uint8List> transferPublicInputs({
  required List<Uint8List> nullifiers,
  required List<Uint8List> outputHashes,
  required int outputTreeId,
  required Uint8List privateTxHash,
  required Uint8List externalDataHash,
  required List<Uint8List> publicAssets,
  required List<Uint8List> publicAmounts,
  required Uint8List ringProgramId,
  required List<Uint8List> signerPublicKeyHashes,
  required Uint8List inputFlags,
  List<Uint8List> afterPrivateTxHash = const [],
  List<Uint8List>? publishedOutputOwnerPublicKeyHashes,
  Uint8List? cacheTreeId,
  Uint8List? cacheReadHashChain,
}) {
  if (publicAssets.length != publicAmounts.length) {
    throw PrivacyRingsException(
      'public assets and amounts differ in length',
      code: 'invalid_length',
    );
  }
  final fields = <Uint8List>[
    rightHashChain4(nullifiers),
    rightHashChain4(outputHashes),
    treeIdField(outputTreeId),
    _field(privateTxHash, 'private tx hash'),
    for (final field in afterPrivateTxHash) _field(field, 'eddsa field'),
    _field(externalDataHash, 'external data hash'),
    for (var i = 0; i < publicAssets.length; i++) ...[
      _field(publicAssets[i], 'public asset'),
      _field(publicAmounts[i], 'public amount'),
    ],
    _field(ringProgramId, 'ring program'),
    rightHashChain(signerPublicKeyHashes),
    _field(inputFlags, 'input flags'),
  ];
  final owners = publishedOutputOwnerPublicKeyHashes;
  if (owners != null) {
    if (cacheTreeId == null || cacheReadHashChain == null) {
      throw PrivacyRingsException(
        'a published owner chain needs the cache fields',
        code: 'invalid_length',
      );
    }
    final padded = [
      for (final owner in owners) _field(owner, 'output owner'),
      for (var i = owners.length; i < outputHashes.length; i++) Uint8List(32),
    ];
    fields
      ..add(rightHashChain4(padded))
      ..add(_field(cacheTreeId, 'cache tree'))
      ..add(_field(cacheReadHashChain, 'cache read chain'));
  }
  return fields;
}

/// `transfer_public_input_hash`: the public inputs with the slot chain
/// inserted after the nullifier and output chains, then `hash_chain_4`.
Uint8List transferPublicInputHash({
  required List<Uint8List> nullifiers,
  required List<Uint8List> outputHashes,
  required int outputTreeId,
  required Uint8List privateTxHash,
  required Uint8List externalDataHash,
  required List<Uint8List> publicAssets,
  required List<Uint8List> publicAmounts,
  required Uint8List ringProgramId,
  required List<Uint8List> signerPublicKeyHashes,
  required Uint8List inputFlags,
  required List<ProofTreeSlot> treeSlots,
  List<Uint8List> afterPrivateTxHash = const [],
  List<Uint8List>? publishedOutputOwnerPublicKeyHashes,
  Uint8List? cacheTreeId,
  Uint8List? cacheReadHashChain,
}) {
  final fields = transferPublicInputs(
    nullifiers: nullifiers,
    outputHashes: outputHashes,
    outputTreeId: outputTreeId,
    privateTxHash: privateTxHash,
    afterPrivateTxHash: afterPrivateTxHash,
    externalDataHash: externalDataHash,
    publicAssets: publicAssets,
    publicAmounts: publicAmounts,
    ringProgramId: ringProgramId,
    signerPublicKeyHashes: signerPublicKeyHashes,
    inputFlags: inputFlags,
    publishedOutputOwnerPublicKeyHashes: publishedOutputOwnerPublicKeyHashes,
    cacheTreeId: cacheTreeId,
    cacheReadHashChain: cacheReadHashChain,
  );
  return hashChain4([
    fields[0],
    fields[1],
    treeSlotsHashChain(treeSlots),
    ...fields.skip(2),
  ]);
}

/// The `u16` stored in a right-aligned tree-id field.
int treeIdFromField(Uint8List field) {
  final bytes = _field(field, 'tree id');
  for (var i = 0; i < 30; i++) {
    if (bytes[i] != 0) {
      throw PrivacyRingsException(
        'tree id field is wider than a u16',
        code: 'integer_range',
      );
    }
  }
  return (bytes[30] << 8) | bytes[31];
}

Uint8List _at(List<Uint8List> values, int index) {
  if (index >= values.length) return Uint8List(32);
  return _field(values[index], 'hash chain');
}

Uint8List _field(List<int> bytes, String name) {
  if (bytes.length != 32) {
    throw PrivacyRingsException(
      '$name is ${bytes.length} bytes, the field takes 32',
      code: 'invalid_length',
    );
  }
  return Uint8List.fromList(bytes);
}
