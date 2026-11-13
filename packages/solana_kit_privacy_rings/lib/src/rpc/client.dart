import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

import 'package:solana_kit_privacy_rings/src/constants.dart';
import 'package:solana_kit_privacy_rings/src/exception.dart';
import 'package:solana_kit_privacy_rings/src/redact.dart';
import 'package:solana_kit_privacy_rings/src/rpc/types.dart';

/// JSON-RPC client for the Privacy Rings indexer.
///
/// Each call is `POST {indexer}/{method}` with a JSON-RPC 2.0 body whose
/// `method` equals the path segment. That is the shape documented at
/// <https://www.helius.dev/docs/privacy/endpoints> and implemented by
/// `postJsonRpc` in `sdk-libs/ts/src/services/jsonrpc.ts`.
class PrivacyIndexerClient {
  /// Creates a client for [endpoint].
  ///
  /// [endpoint] is the indexer base, for example
  /// `https://mainnet.helius-rpc.com/v1/spr`. An `api-key` query on
  /// [endpoint] is lifted off the stored URL. Pass [apiKey] only when the
  /// URL does not already carry one.
  PrivacyIndexerClient({
    required Uri endpoint,
    http.Client? httpClient,
    String? apiKey,
  }) : _http = httpClient ?? http.Client(),
       _ownsClient = httpClient == null,
       _apiKey = _takeApiKey(endpoint, apiKey),
       _endpoint = _withoutApiKey(endpoint);

  final http.Client _http;
  final bool _ownsClient;
  final String? _apiKey;
  final Uri _endpoint;
  int _nextId = 1;

  /// Releases the HTTP client when this object created it.
  void close() {
    if (_ownsClient) _http.close();
  }

  /// `getEncryptedUtxosByTags`.
  Future<IndexerPage<TransactionPageEntry<EncryptedUtxoMatch>>>
  getEncryptedUtxosByTags({
    List<String> tags = const [],
    Address? ringProgramId,
    PageRequest page = const PageRequest(),
  }) async {
    return decodeEncryptedUtxos(
      await _call(
        'getEncryptedUtxosByTags',
        _tagsParams(tags, ringProgramId, page),
      ),
    );
  }

  /// `getShieldedTransactionsByTags`.
  Future<IndexerPage<TransactionPageEntry<ShieldedTransaction>>>
  getShieldedTransactionsByTags({
    List<String> tags = const [],
    Address? ringProgramId,
    PageRequest page = const PageRequest(),
  }) async {
    return decodeShieldedTransactions(
      await _call(
        'getShieldedTransactionsByTags',
        _tagsParams(tags, ringProgramId, page),
      ),
    );
  }

  /// `getShieldedTransactionsByNullifiers`.
  Future<IndexerPage<TransactionPageEntry<ShieldedTransaction>>>
  getShieldedTransactionsByNullifiers({
    required List<String> nullifiers,
    PageRequest page = const PageRequest(),
  }) async {
    if (nullifiers.isEmpty) {
      throw PrivacyRingsException(
        'nullifiers must not be empty',
        code: 'invalid_request',
      );
    }
    for (final (index, value) in nullifiers.indexed) {
      _hash(value, 'nullifiers[$index]');
    }
    return decodeShieldedTransactions(
      await _call('getShieldedTransactionsByNullifiers', {
        'nullifiers': nullifiers,
        ...pageControls(page),
      }),
    );
  }

  /// `getShieldedTransactionsBySignature`.
  Future<
    ({
      IndexerContext context,
      int? outputTreeId,
      List<({int eventIndex, ShieldedTransaction transaction})> transactions,
    })
  >
  getShieldedTransactionsBySignature(String txSignature) async {
    _signature(txSignature);
    return decodeShieldedTransactionsBySignature(
      await _call('getShieldedTransactionsBySignature', {
        'txSignature': txSignature,
      }),
    );
  }

  /// `getMerkleProofs`.
  Future<({IndexerContext context, List<MerkleProof> proofs})> getMerkleProofs({
    required Address treeAccount,
    required List<String> leaves,
  }) async {
    return decodeMerkleProofs(
      await _call('getMerkleProofs', _leaves(treeAccount, leaves)),
    );
  }

  /// `getNonInclusionProofs`.
  Future<({IndexerContext context, List<NonInclusionProof> proofs})>
  getNonInclusionProofs({
    required Address treeAccount,
    required List<String> leaves,
  }) async {
    return decodeNonInclusionProofs(
      await _call('getNonInclusionProofs', _leaves(treeAccount, leaves)),
    );
  }

  /// `getNullifierQueueElements`.
  ///
  /// Returns elements with `seq >= startSeq`, at most [limit] of them.
  /// [limit] is from 1 to 1000. [startSeq] defaults to 0.
  Future<({IndexerContext context, List<NullifierQueueElement> elements})>
  getNullifierQueueElements({
    required Address treeAccount,
    required int limit,
    int startSeq = 0,
  }) async {
    if (startSeq < 0) {
      throw PrivacyRingsException(
        'startSeq is negative',
        code: 'integer_range',
      );
    }
    if (limit < 1 || limit > 1000) {
      throw PrivacyRingsException(
        'limit must be from 1 to 1000',
        code: 'invalid_limit',
      );
    }
    return decodeNullifierQueueElements(
      await _call('getNullifierQueueElements', {
        'treeAccount': treeAccount.toString(),
        'startSeq': startSeq,
        'limit': limit,
      }),
    );
  }

  /// `getUserRecords`.
  ///
  /// At most [maxUserRecordOwners] owners. A null entry means that owner
  /// has not registered.
  Future<({IndexerContext context, List<UserRecord?> records})> getUserRecords(
    List<Address> owners,
  ) async {
    if (owners.isEmpty || owners.length > maxUserRecordOwners) {
      throw PrivacyRingsException(
        'getUserRecords accepts 1 to $maxUserRecordOwners owners',
        code: 'invalid_request',
      );
    }
    return decodeUserRecords(
      await _call('getUserRecords', {
        'owners': [for (final owner in owners) owner.toString()],
      }),
    );
  }

  Future<Object?> _call(String method, Map<String, Object?> params) async {
    final id = _nextId++;
    final url = _methodUrl(method);
    final body = jsonEncode({
      'jsonrpc': '2.0',
      'id': id,
      'method': method,
      'params': params,
    });
    late http.Response response;
    try {
      response = await _http.post(
        url,
        headers: {
          'accept': 'application/json',
          'x-api-key': ?_apiKey,
          'content-type': 'application/json; charset=utf-8',
        },
        body: body,
      );
    } catch (error) {
      throw PrivacyRingsException(
        'indexer request failed: ${redactSecrets(error.toString(), apiKey: _apiKey)}',
        code: 'indexer_transport',
      );
    }
    if (response.statusCode != 200) {
      throw PrivacyRingsException(
        'indexer HTTP ${response.statusCode} for $method at ${redactUri(url)}',
        code: 'indexer_http',
      );
    }
    Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw PrivacyRingsException(
        'indexer response for $method was not JSON',
        code: 'invalid_response',
      );
    }
    return _result(decoded, id, method);
  }

  Uri _methodUrl(String method) {
    final basePath = _endpoint.path.replaceAll(RegExp(r'/+$'), '');
    final path = basePath.isEmpty ? '/$method' : '$basePath/$method';
    final query = Map<String, String>.from(_endpoint.queryParameters);
    return _endpoint.replace(
      path: path,
      queryParameters: query,
    );
  }

  Object? _result(Object? value, int id, String method) {
    if (value is! Map) {
      throw PrivacyRingsException(
        'indexer response for $method is not an object',
        code: 'invalid_response',
      );
    }
    final record = value.map((key, item) => MapEntry(key.toString(), item));
    const allowed = {'id', 'jsonrpc', 'result', 'error'};
    if (record.keys.any((key) => !allowed.contains(key))) {
      throw PrivacyRingsException(
        'indexer response for $method has unexpected fields',
        code: 'invalid_response',
      );
    }
    if (record['jsonrpc'] != '2.0' || record['id'] != id) {
      throw PrivacyRingsException(
        'indexer response for $method does not match the request',
        code: 'invalid_response',
      );
    }
    final hasResult = record.containsKey('result');
    final error = record['error'];
    final hasError = record.containsKey('error') && error != null;
    if (hasResult && hasError) {
      throw PrivacyRingsException(
        'indexer response for $method has both result and error',
        code: 'invalid_response',
      );
    }
    if (hasError) {
      final code = error is Map ? error['code'] : null;
      final message = error is Map ? error['message'] : null;
      throw PrivacyRingsException(
        'indexer $method failed'
        '${code is num ? ' ($code)' : ''}'
        '${message is String ? ': ${redactSecrets(message, apiKey: _apiKey)}' : ''}',
        code: 'indexer_error',
      );
    }
    if (!hasResult) {
      throw PrivacyRingsException(
        'indexer response for $method omitted its result',
        code: 'invalid_response',
      );
    }
    return record['result'];
  }
}

Map<String, Object?> _tagsParams(
  List<String> tags,
  Address? ringProgramId,
  PageRequest page,
) {
  if (tags.isEmpty && ringProgramId == null) {
    throw PrivacyRingsException(
      'tags or ringProgramId is required',
      code: 'invalid_request',
    );
  }
  for (final (index, tag) in tags.indexed) {
    _hash(tag, 'tags[$index]');
  }
  return {
    'tags': tags,
    ...pageControls(page),
    if (ringProgramId != null) 'ringProgramId': ringProgramId.toString(),
  };
}

Map<String, Object?> _leaves(Address tree, List<String> leaves) {
  if (leaves.isEmpty) {
    throw PrivacyRingsException(
      'leaves must not be empty',
      code: 'invalid_request',
    );
  }
  for (final (index, leaf) in leaves.indexed) {
    _hash(leaf, 'leaves[$index]');
  }
  return {'treeAccount': tree.toString(), 'leaves': leaves};
}

void _hash(String value, String name) {
  late List<int> bytes;
  try {
    bytes = getBase58Encoder().encode(value);
  } on Object {
    throw PrivacyRingsException(
      '$name is not base58',
      code: 'invalid_request',
    );
  }
  if (bytes.length != 32) {
    throw PrivacyRingsException(
      '$name is not a 32-byte base58 value',
      code: 'invalid_request',
    );
  }
}

void _signature(String value) {
  late List<int> bytes;
  try {
    bytes = getBase58Encoder().encode(value);
  } on Object {
    throw PrivacyRingsException(
      'txSignature is not base58',
      code: 'invalid_request',
    );
  }
  if (bytes.length != 64) {
    throw PrivacyRingsException(
      'txSignature is not a 64-byte base58 signature',
      code: 'invalid_request',
    );
  }
}

String? _takeApiKey(Uri endpoint, String? apiKey) {
  final queryKey = endpoint.queryParameters['api-key'];
  if (apiKey != null && queryKey != null) {
    throw PrivacyRingsException(
      'pass the API key either in the URL or as apiKey, not both',
      code: 'invalid_config',
    );
  }
  final key = apiKey ?? queryKey;
  if (key != null && key.isEmpty) {
    throw PrivacyRingsException('API key is empty', code: 'invalid_config');
  }
  return key;
}

Uri _withoutApiKey(Uri endpoint) {
  if (!endpoint.queryParameters.containsKey('api-key')) return endpoint;
  final query = Map<String, String>.from(endpoint.queryParameters)
    ..remove('api-key');
  return endpoint.replace(queryParameters: query);
}
