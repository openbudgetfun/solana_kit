import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_privacy_rings/src/codec/output.dart';
import 'package:solana_kit_privacy_rings/src/constants.dart';
import 'package:solana_kit_privacy_rings/src/exception.dart';
import 'package:solana_kit_privacy_rings/src/keys/viewing_key.dart';
import 'package:solana_kit_privacy_rings/src/rpc/types.dart';

/// One note recovered from the indexer.
class PrivateNote {
  /// Creates a recovered note.
  const PrivateNote({
    required this.amount,
    required this.mint,
    required this.signature,
    this.assetId,
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

/// Notes opened from indexer history, plus how many slots were left closed.
class PrivateBalanceReport {
  /// Creates a report.
  const PrivateBalanceReport({
    required this.notes,
    required this.balances,
    required this.skipped,
  });

  /// Opened notes. Spent notes are not subtracted: the indexer history
  /// this report reads does not say which nullifier spent which note.
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
Future<PrivateBalanceReport> readConfidentialNotes({
  required ViewingKey viewingKey,
  required List<ShieldedTransaction> transactions,
  Map<BigInt, Address> mints = const {},
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
        txViewingPk: viewing,
        salt: salt,
        slotIndex: index,
        signature: transaction.txSignature,
        mints: mints,
      );
      if (note == null) {
        skipped++;
      } else {
        notes.add(note);
      }
    }
  }
  return PrivateBalanceReport(
    notes: notes,
    balances: _balances(notes),
    skipped: skipped,
  );
}

/// Reads proofless deposit matches.
///
/// A match that carries a transaction viewing key or a salt is an
/// encrypted output. Its cipher slot index is not on this record, so it
/// is skipped; open those through [readConfidentialNotes].
Future<PrivateBalanceReport> readProoflessDeposits(
  List<EncryptedUtxoMatch> matches,
) async {
  final notes = <PrivateNote>[];
  var skipped = 0;
  for (final match in matches) {
    if (match.txViewingPk != null || match.salt != null) {
      skipped++;
      continue;
    }
    final note = _prooflessNote(match);
    if (note == null) {
      skipped++;
    } else {
      notes.add(note);
    }
  }
  return PrivateBalanceReport(
    notes: notes,
    balances: _balances(notes),
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
  required List<int> txViewingPk,
  required List<int> salt,
  required int slotIndex,
  required String signature,
  required Map<BigInt, Address> mints,
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
  final mint = decoded.knownMint ?? mints[decoded.assetId];
  return PrivateNote(
    amount: decoded.amount,
    mint: mint,
    assetId: decoded.assetId,
    signature: signature,
  );
}

PrivateNote? _prooflessNote(EncryptedUtxoMatch match) {
  final frame = readOutputFrame(match.outputSlot.payload);
  if (frame.encoding != plaintextEncoding || frame.scheme != prooflessScheme) {
    return null;
  }
  final decoded = decodeProoflessPlaintext(frame.body);
  return PrivateNote(
    amount: decoded.amount,
    mint: decoded.asset,
    signature: match.txSignature,
  );
}

List<PrivateBalance> _balances(List<PrivateNote> notes) {
  final grouped = <String, PrivateBalance>{};
  for (final note in notes) {
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
