import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/parsed_events_types.dart';

/// Client for the mainnet-only Helius Parsed Events REST API.
///
/// Parsed Events decodes signatures and address history into instructions,
/// transfers, and summaries, and scans history server-side by program
/// instruction or token mint.
class ParsedEventsClient {
  /// Creates a Parsed Events client.
  ///
  /// [isMainnet] guards every method: Parsed Events has no devnet deployment,
  /// so a devnet client fails loudly instead of silently reading mainnet
  /// history.
  const ParsedEventsClient({
    required RestClient restClient,
    required String apiKey,
    required bool isMainnet,
  }) : _restClient = restClient, // ignore: prefer_initializing_formals
       _apiKey = apiKey, // ignore: prefer_initializing_formals
       _isMainnet = isMainnet; // ignore: prefer_initializing_formals

  final RestClient _restClient;
  final String _apiKey;
  final bool _isMainnet;

  /// Parses transaction signatures into decoded instructions, transfers, and
  /// summaries.
  ///
  /// Results come back in the same order as the request's `transactions`,
  /// including duplicates. A missing or unparseable transaction does not fail
  /// the request; its item has [ParsedTransactionResult.parserStatus] set to
  /// [ParsedTransactionStatus.error].
  Future<List<ParsedTransactionResult>> parseTransactions(
    ParseTransactionsRequest request,
  ) async {
    _requireMainnet();
    final result = await _post('transactions', request.toJson());
    final list = result! as List<Object?>;

    return list
        .map((entry) {
          final map = (entry as Map?)?.cast<String, Object?>();

          if (map == null) {
            throw const FormatException(
              'Parsed Events returned a non-object transaction result',
            );
          }

          return ParsedTransactionResult.fromJson(map);
        })
        .toList(growable: false);
  }

  /// Returns parsed transaction history for an address.
  ///
  /// Pagination is manual: pass the returned `paginationToken` back to fetch
  /// the next page.
  Future<GetParsedTransactionHistoryResponse> getTransactionHistory(
    GetParsedTransactionHistoryRequest request,
  ) async {
    _requireMainnet();
    final result = await _post('transaction-history', request.toJson());

    return GetParsedTransactionHistoryResponse.fromJson(
      result! as Map<String, Object?>,
    );
  }

  /// Scans an address's history server-side for transactions that call one of
  /// a set of programs, touch one of a set of mints, or both.
  ///
  /// Pagination is manual: a request that stops early still succeeds, possibly
  /// with empty [ScanResponse.data], so keep calling with the returned
  /// `paginationToken` until it is absent.
  Future<ScanResponse> scan(ScanParsedTransactionHistoryRequest request) async {
    _requireMainnet();
    final result = await _post('scan', request.toJson());

    return ScanResponse.fromJson(result! as Map<String, Object?>);
  }

  Future<Object?> _post(String path, Map<String, Object?> body) {
    return _restClient.post(
      '$path?api-key=${Uri.encodeQueryComponent(_apiKey)}',
      body: _withoutNulls(body),
    );
  }

  void _requireMainnet() {
    if (!_isMainnet) {
      throw StateError('Parsed Events is only available on mainnet.');
    }
  }
}

/// Recursively removes null values, matching the Parsed Events wire contract
/// where every optional field is non-nullable.
Object? _withoutNulls(Object? value) {
  if (value is Map<String, Object?>) {
    return {
      for (final entry in value.entries)
        if (entry.value != null) entry.key: _withoutNulls(entry.value),
    };
  }

  if (value is List) {
    return value.map(_withoutNulls).toList();
  }

  return value;
}
