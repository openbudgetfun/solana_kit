import 'package:solana_kit_jupiter/src/internal/rest_client.dart';
import 'package:solana_kit_jupiter/src/jupiter_config.dart';
import 'package:solana_kit_jupiter/src/models/price_and_tokens.dart';

/// Client for Jupiter's Token API v2.
class JupiterTokenClient {
  /// Creates a token client.
  JupiterTokenClient({required JupiterConfig config})
    : _restClient = JupiterRestClient(
        baseUrl: config.baseUrl,
        apiKey: config.apiKey,
        client: config.client,
      );

  final JupiterRestClient _restClient;

  /// Searches tokens by name, symbol, or mint address.
  Future<List<JupiterTokenItem>> search(String query, {int? limit}) async {
    final response = await _restClient.get(
      '/tokens/v2/search',
      queryParameters: {
        'query': query,
        if (limit != null) 'limit': '$limit',
      },
    );
    return _parseTokenList(response);
  }

  /// Lists tokens tagged with [tag], such as `verified`, `strict`, or `lfg`.
  Future<List<JupiterTokenItem>> tagged(String tag) async {
    final response = await _restClient.get(
      '/tokens/v2/tag',
      queryParameters: {
        'tag': tag,
      },
    );
    return _parseTokenList(response);
  }

  /// Lists tokens in a Token API category such as `toporganized`.
  Future<List<JupiterTokenItem>> category(String category, {int? limit}) async {
    final response = await _restClient.get(
      '/tokens/v2/category',
      queryParameters: {
        'category': category,
        if (limit != null) 'limit': '$limit',
      },
    );
    return _parseTokenList(response);
  }

  /// Lists recently active tokens.
  Future<List<JupiterTokenItem>> recent() async {
    final response = await _restClient.get('/tokens/v2/recent');
    return _parseTokenList(response);
  }

  List<JupiterTokenItem> _parseTokenList(Object? response) {
    final items = switch (response) {
      final List<Object?> list => list,
      _ => throw JupiterException(
        statusCode: 200,
        message: 'Expected a JSON array from the Token API',
        body: response,
      ),
    };
    return items
        .map((item) {
          return switch (item) {
            final Map<String, Object?> json => JupiterTokenItem.fromJson(json),
            _ => throw JupiterException(
              statusCode: 200,
              message: 'Malformed token entry',
              body: item,
            ),
          };
        })
        .toList(growable: false);
  }
}
