import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_pyth/solana_kit_pyth.dart';
import 'package:test/test.dart';

const priceUpdateFixture = <String, Object?>{
  'binary': {
    'data': ['AnU='],
    'encoding': 'base64',
  },
  'parsed': [
    {
      'id':
          '0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace',
      'price': {
        'conf': '30400150',
        'expo': -8,
        'price': '3040015000',
        'publish_time': 1700000000,
      },
      'ema_price': {
        'conf': '1000000',
        'expo': -8,
        'price': '3030000000',
        'publish_time': 1700000001,
      },
      'metadata': {'slot': 12345, 'prev_publish_time': 1699999900},
    },
  ],
};

const priceFeedsFixture = <Object?>[
  <String, Object?>{
    'asset_type': 'crypto',
    'attributes': <String, Object?>{'country': 'US'},
    'base': 'BTC',
    'description': 'Bitcoin / United States Dollar',
    'id': 'feed-1',
    'quote': 'USD',
    'symbol': 'BTC/USD',
  },
];

void main() {
  group('getLatestPriceUpdates', () {
    test('requests /v2/updates/price/latest with ids[] and options', () async {
      final requests = <http.Request>[];
      final client = HermesClient(
        const HermesConfig(),
        client: MockClient((request) async {
          requests.add(request);
          return http.Response(jsonEncode(priceUpdateFixture), 200);
        }),
      );
      final update = await client.getLatestPriceUpdates(
        ['feed-a', 'feed-b'],
        encoding: HermesEncoding.base64,
        parsed: true,
      );
      expect(requests, hasLength(1));
      expect(requests.single.method, 'GET');
      expect(
        requests.single.url.toString(),
        'https://hermes.pyth.network/v2/updates/price/latest'
        '?ids%5B%5D=feed-a&ids%5B%5D=feed-b&encoding=base64&parsed=true',
      );
      expect(update.binaryEncoding, HermesEncoding.base64);
      expect(update.parsed, hasLength(1));
      expect(update.parsed!.single.price.price, BigInt.from(3040015000));
    });

    test('includes ignore_invalid_price_ids when requested', () async {
      final requests = <http.Request>[];
      final client = HermesClient(
        const HermesConfig(),
        client: MockClient((request) async {
          requests.add(request);
          return http.Response(jsonEncode(priceUpdateFixture), 200);
        }),
      );
      await client.getLatestPriceUpdates(
        const ['feed-a'],
        ignoreInvalidPriceIds: true,
      );
      expect(
        requests.single.url.queryParameters['ignore_invalid_price_ids'],
        'true',
      );
    });
  });

  group('getPriceUpdatesAtTimestamp', () {
    test('requests /v2/updates/price/{publishTime}', () async {
      final requests = <http.Request>[];
      final client = HermesClient(
        const HermesConfig(),
        client: MockClient((request) async {
          requests.add(request);
          return http.Response(jsonEncode(priceUpdateFixture), 200);
        }),
      );
      await client.getPriceUpdatesAtTimestamp(1600000000, const ['feed-a']);
      expect(requests.single.url.path, '/v2/updates/price/1600000000');
    });
  });

  group('getPriceFeeds', () {
    test('requests /v2/price_feeds with filters', () async {
      final requests = <http.Request>[];
      final client = HermesClient(
        const HermesConfig(),
        client: MockClient((request) async {
          requests.add(request);
          return http.Response(jsonEncode(priceFeedsFixture), 200);
        }),
      );
      final feeds = await client.getPriceFeeds(
        query: 'bitcoin',
        assetType: HermesAssetType.crypto,
      );
      expect(requests.single.url.path, '/v2/price_feeds');
      expect(requests.single.url.queryParameters['query'], 'bitcoin');
      expect(requests.single.url.queryParameters['asset_type'], 'crypto');
      expect(feeds, hasLength(1));
      expect(feeds.single.id, 'feed-1');
      expect(feeds.single.symbol, 'BTC/USD');
    });

    test('omits filter parameters when unfiltered', () async {
      final requests = <http.Request>[];
      final client = HermesClient(
        const HermesConfig(),
        client: MockClient((request) async {
          requests.add(request);
          return http.Response('[]', 200);
        }),
      );
      final feeds = await client.getPriceFeeds();
      expect(requests.single.url.queryParameters, isEmpty);
      expect(feeds, isEmpty);
    });
  });

  group('configuration', () {
    test('normalizes trailing slashes in the base url', () async {
      final requests = <http.Request>[];
      final client = HermesClient(
        const HermesConfig(baseUrl: 'https://prices.example.com/'),
        client: MockClient((request) async {
          requests.add(request);
          return http.Response(jsonEncode(priceUpdateFixture), 200);
        }),
      );
      await client.getLatestPriceUpdates(const ['feed-a']);
      expect(requests.single.url.host, 'prices.example.com');
      expect(requests.single.url.path, '/v2/updates/price/latest');
    });

    test('sends the access token as a bearer header', () async {
      final requests = <http.Request>[];
      final client = HermesClient(
        const HermesConfig(accessToken: 'top-secret'),
        client: MockClient((request) async {
          requests.add(request);
          return http.Response(jsonEncode(priceUpdateFixture), 200);
        }),
      );
      await client.getLatestPriceUpdates(const ['feed-a']);
      expect(requests.single.headers['authorization'], 'Bearer top-secret');
    });

    test('sends custom headers', () async {
      final requests = <http.Request>[];
      final client = HermesClient(
        const HermesConfig(headers: {'x-custom': 'yes'}),
        client: MockClient((request) async {
          requests.add(request);
          return http.Response(jsonEncode(priceUpdateFixture), 200);
        }),
      );
      await client.getLatestPriceUpdates(const ['feed-a']);
      expect(requests.single.headers['x-custom'], 'yes');
    });
  });

  group('error handling', () {
    test('throws without retrying on 404', () async {
      var calls = 0;
      final client = HermesClient(
        const HermesConfig(),
        client: MockClient((request) async {
          calls++;
          return http.Response('Not found', 404);
        }),
      );
      await expectLater(
        client.getLatestPriceUpdates(const ['unknown']),
        throwsA(
          isA<PythHttpException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.body, 'body', 'Not found'),
        ),
      );
      expect(calls, 1);
    });

    test('retries 5xx responses then succeeds', () async {
      var calls = 0;
      final client = HermesClient(
        const HermesConfig(
          backoffMs: 1,
        ),
        client: MockClient((request) async {
          calls++;
          if (calls == 1) return http.Response('boom', 500);
          return http.Response(jsonEncode(priceUpdateFixture), 200);
        }),
      );
      final update = await client.getLatestPriceUpdates(const ['feed-a']);
      expect(calls, 2);
      expect(update.binaryData, ['AnU=']);
    });

    test('gives up after the configured number of retries', () async {
      var calls = 0;
      final client = HermesClient(
        const HermesConfig(httpRetries: 2, backoffMs: 1),
        client: MockClient((request) async {
          calls++;
          return http.Response('boom', 503);
        }),
      );
      await expectLater(
        client.getLatestPriceUpdates(const ['feed-a']),
        throwsA(
          isA<PythHttpException>().having(
            (e) => e.statusCode,
            'statusCode',
            503,
          ),
        ),
      );
      expect(calls, 3); // 1 original attempt + 2 retries
    });

    test('reports the response body for non-2xx responses', () async {
      final client = HermesClient(
        const HermesConfig(),
        client: MockClient(
          (request) async =>
              http.Response('', 418, reasonPhrase: "I'm a teapot"),
        ),
      );
      await expectLater(
        client.getLatestPriceUpdates(const ['feed-a']),
        throwsA(
          isA<PythHttpException>()
              .having((e) => e.statusCode, 'statusCode', 418)
              .having((e) => e.body, 'body', "I'm a teapot")
              .having(
                (e) => e.toString(),
                'toString',
                "PythHttpException(status: 418): Hermes request failed — I'm a teapot",
              ),
        ),
      );
    });

    test('wraps timeouts', () async {
      final client = HermesClient(
        const HermesConfig(httpRetries: 0, backoffMs: 1),
        client: MockClient((request) => throw TimeoutException('too slow')),
      );
      await expectLater(
        client.getLatestPriceUpdates(const ['feed-a']),
        throwsA(
          isA<PythException>().having(
            (e) => e.message,
            'message',
            contains('Timed out fetching'),
          ),
        ),
      );
    });

    test('wraps network failures', () async {
      final client = HermesClient(
        const HermesConfig(httpRetries: 0, backoffMs: 1),
        client: MockClient(
          (request) => throw http.ClientException('connection refused'),
        ),
      );
      await expectLater(
        client.getLatestPriceUpdates(const ['feed-a']),
        throwsA(
          isA<PythException>()
              .having(
                (e) => e.message,
                'message',
                contains('Network error fetching'),
              )
              .having(
                (e) => e.message,
                'message',
                contains('connection refused'),
              ),
        ),
      );
    });
  });

  group('response validation', () {
    test('rejects non-object items in the price_feeds array', () async {
      final client = HermesClient(
        const HermesConfig(),
        client: MockClient((request) async => http.Response('[42]', 200)),
      );
      await expectLater(
        client.getPriceFeeds(),
        throwsA(
          isA<PythException>().having(
            (e) => e.message,
            'message',
            'Expected a JSON object, got: 42',
          ),
        ),
      );
    });

    test('rejects non-array price_feeds responses', () async {
      final client = HermesClient(
        const HermesConfig(),
        client: MockClient((request) async => http.Response('{}', 200)),
      );
      await expectLater(
        client.getPriceFeeds(),
        throwsA(
          isA<PythException>().having(
            (e) => e.message,
            'message',
            'Expected a JSON array, got: {}',
          ),
        ),
      );
    });

    test('rejects non-object price update responses', () async {
      final client = HermesClient(
        const HermesConfig(),
        client: MockClient((request) async => http.Response('[]', 200)),
      );
      await expectLater(
        client.getLatestPriceUpdates(const ['feed-a']),
        throwsA(
          isA<PythException>().having(
            (e) => e.message,
            'message',
            'Expected a JSON object, got: []',
          ),
        ),
      );
    });
  });

  group('client construction', () {
    test('creates a default HTTP client when none is provided', () {
      final client = HermesClient(const HermesConfig());
      expect(client.config.baseUrl, HermesConfig.defaultHermesBaseUrl);
      expect(client.config.timeout, const Duration(seconds: 5));
      expect(client.config.httpRetries, HermesConfig.defaultHermesHttpRetries);
    });
  });

  group('getPriceUpdatesAtTimestamp options', () {
    test('forwards ignore_invalid_price_ids', () async {
      final requests = <http.Request>[];
      final client = HermesClient(
        const HermesConfig(),
        client: MockClient((request) async {
          requests.add(request);
          return http.Response(jsonEncode(priceUpdateFixture), 200);
        }),
      );
      await client.getPriceUpdatesAtTimestamp(
        1600000000,
        const ['feed-a'],
        ignoreInvalidPriceIds: true,
      );
      expect(
        requests.single.url.queryParameters['ignore_invalid_price_ids'],
        'true',
      );
    });
  });
}
