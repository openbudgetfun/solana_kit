import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_privacy_rings/src/bytes.dart';
import 'package:solana_kit_privacy_rings/src/constants.dart';
import 'package:solana_kit_privacy_rings/src/exception.dart';

/// One cleartext record inside a confidential note.
class OutputDataRecord {
  /// Creates a record.
  OutputDataRecord({required this.kind, required List<int> bytes})
    : bytes = Uint8List.fromList(bytes);

  /// `ringData`, `utxoData`, or `memo`.
  final String kind;

  /// Record bytes.
  final Uint8List bytes;
}

/// Decrypted confidential output.
///
/// Layout: `encodeConfidential` in
/// `sdk-libs/ts/src/transaction/serialization/codecs.ts`.
class ConfidentialPlaintext {
  /// Creates a decrypted note.
  ConfidentialPlaintext({
    required this.assetId,
    required this.amount,
    required List<int> blinding,
    required this.records,
    this.ringProgramId,
  }) : blinding = copyBytes(blinding, 32, 'blinding');

  /// Protocol asset id. [solAssetId] is native SOL.
  final BigInt assetId;

  /// Amount in base units.
  final BigInt amount;

  /// Note blinding.
  final Uint8List blinding;

  /// Ring program, when the note carries ring data.
  final Address? ringProgramId;

  /// Application records committed with the note.
  final List<OutputDataRecord> records;

  /// Mint address when it is known without a registry.
  ///
  /// Native SOL is [solMint]. Other asset ids need the on-chain asset
  /// registry, which this value does not invent.
  Address? get knownMint => assetId == solAssetId ? solMint : null;
}

/// A proofless deposit output. The amount is in the clear.
class ProoflessPlaintext {
  /// Creates a proofless output.
  ProoflessPlaintext({
    required List<int> owner,
    required List<int> blinding,
    required this.asset,
    required this.amount,
  }) : owner = copyBytes(owner, 32, 'owner'),
       blinding = copyBytes(blinding, 32, 'blinding');

  /// Recipient owner hash.
  final Uint8List owner;

  /// Deposit blinding.
  final Uint8List blinding;

  /// Asset mint. Native SOL uses [solMint].
  final Address asset;

  /// Amount in base units.
  final BigInt amount;
}

/// A parsed output frame: encoding tag, scheme byte, and body.
class OutputFrame {
  /// Creates a frame.
  const OutputFrame({
    required this.encoding,
    required this.scheme,
    required this.body,
  });

  /// `0` plaintext, `1` encrypted, `2` verifiable.
  final int encoding;

  /// `EncryptedScheme` byte.
  final int scheme;

  /// Bytes after the scheme byte.
  final Uint8List body;
}

/// Reads the output-data frame around a slot payload.
///
/// `readOutputFrame` in
/// `sdk-libs/ts/src/transaction/serialization/codecs.ts`.
OutputFrame readOutputFrame(Uint8List bytes) {
  final reader = ByteReader(bytes);
  final encoding = reader.u8('encoding');
  if (encoding > 2) {
    throw PrivacyRingsException(
      'unknown output encoding $encoding',
      code: 'invalid_discriminator',
    );
  }
  final blob = reader.bytes(reader.u32('blob.length'), 'blob');
  reader.done();
  if (blob.isEmpty) {
    throw PrivacyRingsException(
      'output frame is missing its scheme byte',
      code: 'truncated',
    );
  }
  return OutputFrame(
    encoding: encoding,
    scheme: blob[0],
    body: Uint8List.sublistView(blob, 1),
  );
}

/// Decodes a confidential plaintext.
ConfidentialPlaintext decodeConfidentialPlaintext(Uint8List bytes) {
  final reader = ByteReader(bytes);
  final assetId = reader.u64('assetId');
  final amount = reader.u64('amount');
  final blinding = reader.bytes(32, 'blinding');
  final ring = reader.option(() => reader.bytes(32, 'ringProgramId'));
  final count = reader.u8('records');
  final records = <OutputDataRecord>[];
  for (var i = 0; i < count; i++) {
    final tag = reader.u8('record.tag');
    final kind = switch (tag) {
      1 => 'ringData',
      2 => 'utxoData',
      3 => 'memo',
      _ => throw PrivacyRingsException(
        'unknown data record tag $tag',
        code: 'invalid_discriminator',
      ),
    };
    records.add(
      OutputDataRecord(
        kind: kind,
        bytes: reader.bytes(reader.u16('record.length'), 'record'),
      ),
    );
  }
  reader.done();
  return ConfidentialPlaintext(
    assetId: assetId,
    amount: amount,
    blinding: blinding,
    ringProgramId: ring == null ? null : getAddressDecoder().decode(ring),
    records: records,
  );
}

/// Decodes a proofless deposit body far enough to recover the amount.
///
/// Optional trailing fields are consumed so a truncated body throws, and
/// leftover bytes throw.
ProoflessPlaintext decodeProoflessPlaintext(Uint8List bytes) {
  final reader = ByteReader(bytes);
  final owner = reader.bytes(32, 'owner');
  final blinding = reader.bytes(32, 'blinding');
  final asset = getAddressDecoder().decode(reader.bytes(32, 'asset'));
  final amount = reader.u64('amount');
  reader.option(() => reader.bytes(32, 'dataHash'));
  Uint8List? optionalBytes() =>
      reader.option(() => reader.bytes(reader.u32('bytes.length'), 'bytes'));
  optionalBytes();
  reader.option(() => reader.bytes(32, 'ringProgramId'));
  reader.option(() => reader.bytes(32, 'ringDataHash'));
  optionalBytes();
  optionalBytes();
  reader.done();
  return ProoflessPlaintext(
    owner: owner,
    blinding: blinding,
    asset: asset,
    amount: amount,
  );
}

/// Splits the 33-byte tagged X25519 key off the front of a confidential body.
({Uint8List publicKey, Uint8List ciphertext}) splitEmbeddedViewingKey(
  Uint8List body,
) {
  if (body.length < 33) {
    throw PrivacyRingsException(
      'confidential body is shorter than a viewing key',
      code: 'truncated',
    );
  }
  return (
    publicKey: Uint8List.sublistView(body, 0, 33),
    ciphertext: Uint8List.sublistView(body, 33),
  );
}
