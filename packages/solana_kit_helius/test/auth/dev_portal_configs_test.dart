import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('dev portal configs', () {
    Map<String, Object?> payload() => {
      'stripe': {
        'priceIds': {
          'Monthly': {'developer_v4': 'price_dev_month'},
          'Yearly': {'developer_v4': 'price_dev_year'},
          'AgentPlan': 'price_agent',
        },
        'prepaidCreditsPlans': {'prepaid_credits_10_USDC': 'price_credits'},
      },
      'openPay': {
        'priceIds': {
          'Monthly': {'legacy': 'legacy_month'},
          'Yearly': {'legacy': 'legacy_year'},
        },
      },
    };

    test(
      'fetchDevPortalConfigs sends bearer auth and optional agent query',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/v0/dev-portal/configs');
          expect(request.url.queryParameters['agent'], 'cli');
          expect(request.headers['Authorization'], 'Bearer jwt-token');
          expect(request.headers['User-Agent'], 'agent');
          return http.Response(jsonEncode(payload()), 200);
        });

        final configs = await fetchDevPortalConfigs(
          'jwt-token',
          includeAgentPlan: true,
          userAgent: 'agent',
          client: client,
        );

        expect(
          configs.stripe.priceIds.monthly['developer_v4'],
          'price_dev_month',
        );
        expect(
          configs.stripe.priceIds.yearly['developer_v4'],
          'price_dev_year',
        );
        expect(configs.stripe.priceIds.agentPlan, 'price_agent');
        expect(configs.openPay!.priceIds.monthly['legacy'], 'legacy_month');
      },
    );

    test('fetchStripePriceIds returns the stripe priceIds block', () async {
      final client = MockClient(
        (request) async => http.Response(jsonEncode(payload()), 200),
      );

      final prices = await fetchStripePriceIds('jwt-token', client: client);

      expect(prices.monthly['developer_v4'], 'price_dev_month');
      expect(prices.yearly['developer_v4'], 'price_dev_year');
      expect(prices.agentPlan, 'price_agent');
    });

    test(
      'fetchPrepaidCreditsPriceIds returns prepaid plans or empty map',
      () async {
        final withPlans = MockClient(
          (request) async => http.Response(jsonEncode(payload()), 200),
        );
        final withoutPlans = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'stripe': {
                'priceIds': {
                  'Monthly': <String, String>{},
                  'Yearly': <String, String>{},
                },
              },
            }),
            200,
          );
        });

        expect(
          await fetchPrepaidCreditsPriceIds('jwt-token', client: withPlans),
          {'prepaid_credits_10_USDC': 'price_credits'},
        );
        expect(
          await fetchPrepaidCreditsPriceIds('jwt-token', client: withoutPlans),
          isEmpty,
        );
      },
    );

    test('throws on HTTP error', () async {
      final client = MockClient((request) async => http.Response('Nope', 500));

      await expectLater(
        fetchDevPortalConfigs('jwt-token', client: client),
        throwsA(isA<Exception>()),
      );
    });
  });
}
