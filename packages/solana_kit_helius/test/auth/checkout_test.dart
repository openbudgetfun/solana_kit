import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

Map<String, Object?> configs({bool agent = false}) => {
  'stripe': {
    'priceIds': {
      'Monthly': {
        'developer_v4': 'price_dev_monthly',
        'business_v4': 'price_biz_monthly',
      },
      'Yearly': {
        'developer_v4': 'price_dev_yearly',
        'business_v4': 'price_biz_yearly',
      },
      if (agent) 'AgentPlan': 'price_agent_plan',
    },
  },
};

Map<String, Object?> status({
  String phase = 'confirming',
  bool ready = false,
}) => {
  'status': ready ? 'completed' : phase,
  'phase': phase,
  'subscriptionActive': ready,
  'readyToRedirect': ready,
  'message': ready ? 'Payment successful!' : phase,
};

void main() {
  group('checkout helpers', () {
    test('resolvePriceId resolves plans and agent plan', () async {
      final client = MockClient((request) async {
        expect(
          request.headers['authorization'] ?? request.headers['Authorization'],
          'Bearer jwt',
        );
        return http.Response(
          jsonEncode(
            configs(agent: request.url.queryParameters['agent'] == 'cli'),
          ),
          200,
        );
      });

      expect(
        await resolvePriceId('jwt', 'Developer', 'monthly', client: client),
        'price_dev_monthly',
      );
      expect(
        await resolvePriceId('jwt', 'business', 'yearly', client: client),
        'price_biz_yearly',
      );
      expect(
        await resolvePriceId('jwt', 'agent', 'yearly', client: client),
        'price_agent_plan',
      );
    });

    test('resolvePriceId throws useful errors', () async {
      expect(
        resolvePriceId('jwt', 'basic', 'monthly'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Unknown plan: basic'),
          ),
        ),
      );

      final empty = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'stripe': {
              'priceIds': {
                'Monthly': <String, String>{},
                'Yearly': <String, String>{},
              },
            },
          }),
          200,
        ),
      );
      await expectLater(
        resolvePriceId('jwt', 'developer', 'monthly', client: empty),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('pricing configuration is empty'),
          ),
        ),
      );
    });

    test(
      'covers user-agent, qty, HTTP errors, and agent price failures',
      () async {
        final failed = MockClient(
          (_) async => http.Response('bad gateway', 502),
        );
        await expectLater(
          initializeCheckout(
            'jwt',
            const CheckoutInitializeRequest(priceId: 'price', refId: 'ref'),
            client: failed,
          ),
          throwsA(
            isA<SolanaError>().having(
              (error) => error.context[SolanaErrorContextKeys.statusCode],
              'status code',
              502,
            ),
          ),
        );

        final seen = <String, Object?>{};
        final client = MockClient((request) async {
          seen['userAgent'] =
              request.headers['user-agent'] ?? request.headers['User-Agent'];
          seen['qty'] = request.url.queryParameters['qty'];
          return http.Response(jsonEncode({'dueToday': 1}), 200);
        });
        final preview = await getCheckoutPreviewByPriceId(
          'jwt',
          'price_dev_monthly',
          'ref-1',
          qty: 3,
          userAgent: 'solana-kit-test',
          client: client,
        );
        expect(preview.dueToday, 1);
        expect(seen, {'userAgent': 'solana-kit-test', 'qty': '3'});

        final missingAgent = MockClient(
          (_) async => http.Response(jsonEncode(configs()), 200),
        );
        await expectLater(
          resolvePriceId('jwt', 'agent', 'monthly', client: missingAgent),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('No priceId found for plan "agent"'),
            ),
          ),
        );
      },
    );

    test(
      'initialize, preview, intent, and status use expected endpoints',
      () async {
        final seen = <String>[];
        final client = MockClient((request) async {
          seen.add(
            '${request.method} ${request.url.path}?${request.url.query}',
          );
          switch (request.url.path.replaceFirst('/v0', '')) {
            case '/dev-portal/configs':
              return http.Response(jsonEncode(configs()), 200);
            case '/checkout/preview':
              expect(
                request.url.queryParameters['priceId'],
                'price_dev_monthly',
              );
              return http.Response(
                jsonEncode({
                  'planName': 'Developer',
                  'period': 'monthly',
                  'baseAmount': 4900,
                  'subtotal': 4900,
                  'appliedCredits': 0,
                  'proratedCredits': 0,
                  'discounts': 0,
                  'dueToday': 4900,
                  'destinationWallet': 'Treasury111',
                  'note': '',
                  'coupon': {'code': 'SAVE10', 'valid': true, 'percentOff': 10},
                }),
                200,
              );
            case '/checkout/initialize':
              expect(
                (jsonDecode(request.body) as Map<String, Object?>)['refId'],
                'ref-1',
              );
              return http.Response(
                jsonEncode({
                  'id': 'pi_test',
                  'status': 'pending',
                  'destinationWallet': 'Treasury111',
                  'amount': 4900,
                  'solanaPayUrl': 'solana:...',
                  'expiresAt': '2026-01-01T00:00:00Z',
                }),
                200,
              );
            case '/checkout/pi_test':
              return http.Response(
                jsonEncode({
                  'id': 'pi_test',
                  'status': 'pending',
                  'destinationWallet': 'Treasury111',
                  'amount': 4900,
                  'solanaPayUrl': 'solana:...',
                  'expiresAt': '2026-01-01T00:00:00Z',
                }),
                200,
              );
            case '/checkout/pi_test/status':
              return http.Response(
                jsonEncode(status(phase: 'complete', ready: true)),
                200,
              );
          }
          return http.Response('nope', 404);
        });

        final preview = await getCheckoutPreview(
          'jwt',
          'developer',
          'monthly',
          'ref-1',
          couponCode: 'SAVE10',
          client: client,
        );
        final init = await initializeCheckout(
          'jwt',
          const CheckoutInitializeRequest(
            priceId: 'price_dev_monthly',
            refId: 'ref-1',
          ),
          client: client,
        );
        final intent = await getPaymentIntent('jwt', 'pi_test', client: client);
        final paymentStatus = await getPaymentStatus(
          'jwt',
          'pi_test',
          client: client,
        );

        expect(preview.coupon?.valid, isTrue);
        expect(init.id, 'pi_test');
        expect(intent.amount, 4900);
        expect(paymentStatus.readyToRedirect, isTrue);
        expect(
          seen,
          contains(
            'GET /v0/checkout/preview?priceId=price_dev_monthly&refId=ref-1&couponCode=SAVE10',
          ),
        );
      },
    );
  });

  group('pollUntilTerminal', () {
    test('returns terminal outcomes and timeout', () async {
      expect(
        (await pollUntilTerminal(
          'jwt',
          'pi',
          statusFetcher: () async =>
              CheckoutStatusResponse.fromJson(status(ready: true)),
        )).kind,
        'completed',
      );
      expect(
        (await pollUntilTerminal(
          'jwt',
          'pi',
          statusFetcher: () async =>
              CheckoutStatusResponse.fromJson(status(phase: 'expired')),
        )).kind,
        'expired',
      );
      expect(
        (await pollUntilTerminal(
          'jwt',
          'pi',
          statusFetcher: () async =>
              CheckoutStatusResponse.fromJson(status(phase: 'failed')),
        )).kind,
        'failed',
      );
      expect(
        (await pollUntilTerminal(
          'jwt',
          'pi',
          timeout: const Duration(milliseconds: 1),
          interval: Duration.zero,
          statusFetcher: () async => CheckoutStatusResponse.fromJson(status()),
          sleep: (_) async {},
        )).kind,
        'timeout',
      );
    });

    test('treats http 410 as expired and rethrows other errors', () async {
      final gone = createSolanaError(
        SolanaErrorCode.heliusRestError,
        context: {SolanaErrorContextKeys.statusCode: 410},
      );
      expect(
        (await pollUntilTerminal(
          'jwt',
          'pi',
          statusFetcher: () async => throw gone,
        )).kind,
        'expired',
      );
      expect(
        pollUntilTerminal(
          'jwt',
          'pi',
          statusFetcher: () async => throw StateError('boom'),
        ),
        throwsStateError,
      );
    });

    test(
      'pollCheckoutCompletion maps expired and timeout fallback statuses',
      () async {
        final expiredClient = MockClient(
          (_) async => http.Response('gone', 410),
        );
        final expired = await pollCheckoutCompletion(
          'jwt',
          'pi',
          client: expiredClient,
        );
        expect(expired.phase, 'expired');

        final pending = MockClient(
          (_) async => http.Response(jsonEncode(status()), 200),
        );
        final timeout = await pollCheckoutCompletion(
          'jwt',
          'pi',
          client: pending,
          timeout: const Duration(milliseconds: 1),
          interval: Duration.zero,
          sleep: (_) async {},
        );
        expect(timeout.message, 'Polling timed out');
      },
    );
  });

  group('createPayment', () {
    test('creates a payment link and rejects zero amount preview', () async {
      final client = MockClient((request) async {
        switch (request.url.path.replaceFirst('/v0', '')) {
          case '/checkout/preview':
            return http.Response(jsonEncode({'dueToday': 4900}), 200);
          case '/checkout/initialize':
            return http.Response(
              jsonEncode({
                'id': 'pi_test',
                'status': 'pending',
                'destinationWallet': 'Treasury111',
                'amount': 4900,
                'solanaPayUrl': 'solana:...',
                'expiresAt': '2026-01-01T00:00:00Z',
              }),
              200,
            );
        }
        return http.Response('nope', 404);
      });

      final link = await createPayment(
        const CreatePaymentRequest(
          jwt: 'jwt',
          refId: 'ref-1',
          priceId: 'price_dev_monthly',
          paymentHost: 'https://pay.example',
        ),
        client: client,
      );
      expect(link.paymentUrl, 'https://pay.example/pay/pi_test');
      expect(link.memo, 'pi_test');

      final zero = MockClient(
        (_) async => http.Response(jsonEncode({'dueToday': 0}), 200),
      );
      await expectLater(
        createPayment(
          const CreatePaymentRequest(
            jwt: 'jwt',
            refId: 'ref-1',
            priceId: 'price_dev_monthly',
          ),
          client: zero,
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Zero-amount signups'),
          ),
        ),
      );
    });

    test(
      'supports plan-based payment links and validates missing payment inputs',
      () async {
        await expectLater(
          createPayment(const CreatePaymentRequest(jwt: 'jwt', refId: 'ref-1')),
          throwsA(isA<ArgumentError>()),
        );

        final client = MockClient((request) async {
          switch (request.url.path.replaceFirst('/v0', '')) {
            case '/dev-portal/configs':
              return http.Response(jsonEncode(configs(agent: true)), 200);
            case '/checkout/preview':
              expect(
                request.url.queryParameters['priceId'],
                'price_agent_plan',
              );
              return http.Response(jsonEncode({'dueToday': 1000}), 200);
            case '/checkout/initialize':
              final body = jsonDecode(request.body) as Map<String, Object?>;
              expect(body['priceId'], 'price_agent_plan');
              return http.Response(
                jsonEncode({
                  'id': 'pi_agent',
                  'status': 'pending',
                  'destinationWallet': 'Treasury111',
                  'amount': 1000,
                  'solanaPayUrl': 'solana:...',
                  'expiresAt': '2026-01-01T00:00:00Z',
                }),
                200,
              );
          }
          return http.Response('nope', 404);
        });

        final link = await createPayment(
          const CreatePaymentRequest(jwt: 'jwt', refId: 'ref-1', plan: 'agent'),
          client: client,
        );
        expect(link.planName, 'Agent Plan');
        expect(link.paymentIntentId, 'pi_agent');
      },
    );
  });
}
