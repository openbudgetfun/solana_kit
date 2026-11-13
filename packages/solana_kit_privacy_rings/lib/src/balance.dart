import 'dart:async';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_privacy_rings/src/codec/output.dart';
import 'package:solana_kit_privacy_rings/src/constants.dart';
import 'package:solana_kit_privacy_rings/src/exception.dart';
import 'package:solana_kit_privacy_rings/src/keys/viewing_key.dart';
import 'package:solana_kit_privacy_rings/src/rpc/types.dart';

/// Checks a decrypted note against a trusted commitment and recipient identity.
///
/// AES-CTR has no authentication. Return true only after reconstructing the
/// Poseidon commitment with the expected owner, mint, domain, and record hashes
/// and checking it against a commitment from a trusted source.
typedef ConfidentialNoteVerifier = FutureOr<bool> Function(
  ConfidentialPlaintext note,
  OutputContext context,
);

/// One note recovered from the indexer.
class PrivateNote {
  /// Creates a recovered note.
  const PrivateNote({
    required this.amount,
    required this.mint,
    required this.signature,
    this.assetId,
    this.treeId,
    this.leafIndex,
    this.blinding,
    this.commitment,
  });

  /// Amount in base units.
  final BigInt amount;

  /// Mint, when this package can name one.
  ///
  /// Native SOL is [solMint]. A confidential note for another asset id
  /// is named only when the caller passed that id in the mint registry.
  final Address? mint;

  /// Protocol asset id. Present for a confidential note.
  final BigInt? assetId;

  /// Transaction that created the note.
  final String signature;

  /// Tree id, when the indexer named the leaf.
  final int? treeId;

  /// Leaf index in [treeId].
  final BigInt? leafIndex;

  /// Note blinding, when the plaintext carried one.
  final Uint8List? blinding;

  /// Output commitment, when the indexer named one.
  final Uint8List? commitment;
}

/// Sum of [notes] that share a mint or, when the mint is unknown, an
/// asset id.
class PrivateBalance {
  /// Creates a balance.
  const PrivateBalance({
    required this.amount,
    required this.notes,
    this.mint,
    this.assetId,
  });

  /// Total base units.
  final BigInt amount;

  /// Notes included in [amount].
  final int notes;

  /// Mint, when every included note named the same one.
  final Address? mint;

  /// Asset id, when the notes are confidential.
  final BigInt? assetId;
}

/// A leaf the caller already knows is spent.
class SpentLeaf {
  /// Creates a spent-leaf key.
  const SpentLeaf(this.treeId, this.leafIndex);

  /// Tree id.
  final int treeId;

  /// Leaf index.
  final BigInt leafIndex;

  @override
  bool operator ==(Object other) =>
      other is SpentLeaf &&
      other.treeId == treeId &&
      other.leafIndex == leafIndex;

  @override
  int get hashCode => Object.hash(treeId, leafIndex);
}

/// Notes opened from indexer history, plus how many slots were left closed.
class PrivateBalanceReport {
  /// Creates a report.
  const PrivateBalanceReport({
    required this.notes,
    required this.balances,
    required this.skipped,
  });

  /// Opened notes. A leaf in [notes] is counted once by [balances].
  final List<PrivateNote> notes;

  /// [notes] grouped by mint, or by asset id when the mint is unknown.
  final List<PrivateBalance> balances;

  /// Slots that were not confidential or proofless notes for this key.
  ///
  /// A ciphertext that does not decode under the viewing key is counted
  /// here. A payload that is not a complete output frame is reported as
  /// an exception instead, because that is a malformed indexer record
  /// rather than someone else's note.
  final int skipped;
}

/// Opens confidential outputs in [transactions] with [viewingKey].
///
/// The cipher binds the output's position in `outputSlots`, not the
/// Merkle leaf index. Proofless deposits are ignored here;
/// use [readProoflessDeposits] for those. A transaction flagged
/// `proofless` is skipped so a deposit is not counted twice when the
/// caller also reads the encrypted-UTXO endpoint, matching the split in
/// `sdk-libs/ts/src/wallet/sync.ts`.
///
/// Without [verifyNote], this is raw decryption, not authentication: verify the
/// Poseidon commitment before treating the result as a balance. Spent leaves
/// are excluded from both notes and totals.
Future<PrivateBalanceReport> readConfidentialNotes({
  required ViewingKey viewingKey,
  required List<ShieldedTransaction> transactions,
  Map<BigInt, Address> mints = const {},
  ConfidentialNoteVerifier? verifyNote,
  Set<SpentLeaf> spent = const {},
}) async {
  final notes = <PrivateNote>[];
  var skipped = 0;
  for (final transaction in transactions) {
    if (transaction.proofless) {
      skipped += transaction.outputSlots.length;
      continue;
    }
    final viewing = transaction.txViewingPk;
    final salt = transaction.salt;
    if (viewing == null || salt == null) {
      skipped += transaction.outputSlots.length;
      continue;
    }
    for (final (index, slot) in transaction.outputSlots.indexed) {
      final note = await _confidentialNote(
        viewingKey: viewingKey,
        payload: slot.payload,
        outputContext: slot.outputContext,
        txViewingPk: viewing,
        salt: salt,
        slotIndex: index,
        signature: transaction.txSignature,
        mints: mints,
        verifyNote: verifyNote,
      );
      if (note == null) {
        skipped++;
      } else if (!_isSpent(note, spent)) {
        notes.add(note);
      }
    }
  }
  return PrivateBalanceReport(
    notes: notes,
    balances: _balances(notes, spent: spent),
    skipped: skipped,
  );
}

/// Reads proofless deposit matches.
///
/// A match that carries a transaction viewing key or a salt is an
/// encrypted output. Its cipher slot index is not on this record, so it
/// is skipped; open those through [readConfidentialNotes]. With [expectedOwner],
/// deposits for other owners are excluded. Tags alone do not establish ownership.
/// Without it, callers must verify ownership before using the amounts.
Future<PrivateBalanceReport> readProoflessDeposits(
  List<EncryptedUtxoMatch> matches, {
  Uint8List? expectedOwner,
  Set<SpentLeaf> spent = const {},
}) async {
  final notes = <PrivateNote>[];
  var skipped = 0;
  if (expectedOwner != null && expectedOwner.length != 32) {
    throw PrivacyRingsException(
      'owner must be 32 bytes',
      code: 'invalid_length',
    );
  }
  for (final match in matches) {
    if (match.txViewingPk != null || match.salt != null) {
      skipped++;
      continue;
    }
    final note = _prooflessNote(match, expectedOwner);
    if (note == null) {
      skipped++;
    } else if (!_isSpent(note, spent)) {
      notes.add(note);
    }
  }
  return PrivateBalanceReport(
    notes: notes,
    balances: _balances(notes, spent: spent),
    skipped: skipped,
  );
}

/// Adds the notes from [other] onto [base].
PrivateBalanceReport combineBalanceReports(
  PrivateBalanceReport base,
  PrivateBalanceReport other,
) {
  final notes = [...base.notes, ...other.notes];
  return PrivateBalanceReport(
    notes: notes,
    balances: _balances(notes),
    skipped: base.skipped + other.skipped,
  );
}

Future<PrivateNote?> _confidentialNote({
  required ViewingKey viewingKey,
  required Uint8List payload,
  required OutputContext outputContext,
  required List<int> txViewingPk,
  required List<int> salt,
  required int slotIndex,
  required String signature,
  required Map<BigInt, Address> mints,
  required ConfidentialNoteVerifier? verifyNote,
}) async {
  final frame = readOutputFrame(payload);
  final confidential =
      frame.scheme == confidentialScheme ||
      frame.scheme == ringConfidentialScheme;
  if (frame.encoding != encryptedEncoding || !confidential) return null;
  final split = splitEmbeddedViewingKey(frame.body);
  final plaintext = await viewingKey.decryptSlot(
    txViewingPublicKey: txViewingPk,
    ciphertext: split.ciphertext,
    salt: salt,
    slotIndex: slotIndex,
  );
  ConfidentialPlaintext decoded;
  try {
    decoded = decodeConfidentialPlaintext(plaintext);
  } on PrivacyRingsException {
    return null;
  }
  if (verifyNote != null && !await verifyNote(decoded, outputContext)) {
    return null;
  }
  final mint = decoded.knownMint ?? mints[decoded.assetId];
  return PrivateNote(
    amount: decoded.amount,
    mint: mint,
    assetId: decoded.assetId,
    signature: signature,
    treeId: outputContext.treeId,
    leafIndex: outputContext.leafIndex,
    blinding: decoded.blinding,
    commitment: getBase58Encoder().encode(outputContext.hash),
  );
}

PrivateNote? _prooflessNote(
  EncryptedUtxoMatch match,
  Uint8List? expectedOwner,
) {
  final frame = readOutputFrame(match.outputSlot.payload);
  if (frame.encoding != plaintextEncoding || frame.scheme != prooflessScheme) {
    return null;
  }
  final decoded = decodeProoflessPlaintext(frame.body);
  if (expectedOwner != null && !_bytesEqual(decoded.owner, expectedOwner)) {
    return null;
  }
  return PrivateNote(
    amount: decoded.amount,
    mint: decoded.asset,
    signature: match.txSignature,
    treeId: match.outputSlot.outputContext.treeId,
    leafIndex: match.outputSlot.outputContext.leafIndex,
    blinding: decoded.blinding,
    commitment: getBase58Encoder().encode(match.outputSlot.outputContext.hash),
  );
}

List<PrivateBalance> _balances(
  List<PrivateNote> notes, {
  Set<SpentLeaf> spent = const {},
}) {
  final seen = <String, PrivateNote>{};
  final kept = <PrivateNote>[];
  for (final note in notes) {
    final tree = note.treeId;
    final leaf = note.leafIndex;
    if (tree != null && leaf != null) {
      if (spent.contains(SpentLeaf(tree, leaf))) continue;
      final key = '$tree:$leaf';
      final existing = seen[key];
      if (existing != null) {
        if (!_sameNote(existing, note)) {
          throw PrivacyRingsException(
            'leaf $tree:$leaf appears twice with different contents',
            code: 'conflicting_leaf',
          );
        }
        continue;
      }
      seen[key] = note;
    }
    kept.add(note);
  }
  final grouped = <String, PrivateBalance>{};
  for (final note in kept) {
    final key = note.mint?.toString() ?? 'asset:${note.assetId}';
    final existing = grouped[key];
    grouped[key] = PrivateBalance(
      amount: (existing?.amount ?? BigInt.zero) + note.amount,
      notes: (existing?.notes ?? 0) + 1,
      mint: note.mint,
      assetId: note.assetId,
    );
  }
  return grouped.values.toList();
}

/// Drops notes whose derived nullifier is in [spent].
///
/// [nullifierOf] maps a leaf to the nullifier the caller derived. A note
/// with no entry is kept: this function does not guess which nullifier
/// spent it. Matches `subtract_nullified` in the Rust client.
List<PrivateNote> subtractNullifiedNotes(
  List<PrivateNote> notes,
  Map<SpentLeaf, List<int>> nullifierOf,
  Iterable<List<int>> spent,
) {
  return [
    for (final note in notes)
      if (_keepNote(note, nullifierOf, spent, dropWhenNamed: true)) note,
  ];
}

/// Keeps notes whose nullifier has a non-inclusion proof.
///
/// A note whose nullifier is known and absent from [unspent] is removed.
/// A note with no derived nullifier is kept, because the proof cannot
/// name it. Matches `retain_non_inclusion` in the Rust client.
List<PrivateNote> retainNonInclusion(
  List<PrivateNote> notes,
  Map<SpentLeaf, List<int>> nullifierOf,
  Iterable<List<int>> unspent,
) {
  return [
    for (final note in notes)
      if (_keepNote(note, nullifierOf, unspent, dropWhenNamed: false)) note,
  ];
}

bool _keepNote(
  PrivateNote note,
  Map<SpentLeaf, List<int>> nullifierOf,
  Iterable<List<int>> set, {
  required bool dropWhenNamed,
}) {
  final tree = note.treeId;
  final leaf = note.leafIndex;
  if (tree == null || leaf == null) return true;
  final derived = nullifierOf[SpentLeaf(tree, leaf)];
  if (derived == null) return true;
  final named = set.any(
    (item) =>
        _bytesEqual(Uint8List.fromList(item), Uint8List.fromList(derived)),
  );
  return dropWhenNamed ? !named : named;
}

bool _sameNote(PrivateNote left, PrivateNote right) {
  return left.amount == right.amount &&
      left.mint == right.mint &&
      left.assetId == right.assetId &&
      _bytesEqual(left.blinding, right.blinding) &&
      _bytesEqual(left.commitment, right.commitment);
}

bool _bytesEqual(Uint8List? left, Uint8List? right) {
  if (identical(left, right)) return true;
  if (left == null || right == null || left.length != right.length) {
    return false;
  }
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }
  return true;
}

bool _isSpent(PrivateNote note, Set<SpentLeaf> spent) =>
    note.treeId != null &&
    note.leafIndex != null &&
    spent.contains(SpentLeaf(note.treeId!, note.leafIndex!));
