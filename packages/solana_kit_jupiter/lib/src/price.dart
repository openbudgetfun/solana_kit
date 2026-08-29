import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_jupiter/src/internal/rest_client.dart';
import 'package:solana_kit_jupiter/src/jupiter_config.dart';
import 'package:solana_kit_jupiter/src/models/price_and_tokens.dart';

const _maxPriceMints = 50;

/// Client for Jupiter's Price API v3.
class JupiterPriceClient {
  /// Creates a price client.
  JupiterPriceClient({required JupiterConfig config})
    : _restClient = JupiterRestClient(
        baseUrl: config.baseUrl,
        apiKey: config.apiKey,
        client: config.client,
      );

  final JupiterRestClient _restClient;

  /// Fetches USD prices for up to fifty mints.
  ///
  /// Returns a map keyed by mint address. Mints without a reliable price are
  /// omitted from the response by the API.
  Future<Map<Address, JupiterPrice>> getPrices(Iterable<Address> mints) async {
    final ids = mints.toList(growable: false);
    if (ids.length > _maxPriceMints) {
      throw ArgumentError.value(
        ids.length,
        'mints',
        'Jupiter Price API accepts at most $_maxPriceMints mints per request',
      );
    }
    final response = await _restClient.get(
      '/price/v3',
      queryParameters: {
        'ids': ids.map((mint) => mint.toString()).join(','),
      },
    );
    final json = switch (response) {
      final Map<String, Object?> json => json,
      _ => <String, Object?>{},
    };
    return json.map((key, value) {
      final price = switch (value) {
        final Map<String, Object?> json => JupiterPrice.fromJson(json),
        _ => null,
      };
      if (price == null) {
        throw JupiterException(
          statusCode: 200,
          message: 'Malformed price entry for $key',
          body: value,
        );
      }
      return MapEntry(Address(key), price);
    });
  }
}
