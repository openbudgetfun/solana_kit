import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_jupiter/solana_kit_jupiter.dart';
import 'package:test/test.dart';

const _wsol = 'So11111111111111111111111111111111111111112';
const _usdc = 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';

void main() {
  group('JupiterPriceClient', () {
    test('getPrices sends comma-separated ids and parses the map', () async {
      Uri? capturedUri;
      final config = JupiterConfig(
        client: MockClient((request) async {
          capturedUri = request.url;
          return http.Response(
            jsonEncode({
              _wsol: {
                'usdPrice': 123.45,
                'blockId': '270583299',
                'decimals': 9,
                'priceChange24h': -1.5,
              },
            }),
            200,
          );
        }),
      );
      final client = createJupiterClient(config);

      final prices = await client.price.getPrices([
        const Address(_wsol),
        const Address(_usdc),
      ]);

      expect(capturedUri?.path, '/price/v3');
      expect(
        capturedUri?.queryParameters['ids'],
        '$_wsol,$_usdc',
      );
      expect(prices, containsPair(const Address(_wsol), isA<JupiterPrice>()));
      expect(prices[const Address(_usdc)], isNull);
      expect(prices[const Address(_wsol)]!.usdPrice, 123.45);
      expect(prices[const Address(_wsol)]!.blockId, '270583299');
      expect(prices[const Address(_wsol)]!.decimals, 9);
      expect(prices[const Address(_wsol)]!.priceChange24h, -1.5);
    });

    test('getPrices rejects more than fifty mints', () async {
      final client = createJupiterClient(JupiterConfig());
      final mints = List.generate(
        51,
        (index) => const Address(_wsol),
      );
      expect(
        () => client.price.getPrices(mints),
        throwsArgumentError,
      );
    });

    test('getPrices rejects non-map bodies', () async {
      final config = JupiterConfig(
        client: MockClient(
          (request) async => http.Response('[1, 2]', 200),
        ),
      );
      final client = createJupiterClient(config);
      await expectLater(
        client.price.getPrices([const Address(_wsol)]),
        throwsA(isA<JupiterException>()),
      );
    });

    test('getPrices throws on malformed price entries', () async {
      final config = JupiterConfig(
        client: MockClient(
          (request) async => http.Response('{"not-a-map": 13}', 200),
        ),
      );
      final client = createJupiterClient(config);
      await expectLater(
        client.price.getPrices([const Address(_wsol)]),
        throwsA(isA<JupiterException>()),
      );
    });
  });

  group('JupiterTokenClient', () {
    test('search sends the query and parses items', () async {
      Uri? capturedUri;
      final config = JupiterConfig(
        client: MockClient((request) async {
          capturedUri = request.url;
          return http.Response(
            jsonEncode([
              {
                'id': _usdc,
                'name': 'USD Coin',
                'symbol': 'USDC',
                'icon': 'https://example.com/usdc.png',
                'decimals': 6,
                'tags': ['verified', 'strict'],
                'organicScore': 0.42,
                'organicScoreLabel': 'medium',
                'isVerified': true,
                'holderCount': 1000,
                'usdPrice': '1.0',
                'mcap': 100,
                'liquidity': null,
              },
              {'id': _wsol},
            ]),
            200,
          );
        }),
      );
      final client = createJupiterClient(config);

      final items = await client.tokens.search('USDC', limit: 5);

      expect(capturedUri?.path, '/tokens/v2/search');
      expect(capturedUri?.queryParameters['query'], 'USDC');
      expect(capturedUri?.queryParameters['limit'], '5');
      expect(items, hasLength(2));
      expect(items[0].symbol, 'USDC');
      expect(items[0].isVerified, isTrue);
      expect(items[0].tags, ['verified', 'strict']);
      expect(items[0].usdPrice, 1.0);
      expect(items[0].liquidity, isNull);
      expect(items[1].name, isNull);
    });

    test('tagged, category, and recent hit their endpoints', () async {
      final paths = <String>[];
      final config = JupiterConfig(
        client: MockClient((request) async {
          paths.add(request.url.path);
          return http.Response('[]', 200);
        }),
      );
      final client = createJupiterClient(config);

      expect(await client.tokens.tagged('verified'), isEmpty);
      expect(
        await client.tokens.category('toporganicscore', limit: 3),
        isEmpty,
      );
      expect(await client.tokens.recent(), isEmpty);
      expect(paths, [
        '/tokens/v2/tag',
        '/tokens/v2/toporganicscore/24h',
        '/tokens/v2/recent',
      ]);
    });

    test('non-array responses throw', () async {
      final config = JupiterConfig(
        client: MockClient(
          (request) async => http.Response('{"not": "a list"}', 200),
        ),
      );
      final client = createJupiterClient(config);
      await expectLater(
        client.tokens.search('WSOL'),
        throwsA(isA<JupiterException>()),
      );
    });

    test('malformed items throw', () async {
      final config = JupiterConfig(
        client: MockClient((request) async => http.Response('[42]', 200)),
      );
      final client = createJupiterClient(config);
      await expectLater(
        client.tokens.recent(),
        throwsA(isA<JupiterException>()),
      );
    });
  });

  group('model parsing', () {
    test('JupiterPrice handles integer-shaped fields', () {
      final price = JupiterPrice.fromJson({
        'usdPrice': 2,
        'blockId': 42,
        'decimals': '9',
      });
      expect(price.usdPrice, 2.0);
      expect(price.blockId, '42');
      expect(price.decimals, 9);
      expect(price.priceChange24h, isNull);
    });

    test('JupiterOrderResponse tolerates numeric amounts', () {
      final order = JupiterOrderResponse.fromJson({
        'inAmount': 1000,
        'outAmount': '2000',
        'transaction': null,
      });
      expect(order.inAmount, BigInt.from(1000));
      expect(order.outAmount, BigInt.from(2000));
      expect(order.encodedTransaction, isNull);
    });

    test('JupiterExecutionResponse keeps object errors as null', () {
      final execution = JupiterExecutionResponse.fromJson({
        'error': {'code': 1},
      });
      expect(execution.error, isNull);
    });

    test('JupiterBuildResponse parses setup and cleanup instructions', () {
      final built = JupiterBuildResponse.fromJson({
        'setupInstructions': [
          {
            'programId': _programId,
            'accounts': [
              {
                'pubkey': _wsol,
                'isSigner': true,
                'isWritable': false,
              },
            ],
            'data': 'AA==',
          },
        ],
        'cleanupInstruction': {'programId': _programId},
      });
      expect(built.computeBudgetInstructions, isNull);
      expect(built.setupInstructions![0].accounts![0].pubkey, _wsol);
      expect(built.cleanupInstruction!.programId, _programId);
      expect(built.addressLookupTableAddresses, isNull);
    });
  });
}

const _programId = 'JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4';
