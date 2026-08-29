import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_pyth/src/encoding.dart';
import 'package:solana_kit_pyth/src/exceptions.dart';
import 'package:solana_kit_pyth/src/hermes_config.dart';
import 'package:solana_kit_pyth/src/price_feed.dart';

/// Asset type used to filter the [HermesClient.getPriceFeeds] listing.
enum HermesAssetType {
  /// Equities (listed company shares).
  equity._('equity'),

  /// Foreign exchange rates.
  fx._('fx'),

  /// Cryptocurrencies.
  crypto._('crypto'),

  /// Precious metals.
  metal._('metal'),

  /// Interest rates.
  rates._('rates'),

  /// Crypto redemption rates.
  cryptoRedemptionRate._('crypto_redemption_rate'),

  /// Commodities.
  commodities._('commodities'),

  /// Crypto index prices.
  cryptoIndex._('crypto_index'),

  /// Crypto net asset value prices.
  cryptoNav._('crypto_nav'),

  /// Ecology and weather data feeds.
  eco._('eco'),

  /// Kalshi event feeds.
  kalshi._('kalshi');

  const HermesAssetType._(this.value);

  /// The wire name of the asset type as used in Hermes query parameters.
  final String value;
}

/// HTTP client for the Pyth Hermes price service (v2 REST API).
///
/// Mirrors the method surface of the upstream `@pythnetwork/hermes-client`
/// TypeScript package; streaming (SSE) endpoints are not included.
///
/// Each method maps 1:1 to a Hermes REST endpoint:
///
/// * [getPriceFeeds] — `GET /v2/price_feeds`
/// * [getLatestPriceUpdates] — `GET /v2/updates/price/latest`
/// * [getPriceUpdatesAtTimestamp] — `GET /v2/updates/price/{publishTime}`
class HermesClient {
  /// Creates a Hermes client from a [config], optionally reusing an existing
  /// [http.Client] for testability.
  HermesClient(this.config, {http.Client? client})
    : _client = client ?? http.Client();

  /// The configuration used by this client.
  final HermesConfig config;

  final http.Client _client;

  /// Fetches the list of available price feeds.
  ///
  /// The listing can be filtered by a case-insensitive [query] matching feed
  /// symbols, and by [assetType]. Returns one [HermesPriceFeedMetadata] per
  /// available price feed.
  Future<List<HermesPriceFeedMetadata>> getPriceFeeds({
    String? query,
    HermesAssetType? assetType,
  }) async {
    final json = await _getJson(
      _uri('price_feeds', [
        if (query != null) ('query', query),
        if (assetType != null) ('asset_type', assetType.value),
      ]),
    );
    return _asObjectList(
      json,
    ).map(HermesPriceFeedMetadata.fromJson).toList(growable: false);
  }

  /// Fetches the latest price updates for the given price feed [ids].
  ///
  /// [ids] are hex-encoded price feed IDs (with or without a `0x` prefix).
  /// [encoding] selects the encoding of [HermesPriceUpdate.binaryData].
  /// When [parsed] is true, the response also contains the parsed
  /// [HermesPriceUpdate.parsed] feeds. When [ignoreInvalidPriceIds] is true,
  /// unknown price feed IDs are skipped instead of producing an error
  /// response.
  Future<HermesPriceUpdate> getLatestPriceUpdates(
    List<String> ids, {
    HermesEncoding encoding = HermesEncoding.hex,
    bool parsed = false,
    bool ignoreInvalidPriceIds = false,
  }) {
    return _getPriceUpdates('updates/price/latest', ids, {
      'encoding': encoding.value,
      'parsed': '$parsed',
      if (ignoreInvalidPriceIds) 'ignore_invalid_price_ids': 'true',
    });
  }

  /// Fetches the price updates for the given price feed [ids] as of
  /// [publishTime] (Unix timestamp in seconds).
  ///
  /// See [getLatestPriceUpdates] for the meaning of the options.
  Future<HermesPriceUpdate> getPriceUpdatesAtTimestamp(
    int publishTime,
    List<String> ids, {
    HermesEncoding encoding = HermesEncoding.hex,
    bool parsed = false,
    bool ignoreInvalidPriceIds = false,
  }) {
    return _getPriceUpdates('updates/price/$publishTime', ids, {
      'encoding': encoding.value,
      'parsed': '$parsed',
      if (ignoreInvalidPriceIds) 'ignore_invalid_price_ids': 'true',
    });
  }

  Future<HermesPriceUpdate> _getPriceUpdates(
    String path,
    List<String> ids,
    Map<String, String> options,
  ) {
    final parameters = <(String, String)>[
      for (final id in ids) ('ids[]', id),
      ...options.entries.map((entry) => (entry.key, entry.value)),
    ];
    return _getJson(_uri(path, parameters)).then(
      (json) => HermesPriceUpdate.fromJson(_asObject(json)),
    );
  }

  /// Builds a `/v2/...` URI under the configured base URL.
  ///
  /// Query parameters are emitted in insertion order, so the `ids[]`
  /// parameters precede the option parameters, mirroring the upstream client.
  Uri _uri(String path, List<(String, String)> parameters) {
    final buffer = StringBuffer('${config.normalizedBaseUrl}/v2/$path');
    if (parameters.isNotEmpty) {
      buffer
        ..write('?')
        ..writeAll(
          parameters.map(
            (entry) =>
                '${Uri.encodeQueryComponent(entry.$1)}'
                '='
                '${Uri.encodeQueryComponent(entry.$2)}',
          ),
          '&',
        );
    }
    return Uri.parse(buffer.toString());
  }

  Future<Object?> _getJson(Uri uri) async {
    var backoff = config.backoffMs;
    PythException? lastFailure;
    for (var attempt = 0; attempt <= config.httpRetries; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(milliseconds: backoff));
        backoff *= 2;
      }
      try {
        final response = await _client
            .get(uri, headers: _headers)
            .timeout(
              config.timeout,
            );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (response.body.isEmpty) return null;
          return jsonDecode(response.body) as Object?;
        }
        final exception = PythHttpException(
          statusCode: response.statusCode,
          message: 'Hermes request failed',
          body: response.body.isNotEmpty
              ? response.body
              : (response.reasonPhrase ?? 'Unknown error'),
        );
        if (!_isRetryableStatus(response.statusCode)) {
          throw exception;
        }
        lastFailure = exception;
      } on TimeoutException {
        lastFailure = PythException(
          'Timed out fetching $uri after ${config.timeout.inMilliseconds}ms',
        );
      } on http.ClientException catch (error) {
        lastFailure = PythException(
          'Network error fetching $uri: ${error.message}',
        );
      }
    }
    // Every attempt either returned, threw, or recorded a failure, so the
    // only way to get here without a recorded failure is httpRetries < 0.
    throw lastFailure!;
  }

  bool _isRetryableStatus(int statusCode) =>
      statusCode == 408 || statusCode == 429 || statusCode >= 500;

  /// Headers sent with every request, including authentication.
  Map<String, String> get _headers => {
    'accept': 'application/json',
    if (config.accessToken != null)
      'authorization': 'Bearer ${config.accessToken}',
    ...config.headers,
  };

  static List<Map<String, Object?>> _asObjectList(Object? json) {
    if (json is List<Object?>) {
      return [
        for (final item in json)
          if (item case final Map<String, Object?> feed)
            feed
          else
            throw PythException('Expected a JSON object, got: $item'),
      ];
    }
    throw PythException('Expected a JSON array, got: $json');
  }

  static Map<String, Object?> _asObject(Object? json) {
    if (json is Map<String, Object?>) return json;
    throw PythException('Expected a JSON object, got: $json');
  }
}
