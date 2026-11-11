import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

import 'package:solana_kit_privacy_rings/src/exception.dart';

/// Inclusive slot bounds on a history query.
class SlotFilter {
  /// Creates a slot filter. At least one bound is required.
  const SlotFilter({this.gt, this.gte, this.lt, this.lte});

  /// Slot greater than this value.
  final BigInt? gt;

  /// Slot greater than or equal to this value.
  final BigInt? gte;

  /// Slot less than this value.
  final BigInt? lt;

  /// Slot less than or equal to this value.
  final BigInt? lte;

  /// JSON object, omitting unset bounds.
  Map<String, Object?> toJson() {
    return {
      if (gt != null) 'gt': _jsonU64(gt!, 'gt'),
      if (gte != null) 'gte': _jsonU64(gte!, 'gte'),
      if (lt != null) 'lt': _jsonU64(lt!, 'lt'),
      if (lte != null) 'lte': _jsonU64(lte!, 'lte'),
    };
  }
}

/// Filters shared by the history methods.
class HistoryFilters {
  /// Creates history filters.
  const HistoryFilters({this.slot});

  /// Slot window.
  final SlotFilter? slot;

  /// JSON object.
  Map<String, Object?> toJson() => {
    if (slot != null) 'slot': slot!.toJson(),
  };
}

/// Page controls shared by the tag and nullifier queries.
class PageRequest {
  /// Creates page controls.
  const PageRequest({
    this.paginationToken,
    this.limit,
    this.filters,
    this.minContextSlot,
  });

  /// Token from the previous page.
  final String? paginationToken;

  /// Page size, from 1 to 1000.
  final int? limit;

  /// Optional slot filter.
  final HistoryFilters? filters;

  /// Do not answer from a context older than this slot.
  final BigInt? minContextSlot;
}

/// Indexer context returned with every page.
class IndexerContext {
  /// Creates an indexer context.
  const IndexerContext({required this.blockTime, required this.slot});

  /// Block time, as a unix timestamp.
  final BigInt blockTime;

  /// Highest slot the indexer has persisted.
  final BigInt slot;
}

/// Where an output was appended.
class OutputContext {
  /// Creates an output context.
  const OutputContext({
    required this.treeId,
    required this.hash,
    required this.tree,
    required this.leafIndex,
  });

  /// Tree id.
  final int treeId;

  /// Output commitment, base58.
  final String hash;

  /// Tree account.
  final Address tree;

  /// Leaf index in that tree.
  final BigInt leafIndex;
}

/// One encrypted or proofless output slot.
class OutputSlot {
  /// Creates an output slot.
  const OutputSlot({
    required this.viewTag,
    required this.outputContext,
    required this.payload,
  });

  /// View tag, base58.
  final String viewTag;

  /// Merkle position.
  final OutputContext outputContext;

  /// Output-data frame bytes.
  final Uint8List payload;
}

/// One match from `getEncryptedUtxosByTags`.
class EncryptedUtxoMatch {
  /// Creates a match.
  const EncryptedUtxoMatch({
    required this.slot,
    required this.txSignature,
    required this.outputSlot,
    this.txViewingPk,
    this.salt,
  });

  /// Slot of the transaction.
  final BigInt slot;

  /// Transaction signature.
  final String txSignature;

  /// The output.
  final OutputSlot outputSlot;

  /// Tagged transaction viewing key, when the output is encrypted.
  final Uint8List? txViewingPk;

  /// Transaction salt, when the output is encrypted.
  final Uint8List? salt;
}

/// A transaction header plus the entries the method returns.
class TransactionPageEntry<T> {
  /// Creates a page entry.
  const TransactionPageEntry({
    required this.slot,
    required this.signature,
    required this.entries,
  });

  /// Slot.
  final BigInt slot;

  /// Signature.
  final String signature;

  /// Outputs or events.
  final List<T> entries;
}

/// One indexed shielded transaction.
class ShieldedTransaction {
  /// Creates a shielded transaction.
  const ShieldedTransaction({
    required this.slot,
    required this.txSignature,
    required this.outputSlots,
    required this.messages,
    required this.nullifiers,
    required this.proofless,
    this.eventIndex,
    this.txViewingPk,
    this.salt,
    this.ringConfig,
    this.ringProgramId,
  });

  /// Slot.
  final BigInt slot;

  /// Signature.
  final String txSignature;

  /// Event index, when the method reports one.
  final int? eventIndex;

  /// Tagged transaction viewing key.
  final Uint8List? txViewingPk;

  /// Transaction salt.
  final Uint8List? salt;

  /// Output slots, in cipher-slot order.
  final List<OutputSlot> outputSlots;

  /// Unbound messages. Each payload is still base64-decoded.
  final List<({String viewTag, Uint8List payload})> messages;

  /// Nullifiers, base58.
  final List<String> nullifiers;

  /// True when the transaction is a proofless deposit.
  final bool proofless;

  /// Ring config account, when a ring authorized the transaction.
  final Address? ringConfig;

  /// Ring program, when the indexer resolved it.
  final Address? ringProgramId;
}

/// A page of indexer results.
class IndexerPage<T> {
  /// Creates a page.
  const IndexerPage({
    required this.context,
    required this.data,
    required this.paginationToken,
    this.outputTreeId,
  });

  /// Read context.
  final IndexerContext context;

  /// Page entries.
  final List<T> data;

  /// Next page token, or null when this is the last page.
  final String? paginationToken;

  /// Output tree id, when the page reports one.
  final int? outputTreeId;
}

/// Merkle inclusion proof.
class MerkleProof {
  /// Creates a proof.
  const MerkleProof({
    required this.leaf,
    required this.treeType,
    required this.tree,
    required this.path,
    required this.leafIndex,
    required this.root,
    required this.rootSeq,
    required this.rootIndex,
  });

  /// Leaf hash, base58.
  final String leaf;

  /// Tree type tag.
  final int treeType;

  /// Tree account.
  final Address tree;

  /// Sibling hashes, base58.
  final List<String> path;

  /// Leaf index.
  final BigInt leafIndex;

  /// Root hash, base58.
  final String root;

  /// Root sequence.
  final BigInt rootSeq;

  /// Root history position.
  final int rootIndex;
}

/// Nullifier non-inclusion proof.
class NonInclusionProof {
  /// Creates a non-inclusion proof.
  const NonInclusionProof({
    required this.leaf,
    required this.treeType,
    required this.tree,
    required this.path,
    required this.lowElement,
    required this.lowElementIndex,
    required this.highElement,
    required this.highElementIndex,
    required this.root,
    required this.rootSeq,
    required this.rootIndex,
  });

  /// Queried leaf, base58.
  final String leaf;

  /// Tree type tag.
  final int treeType;

  /// Tree account.
  final Address tree;

  /// Sibling hashes, base58.
  final List<String> path;

  /// Low neighbor, base58.
  final String lowElement;

  /// Low neighbor index.
  final BigInt lowElementIndex;

  /// High neighbor, base58.
  final String highElement;

  /// High neighbor index.
  final BigInt highElementIndex;

  /// Root hash, base58.
  final String root;

  /// Root sequence.
  final BigInt rootSeq;

  /// Root history position.
  final int rootIndex;
}

/// A public user-registry record.
class UserRecord {
  /// Creates a user record.
  const UserRecord({
    required this.owner,
    required this.nullifierPubkey,
    required this.viewingPubkey,
    required this.mergeEncryption,
  });

  /// Solana owner.
  final Address owner;

  /// Wallet-wide nullifier public key, base58.
  final String nullifierPubkey;

  /// Tagged X25519 viewing public key.
  final Uint8List viewingPubkey;

  /// `0` disabled, `1` Poseidon-CTR v1.
  final int mergeEncryption;
}

/// JSON controls shared by the paged indexer methods.
Map<String, Object?> pageControls(PageRequest request) {
  if (request.limit != null && (request.limit! < 1 || request.limit! > 1000)) {
    throw PrivacyRingsException(
      'limit must be from 1 to 1000',
      code: 'invalid_limit',
    );
  }
  return {
    if (request.paginationToken != null)
      'paginationToken': request.paginationToken,
    if (request.limit != null) 'limit': request.limit,
    if (request.filters != null) 'filters': request.filters!.toJson(),
    if (request.minContextSlot != null)
      'minContextSlot': _jsonU64(request.minContextSlot!, 'minContextSlot'),
  };
}

Object _jsonU64(BigInt value, String name) {
  if (value.isNegative || value.bitLength > 64) {
    throw PrivacyRingsException(
      '$name is outside 0..2^64-1',
      code: 'integer_range',
    );
  }
  final maxSafe = BigInt.parse('9007199254740991');
  if (value <= maxSafe) return value.toInt();
  return value.toString();
}

Map<String, Object?> _map(Object? value, String path) {
  if (value is! Map) {
    throw PrivacyRingsException(
      '$path is not an object',
      code: 'invalid_response',
    );
  }
  return value.map((key, item) => MapEntry(key.toString(), item));
}

List<Object?> _list(Object? value, String path) {
  if (value is! List) {
    throw PrivacyRingsException(
      '$path is not an array',
      code: 'invalid_response',
    );
  }
  return value;
}

BigInt _u64(Object? value, String path) {
  if (value is int) {
    if (value < 0) {
      throw PrivacyRingsException(
        '$path is negative',
        code: 'invalid_response',
      );
    }
    return BigInt.from(value);
  }
  if (value is String && RegExp(r'^[0-9]+$').hasMatch(value)) {
    final parsed = BigInt.parse(value);
    if (parsed.bitLength > 64) {
      throw PrivacyRingsException(
        '$path does not fit in a u64',
        code: 'invalid_response',
      );
    }
    return parsed;
  }
  throw PrivacyRingsException(
    '$path is not a u64',
    code: 'invalid_response',
  );
}

int _int(Object? value, String path) {
  final parsed = _u64(value, path);
  if (parsed > BigInt.from(0x7fffffff)) {
    throw PrivacyRingsException(
      '$path does not fit in a 32-bit integer',
      code: 'invalid_response',
    );
  }
  return parsed.toInt();
}

String _string(Object? value, String path) {
  if (value is! String || value.isEmpty) {
    throw PrivacyRingsException(
      '$path is not a string',
      code: 'invalid_response',
    );
  }
  return value;
}

Address _address(Object? value, String path) {
  final text = _string(value, path);
  try {
    return address(text);
  } on Object {
    throw PrivacyRingsException(
      '$path is not a Solana address',
      code: 'invalid_response',
    );
  }
}

String _hash(Object? value, String path) {
  final text = _string(value, path);
  late List<int> bytes;
  try {
    bytes = getBase58Encoder().encode(text);
  } on Object {
    throw PrivacyRingsException(
      '$path is not base58',
      code: 'invalid_response',
    );
  }
  if (bytes.length != 32) {
    throw PrivacyRingsException(
      '$path is not a 32-byte hash',
      code: 'invalid_response',
    );
  }
  return text;
}

String _signature(Object? value, String path) {
  final text = _string(value, path);
  late List<int> bytes;
  try {
    bytes = getBase58Encoder().encode(text);
  } on Object {
    throw PrivacyRingsException(
      '$path is not base58',
      code: 'invalid_response',
    );
  }
  if (bytes.length != 64) {
    throw PrivacyRingsException(
      '$path is not a 64-byte signature',
      code: 'invalid_response',
    );
  }
  return text;
}

Uint8List _base64(Object? value, String path) {
  final text = _string(value, path);
  try {
    return Uint8List.fromList(base64.decode(text));
  } on FormatException {
    throw PrivacyRingsException(
      '$path is not base64',
      code: 'invalid_response',
    );
  }
}

bool _bool(Object? value, String path) {
  if (value is! bool) {
    throw PrivacyRingsException(
      '$path is not a boolean',
      code: 'invalid_response',
    );
  }
  return value;
}

Uint8List _sized(Uint8List bytes, int length, String path) {
  if (bytes.length != length) {
    throw PrivacyRingsException(
      '$path is ${bytes.length} bytes; expected $length',
      code: 'invalid_response',
    );
  }
  return bytes;
}

Uint8List? _optionalBytes(Object? value, String path, int length) {
  if (value == null) return null;
  return _sized(_base64(value, path), length, path);
}

IndexerContext _context(Object? value) {
  final record = _map(value, 'context');
  return IndexerContext(
    blockTime: _u64(record['blockTime'], 'context.blockTime'),
    slot: _u64(record['slot'], 'context.slot'),
  );
}

OutputContext _outputContext(Object? value, String path) {
  final record = _map(value, path);
  return OutputContext(
    treeId: _int(record['treeId'], '$path.treeId'),
    hash: _hash(record['hash'], '$path.hash'),
    tree: _address(record['tree'], '$path.tree'),
    leafIndex: _u64(record['leafIndex'], '$path.leafIndex'),
  );
}

OutputSlot _outputSlot(Object? value, String path) {
  final record = _map(value, path);
  return OutputSlot(
    viewTag: _hash(record['viewTag'], '$path.viewTag'),
    outputContext: _outputContext(
      record['outputContext'],
      '$path.outputContext',
    ),
    payload: _base64(record['payload'], '$path.payload'),
  );
}

EncryptedUtxoMatch _encryptedUtxo(Object? value, String path) {
  final record = _map(value, path);
  return EncryptedUtxoMatch(
    slot: _u64(record['slot'], '$path.slot'),
    txSignature: _signature(record['txSignature'], '$path.txSignature'),
    outputSlot: _outputSlot(record['outputSlot'], '$path.outputSlot'),
    txViewingPk: _optionalBytes(record['txViewingPk'], '$path.txViewingPk', 33),
    salt: _optionalBytes(record['salt'], '$path.salt', 16),
  );
}

ShieldedTransaction _shieldedTransaction(Object? value, String path) {
  final record = _map(value, path);
  return ShieldedTransaction(
    slot: _u64(record['slot'], '$path.slot'),
    txSignature: _signature(record['txSignature'], '$path.txSignature'),
    eventIndex: record['eventIndex'] == null
        ? null
        : _int(record['eventIndex'], '$path.eventIndex'),
    txViewingPk: _optionalBytes(record['txViewingPk'], '$path.txViewingPk', 33),
    salt: _optionalBytes(record['salt'], '$path.salt', 16),
    outputSlots: [
      for (final (index, slot) in _list(
        record['outputSlots'],
        '$path.outputSlots',
      ).indexed)
        _outputSlot(slot, '$path.outputSlots[$index]'),
    ],
    messages: [
      for (final (index, message) in _list(
        record['messages'],
        '$path.messages',
      ).indexed)
        () {
          final item = _map(message, '$path.messages[$index]');
          return (
            viewTag: _hash(item['viewTag'], '$path.messages[$index].viewTag'),
            payload: _base64(item['payload'], '$path.messages[$index].payload'),
          );
        }(),
    ],
    nullifiers: [
      for (final (index, item) in _list(
        record['nullifiers'],
        '$path.nullifiers',
      ).indexed)
        _hash(item, '$path.nullifiers[$index]'),
    ],
    proofless: _bool(record['proofless'], '$path.proofless'),
    ringConfig: record['ringConfig'] == null
        ? null
        : _address(record['ringConfig'], '$path.ringConfig'),
    ringProgramId: record['ringProgramId'] == null
        ? null
        : _address(record['ringProgramId'], '$path.ringProgramId'),
  );
}

IndexerPage<TransactionPageEntry<T>> _page<T>(
  Object? value,
  String child,
  T Function(Object? value, String path) decode,
) {
  final record = _map(value, r'$');
  final context = _context(record['context']);
  final token = record['paginationToken'];
  if (token != null && (token is! String || token.isEmpty)) {
    throw PrivacyRingsException(
      'paginationToken is not a string',
      code: 'invalid_response',
    );
  }
  final data = <TransactionPageEntry<T>>[];
  for (final (index, item) in _list(record['data'], r'$.data').indexed) {
    final entry = _map(item, '\$.data[$index]');
    final entries = <T>[];
    for (final (childIndex, childValue) in _list(
      entry[child],
      '\$.data[$index].$child',
    ).indexed) {
      entries.add(decode(childValue, '\$.data[$index].$child[$childIndex]'));
    }
    data.add(
      TransactionPageEntry(
        slot: _u64(entry['slot'], '\$.data[$index].slot'),
        signature: _signature(entry['signature'], '\$.data[$index].signature'),
        entries: entries,
      ),
    );
  }
  return IndexerPage(
    context: context,
    data: data,
    paginationToken: token as String?,
    outputTreeId: record['outputTreeId'] == null
        ? null
        : _int(record['outputTreeId'], r'$.outputTreeId'),
  );
}

/// Decodes `getEncryptedUtxosByTags`.
IndexerPage<TransactionPageEntry<EncryptedUtxoMatch>> decodeEncryptedUtxos(
  Object? value,
) {
  return _page(value, 'outputs', _encryptedUtxo);
}

/// Decodes `getShieldedTransactionsByTags` and the nullifier variant.
IndexerPage<TransactionPageEntry<ShieldedTransaction>>
decodeShieldedTransactions(
  Object? value,
) {
  return _page(value, 'events', _shieldedTransaction);
}

/// Decodes `getShieldedTransactionsBySignature`.
({
  IndexerContext context,
  int? outputTreeId,
  List<({int eventIndex, ShieldedTransaction transaction})> transactions,
})
decodeShieldedTransactionsBySignature(Object? value) {
  final record = _map(value, r'$');
  final transactions = <({int eventIndex, ShieldedTransaction transaction})>[];
  for (final (index, item) in _list(
    record['transactions'],
    r'$.transactions',
  ).indexed) {
    final entry = _map(item, '\$.transactions[$index]');
    transactions.add((
      eventIndex: _int(
        entry['eventIndex'],
        '\$.transactions[$index].eventIndex',
      ),
      transaction: _shieldedTransaction(
        entry['transaction'],
        '\$.transactions[$index].transaction',
      ),
    ));
  }
  return (
    context: _context(record['context']),
    outputTreeId: record['outputTreeId'] == null
        ? null
        : _int(record['outputTreeId'], r'$.outputTreeId'),
    transactions: transactions,
  );
}

MerkleProof _merkleProof(Object? value, String path) {
  final record = _map(value, path);
  final merkle = _map(record['merkleContext'], '$path.merkleContext');
  return MerkleProof(
    leaf: _hash(record['leaf'], '$path.leaf'),
    treeType: _int(merkle['treeType'], '$path.merkleContext.treeType'),
    tree: _address(merkle['tree'], '$path.merkleContext.tree'),
    path: [
      for (final (index, item) in _list(record['path'], '$path.path').indexed)
        _hash(item, '$path.path[$index]'),
    ],
    leafIndex: _u64(record['leafIndex'], '$path.leafIndex'),
    root: _hash(record['root'], '$path.root'),
    rootSeq: _u64(record['rootSeq'], '$path.rootSeq'),
    rootIndex: _int(record['rootIndex'], '$path.rootIndex'),
  );
}

NonInclusionProof _nonInclusion(Object? value, String path) {
  final record = _map(value, path);
  final merkle = _map(record['merkleContext'], '$path.merkleContext');
  return NonInclusionProof(
    leaf: _hash(record['leaf'], '$path.leaf'),
    treeType: _int(merkle['treeType'], '$path.merkleContext.treeType'),
    tree: _address(merkle['tree'], '$path.merkleContext.tree'),
    path: [
      for (final (index, item) in _list(record['path'], '$path.path').indexed)
        _hash(item, '$path.path[$index]'),
    ],
    lowElement: _hash(record['lowElement'], '$path.lowElement'),
    lowElementIndex: _u64(record['lowElementIndex'], '$path.lowElementIndex'),
    highElement: _hash(record['highElement'], '$path.highElement'),
    highElementIndex: _u64(
      record['highElementIndex'],
      '$path.highElementIndex',
    ),
    root: _hash(record['root'], '$path.root'),
    rootSeq: _u64(record['rootSeq'], '$path.rootSeq'),
    rootIndex: _int(record['rootIndex'], '$path.rootIndex'),
  );
}

/// Decodes `getMerkleProofs`.
({IndexerContext context, List<MerkleProof> proofs}) decodeMerkleProofs(
  Object? value,
) {
  final record = _map(value, r'$');
  return (
    context: _context(record['context']),
    proofs: [
      for (final (index, item) in _list(record['proofs'], r'$.proofs').indexed)
        _merkleProof(item, '\$.proofs[$index]'),
    ],
  );
}

/// Decodes `getNonInclusionProofs`.
({IndexerContext context, List<NonInclusionProof> proofs})
decodeNonInclusionProofs(Object? value) {
  final record = _map(value, r'$');
  return (
    context: _context(record['context']),
    proofs: [
      for (final (index, item) in _list(record['proofs'], r'$.proofs').indexed)
        _nonInclusion(item, '\$.proofs[$index]'),
    ],
  );
}

/// Decodes `getUserRecords`.
({IndexerContext context, List<UserRecord?> records}) decodeUserRecords(
  Object? value,
) {
  final record = _map(value, r'$');
  final records = <UserRecord?>[];
  for (final (index, item) in _list(record['records'], r'$.records').indexed) {
    if (item == null) {
      records.add(null);
      continue;
    }
    final entry = _map(item, '\$.records[$index]');
    final scheme = _int(
      entry['mergeEncryption'],
      '\$.records[$index].mergeEncryption',
    );
    if (scheme != 0 && scheme != 1) {
      throw PrivacyRingsException(
        'mergeEncryption $scheme is not 0 or 1',
        code: 'invalid_response',
      );
    }
    records.add(
      UserRecord(
        owner: _address(entry['owner'], '\$.records[$index].owner'),
        nullifierPubkey: _hash(
          entry['nullifierPubkey'],
          '\$.records[$index].nullifierPubkey',
        ),
        viewingPubkey: _sized(
          _base64(entry['viewingPubkey'], '\$.records[$index].viewingPubkey'),
          33,
          '\$.records[$index].viewingPubkey',
        ),
        mergeEncryption: scheme,
      ),
    );
  }
  return (context: _context(record['context']), records: records);
}
