import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:test/test.dart';

Uint8List _secretKey() {
  final keyPair = generateKeyPair();
  try {
    return Uint8List.fromList([...keyPair.privateKey, ...keyPair.publicKey]);
  } finally {
    keyPair.dispose();
  }
}

Map<String, Object?> _project(
  String id, {
  String plan = 'agent_v4',
  String billingPeriodStart = '2026-01-01',
  String billingPeriodEnd = '2026-02-01',
}) => {
  'id': id,
  'subscription': {
    'plan': plan,
    'billingPeriodStart': billingPeriodStart,
    'billingPeriodEnd': billingPeriodEnd,
  },
};

RestClient _restClient() {
  return RestClient(
    baseUrl: 'https://dev-api.helius.xyz/v0',
    client: MockClient(
      (request) async => http.Response('legacy API used', 500),
    ),
  );
}

/// HTTP mock for the hosted-checkout API: `/checkout/initialize` creates a
/// payment intent, `/checkout/{id}/status` reports the poll status.
http.Client _checkoutClient({
  String phase = '',
  bool readyToRedirect = false,
  String? message,
  List<Map<String, Object?>> Function()? projects,
  String projectApiKey = 'proj-key',
  void Function(http.Request request)? onRequest,
}) {
  return MockClient((request) async {
    onRequest?.call(request);
    final path = request.url.path;
    if (path.endsWith('/v0/wallet-signup') && request.method == 'POST') {
      return http.Response(
        jsonEncode({
          'token': 'jwt-from-signup',
          'refId': 'ref-from-signup',
          'newUser': true,
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    if (path.endsWith('/v0/projects') && request.method == 'GET') {
      return http.Response(
        jsonEncode(projects?.call() ?? const <Object?>[]),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    if (path.endsWith('/add-key') && request.method == 'POST') {
      return http.Response(
        jsonEncode({'keyId': 'new-key'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    if (path.contains('/v0/projects/') && request.method == 'GET') {
      return http.Response(
        jsonEncode({
          'apiKeys': projectApiKey.isEmpty
              ? const <Object?>[]
              : [
                  {'keyId': projectApiKey},
                ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    if (request.url.host == 'sender.helius-rpc.com') {
      return http.Response(
        jsonEncode('sig123'),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    if (path.endsWith('/dev-portal/configs')) {
      return http.Response(
        jsonEncode({
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
            },
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    if (path.endsWith('/checkout/initialize')) {
      return http.Response(
        jsonEncode({
          'id': 'pi-1',
          'status': 'pending',
          'destinationWallet': '11111111111111111111111111111111',
          'amount': 5000,
          'solanaPayUrl': 'solana:pi-1',
          'expiresAt': '2026-01-01',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    if (path.endsWith('/checkout/pi-1/status')) {
      return http.Response(
        jsonEncode({
          'phase': phase,
          'readyToRedirect': readyToRedirect,
          'message': ?message,
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    return http.Response('{"error":"not found"}', 404);
  });
}

/// RPC mock for `getLatestBlockhash` + `sendTransaction` and the Helius
/// Sender `/fast` endpoint.
JsonRpcClient _rpcClient() {
  return JsonRpcClient(
    url: 'https://rpc',
    client: MockClient((request) async {
      if (request.url.host == 'sender.helius-rpc.com') {
        return http.Response(
          jsonEncode('sig123'),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      final body = jsonDecode(request.body) as Map<String, Object?>;
      final method = body['method'];
      if (method == 'getLatestBlockhash') {
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'result': {
              'value': {
                'blockhash': '11111111111111111111111111111111',
                'lastValidBlockHeight': 123,
              },
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      if (method == 'sendTransaction') {
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': 'sig123'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response('{"error":"unknown"}', 500);
    }),
  );
}

SignupRequest _preauthenticatedRequest({String plan = 'developer'}) =>
    SignupRequest.preauthenticated(
      jwt: 'jwt',
      refId: 'ref-1',
      walletAddress: '11111111111111111111111111111111',
      plan: plan,
      email: 'user@example.com',
      firstName: 'Ada',
      lastName: 'Lovelace',
    );

void main() {
  group('authSignup', () {
    test('returns a payment link for a new signup', () async {
      final rest = _restClient();
      final result = await authSignup(
        rest,
        'api-key',
        _preauthenticatedRequest(),
        httpClient: _checkoutClient(),
      );
      expect(result, isA<PaymentRequiredResult>());
      final payment = result as PaymentRequiredResult;
      expect(payment.jwt, 'jwt');
      expect(payment.refId, 'ref-1');
      expect(payment.paymentLink.paymentIntentId, 'pi-1');
      expect(payment.paymentLink.amountCents, 5000);
      expect(payment.paymentLink.planName, 'Developer (Monthly)');
    });

    test(
      'short-circuits with AlreadySubscribedResult for the agent plan',
      () async {
        final rest = _restClient();
        final result = await authSignup(
          rest,
          'api-key',
          _preauthenticatedRequest(plan: 'agent'),
          httpClient: _checkoutClient(projects: () => [_project('p-1')]),
        );
        expect(result, isA<AlreadySubscribedResult>());
        final subscribed = result as AlreadySubscribedResult;
        expect(subscribed.projectId, 'p-1');
        expect(subscribed.apiKey, 'proj-key');
        expect(
          subscribed.endpoints.mainnet,
          'https://mainnet.helius-rpc.com/?api-key=proj-key',
        );
      },
    );

    test(
      'short-circuits with UpgradeRequiredResult for another plan',
      () async {
        final rest = _restClient();
        final result = await authSignup(
          rest,
          'api-key',
          _preauthenticatedRequest(plan: 'business'),
          httpClient: _checkoutClient(
            projects: () => [_project('p-1', plan: 'developer_v4')],
          ),
        );
        expect(result, isA<UpgradeRequiredResult>());
        final upgrade = result as UpgradeRequiredResult;
        expect(upgrade.currentPlan, 'developer_v4');
        expect(upgrade.requestedPlan, 'business');
      },
    );

    test('matches monthly and yearly existing subscriptions', () async {
      final rest = _restClient();
      final cases = <({String period, String start, String end})>[
        (period: 'monthly', start: '2026-01-01', end: '2026-02-01'),
        (period: 'yearly', start: '2026-01-01', end: '2027-01-01'),
      ];

      for (final entry in cases) {
        final request = SignupRequest.preauthenticated(
          jwt: 'jwt',
          refId: 'ref-1',
          walletAddress: '11111111111111111111111111111111',
          plan: 'developer',
          period: entry.period,
        );
        final result = await authSignup(
          rest,
          'api-key',
          request,
          httpClient: _checkoutClient(
            projects: () => [
              _project(
                'p-1',
                plan: 'developer_v4',
                billingPeriodStart: entry.start,
                billingPeriodEnd: entry.end,
              ),
            ],
          ),
        );
        expect(result, isA<AlreadySubscribedResult>());
      }
    });

    test('creates an API key when an existing project has none', () async {
      final result = await authSignup(
        _restClient(),
        'api-key',
        _preauthenticatedRequest(plan: 'agent'),
        httpClient: _checkoutClient(
          projects: () => [_project('p-1')],
          projectApiKey: '',
        ),
      );

      expect(result, isA<AlreadySubscribedResult>());
      expect((result as AlreadySubscribedResult).apiKey, 'new-key');
    });

    test('rejects empty preauthenticated credentials', () async {
      const request = SignupRequest.preauthenticated(
        jwt: '',
        refId: '',
        walletAddress: '11111111111111111111111111111111',
        plan: 'developer',
      );

      await expectLater(
        authSignup(_restClient(), 'api-key', request),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects secret keys that do not decode to 64 bytes', () async {
      final request = SignupRequest.secretKey(
        secretKey: base64Encode(Uint8List(63)),
        plan: 'developer',
      );

      await expectLater(
        authSignup(_restClient(), 'api-key', request),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when contact info is missing for a new signup', () async {
      final rest = _restClient();
      const request = SignupRequest.preauthenticated(
        jwt: 'jwt',
        refId: 'ref-1',
        walletAddress: '11111111111111111111111111111111',
        plan: 'developer',
      );
      expect(
        () => authSignup(
          rest,
          'api-key',
          request,
          httpClient: _checkoutClient(),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('throws for an unknown plan', () async {
      final rest = _restClient();
      expect(
        () => authSignup(
          rest,
          'api-key',
          _preauthenticatedRequest(plan: 'enterprise'),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws for an unknown billing period', () async {
      final rest = _restClient();
      const request = SignupRequest.preauthenticated(
        jwt: 'jwt',
        refId: 'ref-1',
        walletAddress: '11111111111111111111111111111111',
        plan: 'developer',
        period: 'weekly',
      );
      expect(
        () => authSignup(rest, 'api-key', request),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects empty contact fields for a new signup', () async {
      final rest = _restClient();
      const request = SignupRequest.preauthenticated(
        jwt: 'jwt',
        refId: 'ref-1',
        walletAddress: '11111111111111111111111111111111',
        plan: 'developer',
        email: ' ',
        firstName: 'Ada',
        lastName: 'Lovelace',
      );
      expect(
        () => authSignup(
          rest,
          'api-key',
          request,
          httpClient: _checkoutClient(),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('authenticates with a secret key when no JWT is provided', () async {
      final rest = _restClient();
      final request = SignupRequest.secretKey(
        secretKey: base64Encode(_secretKey()),
        plan: 'developer',
        email: 'user@example.com',
        firstName: 'Ada',
        lastName: 'Lovelace',
      );
      http.Request? signupRequest;
      final result = await authSignup(
        rest,
        'api-key',
        request,
        httpClient: _checkoutClient(
          onRequest: (request) {
            if (request.url.path.endsWith('/v0/wallet-signup')) {
              signupRequest = request;
            }
          },
        ),
      );
      expect(result, isA<PaymentRequiredResult>());
      final payment = result as PaymentRequiredResult;
      expect(payment.jwt, 'jwt-from-signup');
      expect(payment.refId, 'ref-from-signup');
      expect(signupRequest?.url.queryParameters, isEmpty);
      expect(signupRequest?.headers['Authorization'], isNull);
      final signupBody =
          jsonDecode(signupRequest!.body) as Map<String, Object?>;
      expect(signupBody.keys, containsAll(['message', 'signature', 'userID']));
    });
  });

  group('signupAndPay', () {
    test('returns AlreadySubscribedResult for the agent plan', () async {
      final rest = _restClient();
      final result = await signupAndPay(
        rest,
        'api-key',
        _preauthenticatedRequest(plan: 'agent'),
        secretKey: _secretKey(),
        client: _checkoutClient(projects: () => [_project('p-1')]),
      );
      expect(result, isA<SignupAndPayAlreadySubscribedResult>());
      final subscribed = result as SignupAndPayAlreadySubscribedResult;
      expect(subscribed.projectId, 'p-1');
      expect(subscribed.apiKey, 'proj-key');
    });

    test('returns UpgradeRequiredResult for another plan', () async {
      final rest = _restClient();
      final result = await signupAndPay(
        rest,
        'api-key',
        _preauthenticatedRequest(plan: 'business'),
        secretKey: _secretKey(),
        client: _checkoutClient(
          projects: () => [_project('p-1', plan: 'developer_v4')],
        ),
      );
      expect(result, isA<SignupAndPayUpgradeRequiredResult>());
      final upgrade = result as SignupAndPayUpgradeRequiredResult;
      expect(upgrade.requestedPlan, 'business');
    });

    test('provisions a project after a completed payment', () async {
      var projectCalls = 0;
      final rest = _restClient();
      List<Map<String, Object?>> projects() {
        projectCalls++;
        return projectCalls <= 2 ? [] : [_project('p-1')];
      }

      final result = await signupAndPay(
        rest,
        'api-key',
        _preauthenticatedRequest(),
        secretKey: _secretKey(),
        rpcClient: _rpcClient(),
        client: _checkoutClient(
          readyToRedirect: true,
          projects: projects,
          projectApiKey: '',
        ),
      );
      expect(result, isA<SignupAndPayCompletedResult>());
      final completed = result as SignupAndPayCompletedResult;
      expect(completed.projectId, 'p-1');
      expect(completed.apiKey, 'new-key');
      expect(completed.txSignature, 'sig123');
      expect(completed.paymentIntentId, 'pi-1');
      expect(
        completed.endpoints.mainnet,
        'https://mainnet.helius-rpc.com/?api-key=new-key',
      );
    });

    test('throws when no project is provisioned before the timeout', () async {
      final rest = _restClient();
      await expectLater(
        signupAndPay(
          rest,
          'api-key',
          _preauthenticatedRequest(),
          secretKey: _secretKey(),
          rpcClient: _rpcClient(),
          client: _checkoutClient(readyToRedirect: true),
          provisionTimeout: const Duration(milliseconds: 50),
          provisionInterval: const Duration(milliseconds: 5),
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('no project was provisioned'),
          ),
        ),
      );
    });

    test('returns ExpiredResult when the payment expires', () async {
      final rest = _restClient();
      final result = await signupAndPay(
        rest,
        'api-key',
        _preauthenticatedRequest(),
        secretKey: _secretKey(),
        rpcClient: _rpcClient(),
        client: _checkoutClient(phase: 'expired'),
      );
      expect(result, isA<SignupAndPayExpiredResult>());
      expect((result as SignupAndPayExpiredResult).paymentIntentId, 'pi-1');
    });

    test('returns FailedResult when the payment fails', () async {
      final rest = _restClient();
      final result = await signupAndPay(
        rest,
        'api-key',
        _preauthenticatedRequest(),
        secretKey: _secretKey(),
        rpcClient: _rpcClient(),
        client: _checkoutClient(phase: 'failed', message: 'Payment failed'),
      );
      expect(result, isA<SignupAndPayFailedResult>());
      expect((result as SignupAndPayFailedResult).reason, 'Payment failed');
    });

    test('returns PendingResult when the poll times out', () async {
      final rest = _restClient();
      final result = await signupAndPay(
        rest,
        'api-key',
        _preauthenticatedRequest(),
        secretKey: _secretKey(),
        rpcClient: _rpcClient(),
        client: _checkoutClient(),
        pollTimeout: const Duration(milliseconds: 10),
        pollInterval: const Duration(milliseconds: 1),
      );
      expect(result, isA<SignupAndPayPendingResult>());
      final pending = result as SignupAndPayPendingResult;
      expect(pending.paymentLink.paymentIntentId, 'pi-1');
      expect(pending.txSignature, 'sig123');
    });
  });

  group('AuthClient', () {
    test('signup delegates to authSignup', () async {
      final client = AuthClient(
        restClient: _restClient(),
        apiKey: 'api-key',
        client: _checkoutClient(projects: () => [_project('p-1')]),
      );
      final result = await client.signup(
        _preauthenticatedRequest(plan: 'agent'),
      );
      expect(result, isA<AlreadySubscribedResult>());
    });
  });

  group('helpers', () {
    test('PaymentLink round-trips through fromJson and toJson', () {
      const link = PaymentLink(
        kind: 'payment_required',
        paymentIntentId: 'pi-1',
        amountCents: 5000,
        destinationWallet: '11111111111111111111111111111111',
        memo: 'pi-1',
        expiresAt: '2026-01-01',
        paymentUrl: 'https://dashboard.helius.dev/pay/pi-1',
        solanaPayUrl: 'solana:pi-1',
        planName: 'Developer (Monthly)',
      );
      final decoded = PaymentLink.fromJson(link.toJson());
      expect(decoded.paymentIntentId, 'pi-1');
      expect(decoded.amountCents, 5000);
      expect(decoded.planName, 'Developer (Monthly)');
    });

    test('buildEndpoints builds mainnet and devnet URLs', () {
      final endpoints = buildEndpoints('abc');
      expect(endpoints.mainnet, 'https://mainnet.helius-rpc.com/?api-key=abc');
      expect(endpoints.devnet, 'https://devnet.helius-rpc.com/?api-key=abc');
    });

    test('minSolForTx is one million lamports', () {
      expect(minSolForTx, BigInt.from(1000000));
    });

    test('buildAndSendTokenTransfer requires an RPC client', () {
      expect(
        () => buildAndSendTokenTransfer(
          TokenTransferParams(
            secretKey: _secretKey(),
            recipientAddress: '11111111111111111111111111111111',
            mintAddress: '11111111111111111111111111111111',
            amount: BigInt.one,
          ),
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
