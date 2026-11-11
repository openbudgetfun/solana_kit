import 'dart:typed_data';

import 'package:solana_kit_privacy_rings/src/exception.dart';
import 'package:solana_kit_privacy_rings/src/keys/nullifier.dart';
import 'package:solana_kit_privacy_rings/src/poseidon/hash.dart';
import 'package:solana_kit_privacy_rings/src/poseidon/poseidon.dart';

/// One note field the transfer circuit hashes.
///
/// The names match `utxoJson` in
/// `sdk-libs/ts/src/client/prover/client.ts`.
class CircuitNote {
  /// Creates a note preimage. Every field is 32 bytes.
  CircuitNote({
    required List<int> domain,
    required List<int> owner,
    required List<int> asset,
    required List<int> amount,
    required List<int> blinding,
    required List<int> dataHash,
    required List<int> ringDataHash,
    required List<int> ringProgramId,
  }) : domain = Uint8List.fromList(domain),
       owner = Uint8List.fromList(owner),
       asset = Uint8List.fromList(asset),
       amount = Uint8List.fromList(amount),
       blinding = Uint8List.fromList(blinding),
       dataHash = Uint8List.fromList(dataHash),
       ringDataHash = Uint8List.fromList(ringDataHash),
       ringProgramId = Uint8List.fromList(ringProgramId);

  /// Domain tag, as a field element.
  final Uint8List domain;

  /// Owner field hashed with [blinding] inside the commitment.
  final Uint8List owner;

  /// `hashBytes` of the mint.
  final Uint8List asset;

  /// Amount, as a field element.
  final Uint8List amount;

  /// Note blinding.
  final Uint8List blinding;

  /// Application data hash. Zero when the note carries none.
  final Uint8List dataHash;

  /// Ring data hash. Zero outside a custom ring.
  final Uint8List ringDataHash;

  /// Ring program id field. Zero outside a custom ring.
  final Uint8List ringProgramId;

  /// Commitment in [treeId], from `Utxo::hash_with`.
  Uint8List commitment(Uint8List treeId) {
    return utxoCommitment(
      domain: domain,
      treeId: treeId,
      assetHash: asset,
      amount: amount,
      dataHash: dataHash,
      ringDataHash: ringDataHash,
      ringProgramId: ringProgramId,
      owner: owner,
      blinding: blinding,
    );
  }

  /// JSON object the prover names `utxo`.
  Map<String, Object?> toJson() {
    return {
      'domain': fieldHex(domain),
      'owner': fieldHex(owner),
      'asset': fieldHex(asset),
      'amount': fieldHex(amount),
      'blinding': fieldHex(blinding),
      'dataHash': fieldHex(dataHash),
      'ringDataHash': fieldHex(ringDataHash),
      'ringProgramId': fieldHex(ringProgramId),
    };
  }
}

/// One spend the confidential-transfer witness publishes.
class WitnessInput {
  /// Creates an input.
  WitnessInput({
    required this.note,
    required this.treeSlot,
    required this.treeId,
    required this.ownerPublicKeyHash,
    required this.nullifierSecret,
    this.isDummy = false,
    this.statePathElements = const [],
    this.statePathIndex,
    this.nullifierLowValue,
    this.nullifierNextValue,
    this.nullifierLowPathElements = const [],
    this.nullifierLowPathIndex,
  });

  /// Note opened by this input.
  final CircuitNote note;

  /// Tree slot field.
  final Uint8List treeSlot;

  /// Tree id field used in the commitment.
  final Uint8List treeId;

  /// Owner public-key hash field.
  final Uint8List ownerPublicKeyHash;

  /// 31-byte nullifier secret. The witness right-aligns it.
  final Uint8List nullifierSecret;

  /// Padding input.
  final bool isDummy;

  /// Merkle path, when the caller has one.
  final List<Uint8List> statePathElements;

  /// Merkle path index field.
  final Uint8List? statePathIndex;

  /// Non-inclusion low value.
  final Uint8List? nullifierLowValue;

  /// Non-inclusion next value.
  final Uint8List? nullifierNextValue;

  /// Non-inclusion low path.
  final List<Uint8List> nullifierLowPathElements;

  /// Non-inclusion low path index.
  final Uint8List? nullifierLowPathIndex;
}

/// One new note the witness creates.
class WitnessOutput {
  /// Creates an output.
  WitnessOutput({
    required this.note,
    required this.treeId,
    required this.ownerPublicKeyHash,
    required this.nullifierPublicKey,
    this.isDummy = false,
  });

  /// Note preimage. Its blinding is the value the circuit checks.
  final CircuitNote note;

  /// Output tree id field.
  final Uint8List treeId;

  /// Owner public-key hash field.
  final Uint8List ownerPublicKeyHash;

  /// Nullifier public key of the recipient.
  final Uint8List nullifierPublicKey;

  /// Padding output.
  final bool isDummy;
}

/// JSON body of `POST /prove/transfer_confidential_*`.
///
/// The key set and the `0x` hex encoding match `proverRequest` in
/// `sdk-libs/ts/src/client/prover/client.ts` for circuit `transfer`.
/// Commitments, nullifiers, and output blindings are Poseidon hashes.
/// Merkle paths are included only when the caller supplied them: the
/// indexer is the source of those siblings.
Map<String, Object?> confidentialTransferWitness({
  required List<WitnessInput> inputs,
  required List<WitnessOutput> outputs,
  required Uint8List outputTreeId,
  required Uint8List externalDataHash,
  required Uint8List privateTxHash,
  required Uint8List blindingSeed,
  required Uint8List ringProgramId,
  required List<Uint8List> publicAssets,
  required List<Uint8List> publicAmounts,
  required List<Uint8List> signerPublicKeyHashes,
  required Uint8List inputFlags,
  required List<Uint8List> publishedOutputOwnerPublicKeyHashes,
  required Uint8List cacheTreeId,
  required Uint8List cacheReadHashChain,
  required List<Uint8List> cacheReadHashes,
  required List<Uint8List> cacheIsCached,
  required List<Uint8List> cacheReadIndex,
}) {
  if (inputs.isEmpty) {
    throw PrivacyRingsException(
      'a transfer witness needs one input',
      code: 'invalid_length',
    );
  }
  String hex(Uint8List bytes) => fieldHex(bytes);
  List<String> hexes(List<Uint8List> values) => values.map(fieldHex).toList();
  final key = NullifierKey.fromSecret(inputs.first.nullifierSecret);
  final firstNullifier = key.nullifier(
    inputs.first.note.commitment(inputs.first.treeId),
    inputs.first.note.blinding,
  );
  key.destroy();
  final outputSeed = outputBlindingSeed(firstNullifier, blindingSeed);
  return {
    'circuitType': 'transfer-confidential',
    'nInputs': inputs.length,
    'nOutputs': outputs.length,
    'inputs': [
      for (final input in inputs) _inputJson(input),
    ],
    'outputs': [
      for (var i = 0; i < outputs.length; i++)
        _outputJson(outputs[i], outputSeed, firstNullifier, i),
    ],
    'outputTreeId': hex(outputTreeId),
    'externalDataHash': hex(externalDataHash),
    'privateTxHash': hex(privateTxHash),
    'blindingSeed': hex(blindingSeed),
    'publicAssets': hexes(publicAssets),
    'publicAmounts': hexes(publicAmounts),
    'ringProgramId': hex(ringProgramId),
    'signerPkHashes': hexes(signerPublicKeyHashes),
    'inputFlags': hex(inputFlags),
    'publishedOutputOwnerPkHashes': hexes(
      publishedOutputOwnerPublicKeyHashes,
    ),
    'cacheTreeId': hex(cacheTreeId),
    'cacheReadHashChain': hex(cacheReadHashChain),
    'cacheReadHashes': hexes(cacheReadHashes),
    'cacheIsCached': hexes(cacheIsCached),
    'cacheReadIndex': hexes(cacheReadIndex),
  };
}

Map<String, Object?> _inputJson(WitnessInput input) {
  final key = NullifierKey.fromSecret(input.nullifierSecret);
  final hash = input.note.commitment(input.treeId);
  final body = <String, Object?>{
    'utxo': input.note.toJson(),
    'isDummy': fieldHex(fieldU32(input.isDummy ? 1 : 0)),
    'treeSlot': fieldHex(input.treeSlot),
    'nullifier': fieldHex(key.nullifier(hash, input.note.blinding)),
    'ownerPkHash': fieldHex(input.ownerPublicKeyHash),
    'nullifierSecret': fieldHex(rightAlign(input.nullifierSecret)),
  };
  key.destroy();
  if (input.statePathElements.isNotEmpty && input.statePathIndex != null) {
    body['statePathElements'] = input.statePathElements.map(fieldHex).toList();
    body['statePathIndex'] = fieldHex(input.statePathIndex!);
  }
  if (input.nullifierLowValue != null &&
      input.nullifierNextValue != null &&
      input.nullifierLowPathIndex != null) {
    body['nullifierLowValue'] = fieldHex(input.nullifierLowValue!);
    body['nullifierNextValue'] = fieldHex(input.nullifierNextValue!);
    body['nullifierLowPathElements'] = input.nullifierLowPathElements
        .map(fieldHex)
        .toList();
    body['nullifierLowPathIndex'] = fieldHex(input.nullifierLowPathIndex!);
  }
  return body;
}

Map<String, Object?> _outputJson(
  WitnessOutput output,
  Uint8List outputSeed,
  Uint8List firstNullifier,
  int index,
) {
  final blinding = transactOutputBlinding(firstNullifier, outputSeed, index);
  final note = CircuitNote(
    domain: output.note.domain,
    owner: output.note.owner,
    asset: output.note.asset,
    amount: output.note.amount,
    blinding: blinding,
    dataHash: output.note.dataHash,
    ringDataHash: output.note.ringDataHash,
    ringProgramId: output.note.ringProgramId,
  );
  return {
    'utxo': note.toJson(),
    'isDummy': fieldHex(fieldU32(output.isDummy ? 1 : 0)),
    'hash': fieldHex(note.commitment(output.treeId)),
    'ownerPkHash': fieldHex(output.ownerPublicKeyHash),
    'nullifierPk': fieldHex(output.nullifierPublicKey),
  };
}

/// Body of `POST /prove/{circuit}/indexed`.
///
/// `indexedRequestEnvelope` in
/// `sdk-libs/ts/src/client/prover/indexed.ts`. [prepared] is the witness
/// [confidentialTransferWitness] returns. Commitments and nullifiers in
/// [lookups] are base58, which is how that function encodes them.
Map<String, Object?> indexedProofRequest({
  required Map<String, Object?> prepared,
  required List<({String tree, int id})> trees,
  required List<({int treeSlot, String? commitment, String? nullifier})>
  lookups,
  required List<Uint8List> publicInputs,
  BigInt? minContextSlot,
}) {
  if (minContextSlot != null && minContextSlot.bitLength > 53) {
    throw PrivacyRingsException(
      'minContextSlot does not fit in a JSON number',
      code: 'integer_range',
    );
  }
  return {
    'circuitType': prepared['circuitType'],
    'prepared': prepared,
    'trees': [
      for (final tree in trees) {'tree': tree.tree, 'id': tree.id},
    ],
    'inputs': [
      for (final lookup in lookups)
        {
          'treeSlot': lookup.treeSlot,
          'commitment': lookup.commitment,
          'nullifier': lookup.nullifier,
        },
    ],
    'publicInputs': [for (final input in publicInputs) fieldHex(input)],
    if (minContextSlot != null) 'minContextSlot': minContextSlot.toInt(),
  };
}
