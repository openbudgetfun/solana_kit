import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:test/test.dart';

void main() {
  group('walletGetBalanceAt', () {
    test('sends a GET with mint and time and parses the response', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/v0/addresses/abc123/balance-at');
        expect(request.url.queryParameters['api-key'], 'test-key');
        expect(request.url.queryParameters['mint'], 'mint-xyz');
        expect(request.url.queryParameters['time'], '1736548800');
        expect(request.url.queryParameters.containsKey('slot'), isFalse);
        return http.Response(
          jsonEncode(<String, Object?>{
            'wallet': 'abc123',
            'mint': 'mint-xyz',
            'isNative': false,
            'balance': '123.45',
            'balanceRaw': '12345000000',
            'decimals': 8,
            'requested': {
              'time': 1736548800,
              'slot': null,
              'datetime': null,
            },
            'asOf': {
              'slot': 300000001,
              'blockTime': 1736548800,
              'signature': 'sig1',
            },
          }),
          200,
        );
      });

      final result = await walletGetBalanceAt(
        RestClient(baseUrl: 'https://api.helius-rpc.com', client: client),
        'test-key',
        const GetBalanceAtRequest(
          wallet: 'abc123',
          mint: 'mint-xyz',
          time: 1736548800,
        ),
      );

      expect(result.wallet, 'abc123');
      expect(result.mint, 'mint-xyz');
      expect(result.isNative, isFalse);
      expect(result.balance, '123.45');
      expect(result.balanceRaw, '12345000000');
      expect(result.decimals, 8);
      expect(result.requested.time, 1736548800);
      expect(result.asOf!.slot, 300000001);
      expect(result.asOf!.signature, 'sig1');

      final json = result.toJson();
      expect(json['wallet'], 'abc123');
      expect(json['asOf'], {
        'slot': 300000001,
        'blockTime': 1736548800,
        'signature': 'sig1',
      });
      expect(json['requested'], {'time': 1736548800});
    });

    test('serializes exactly one of time/datetime/slot', () async {
      final client = MockClient((request) async {
        expect(request.url.queryParameters['datetime'], '2025-01-10 19:20:00');
        expect(request.url.queryParameters.containsKey('time'), isFalse);
        expect(request.url.queryParameters.containsKey('slot'), isFalse);
        return http.Response(
          jsonEncode(<String, Object?>{
            'wallet': 'abc123',
            'mint': 'mint-xyz',
            'isNative': false,
            'balance': '0',
            'balanceRaw': '0',
            'decimals': 8,
            'requested': {
              'time': 1736548800,
              'slot': null,
              'datetime': '2025-01-10 19:20:00',
            },
            'asOf': null,
          }),
          200,
        );
      });

      final result = await walletGetBalanceAt(
        RestClient(baseUrl: 'https://api.helius-rpc.com', client: client),
        'test-key',
        const GetBalanceAtRequest(
          wallet: 'abc123',
          mint: 'mint-xyz',
          datetime: '2025-01-10 19:20:00',
        ),
      );

      expect(result.asOf, isNull);
      expect(result.requested.datetime, '2025-01-10 19:20:00');

      final json = result.toJson();
      expect(json['asOf'], isNull);
      expect(json['requested'], {
        'time': 1736548800,
        'datetime': '2025-01-10 19:20:00',
      });
    });

    test('round-trips through the request type', () {
      const request = GetBalanceAtRequest(
        wallet: 'abc123',
        mint: 'mint-xyz',
        slot: 300000001,
      );
      final json = request.toJson();
      expect(json['wallet'], 'abc123');
      expect(json['slot'], 300000001);
      final restored = GetBalanceAtRequest.fromJson(json);
      expect(restored.slot, 300000001);
      expect(restored.time, isNull);
    });

    test('round-trips a slot-based response', () {
      final response = GetBalanceAtResponse.fromJson(<String, Object?>{
        'wallet': 'abc123',
        'mint': 'mint-xyz',
        'isNative': true,
        'balance': '0.000000001',
        'balanceRaw': '1',
        'decimals': 9,
        'requested': <String, Object?>{
          'time': null,
          'slot': 300000001,
          'datetime': null,
        },
        'asOf': null,
      });
      expect(response.asOf, isNull);
      expect(response.isNative, isTrue);

      final json = response.toJson();
      expect(json['requested'], {'slot': 300000001});
      expect(json['balanceRaw'], '1');
    });

    test('exposes getBalanceAt through the wallet client', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/v0/addresses/abc123/balance-at');
        expect(request.url.queryParameters['api-key'], 'test-key');
        expect(request.url.queryParameters['mint'], 'mint-xyz');
        expect(request.url.queryParameters['slot'], '300000001');
        return http.Response(
          jsonEncode(<String, Object?>{
            'wallet': 'abc123',
            'mint': 'mint-xyz',
            'isNative': false,
            'balance': '0',
            'balanceRaw': '0',
            'decimals': 8,
            'requested': <String, Object?>{
              'time': null,
              'slot': 300000001,
              'datetime': null,
            },
            'asOf': null,
          }),
          200,
        );
      });

      final wallet = WalletClient(
        restClient: RestClient(
          baseUrl: 'https://api.helius-rpc.com',
          client: client,
        ),
        apiKey: 'test-key',
      );
      final result = await wallet.getBalanceAt(
        const GetBalanceAtRequest(
          wallet: 'abc123',
          mint: 'mint-xyz',
          slot: 300000001,
        ),
      );
      expect(result.wallet, 'abc123');
      expect(result.requested.slot, 300000001);
    });
  });
}
