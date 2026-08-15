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
  return Uint8List.fromList([...keyPair.privateKey, ...keyPair.publicKey]);
}

http.Client _rpcAndSenderClient() {
  return MockClient((request) async {
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
        jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'result': 'sig123',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    return http.Response('{"error":"unknown"}', 500);
  });
}

Map<String, Object?> _devPortalConfigs() => {
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
};

http.Client _restClient() {
  return MockClient((request) async {
    if (request.url.path.endsWith('/dev-portal/configs')) {
      return http.Response(
        jsonEncode(_devPortalConfigs()),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    if (request.url.path.contains('/checkout/preview')) {
      return http.Response(
        jsonEncode({'dueToday': 5000}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    if (request.url.path.contains('/checkout/initialize')) {
      return http.Response(
        jsonEncode({
          'id': 'pi-upgrade',
          'status': 'pending',
          'destinationWallet': '11111111111111111111111111111111',
          'amount': 5000,
          'solanaPayUrl': 'solana:pi-upgrade',
          'expiresAt': '2026-01-01',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    if (request.url.path.contains('/checkout/')) {
      return http.Response(
        jsonEncode({
          'id': 'pi-renew',
          'status': 'pending',
          'amount': 5000,
          'destinationWallet': '11111111111111111111111111111111',
          'expiresAt': '2026-01-01',
          'solanaPayUrl': 'solana:pi-renew',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    return http.Response(
      jsonEncode({
        'kind': 'payment_required',
        'paymentIntentId': 'pi-upgrade',
        'amountCents': 5000,
        'destinationWallet': '11111111111111111111111111111111',
        'memo': 'pi-upgrade',
        'expiresAt': '2026-01-01',
        'paymentUrl': 'https://dashboard.helius.dev/pay/pi-upgrade',
        'solanaPayUrl': 'solana:pi-upgrade',
        'planName': 'business',
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
}

void main() {
  group('payments', () {
    test('payUSDC sends a transfer to the treasury', () async {
      final client = _rpcAndSenderClient();
      final rpc = JsonRpcClient(url: 'https://rpc', client: client);
      final signature = await payUSDC(
        _secretKey(),
        rpcClient: rpc,
        client: client,
      );
      expect(signature, 'sig123');
    });

    test('payWithMemo includes the memo instruction', () async {
      final client = _rpcAndSenderClient();
      final rpc = JsonRpcClient(url: 'https://rpc', client: client);
      final signature = await payWithMemo(
        _secretKey(),
        '11111111111111111111111111111111',
        BigInt.from(1000000),
        'memo-1',
        rpcClient: rpc,
        client: client,
      );
      expect(signature, 'sig123');
    });

    test('payPaymentLink converts cents to raw USDC', () async {
      final client = _rpcAndSenderClient();
      final rpc = JsonRpcClient(url: 'https://rpc', client: client);
      final link = const PaymentLink(
        kind: 'payment_required',
        paymentIntentId: 'pi-1',
        amountCents: 100,
        destinationWallet: '11111111111111111111111111111111',
        memo: 'pi-1',
        expiresAt: '2026-01-01',
        paymentUrl: 'https://dashboard.helius.dev/pay/pi-1',
        solanaPayUrl: 'solana:pi-1',
        planName: 'developer',
      );
      final signature = await payPaymentLink(
        _secretKey(),
        link,
        rpcClient: rpc,
        client: client,
      );
      expect(signature, 'sig123');
    });
  });

  group('plan management', () {
    test('upgradePlan returns a payment link', () async {
      final client = _restClient();
      final rest = RestClient(
        baseUrl: 'https://dev-api.helius.xyz/v0',
        client: client,
      );
      final result = await upgradePlan(
        rest,
        'api-key',
        jwt: 'jwt',
        projectId: 'p-1',
        plan: 'business',
        client: client,
      );
      expect(result.paymentLink.paymentIntentId, 'pi-upgrade');
    });

    test('payRenewal returns a payment link for a pending intent', () async {
      final client = _restClient();
      final rest = RestClient(
        baseUrl: 'https://dev-api.helius.xyz/v0',
        client: client,
      );
      final result = await payRenewal(
        rest,
        'api-key',
        'jwt',
        'pi-renew',
        client: client,
      );
      expect(result.paymentLink.paymentIntentId, 'pi-renew');
      expect(result.paymentLink.planName, 'Subscription renewal');
    });

    test('payRenewal throws for a non-pending intent', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'id': 'pi-done',
            'status': 'completed',
            'amount': 5000,
            'destinationWallet': '11111111111111111111111111111111',
            'expiresAt': '2026-01-01',
            'solanaPayUrl': 'solana:pi-done',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final rest = RestClient(
        baseUrl: 'https://dev-api.helius.xyz/v0',
        client: client,
      );
      expect(
        () => payRenewal(
          rest,
          'api-key',
          'jwt',
          'pi-done',
          client: client,
        ),
        throwsStateError,
      );
    });
  });
}
