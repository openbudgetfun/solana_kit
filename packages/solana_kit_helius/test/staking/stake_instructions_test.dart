import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('StakingClient.getStakeInstructions', () {
    test('sends POST to /v0/staking/instructions and returns map', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/v0/staking/instructions');
        expect(request.url.queryParameters['api-key'], isNotEmpty);
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['from'], 'owner-address');
        expect(body['amount'], 1000000);
        return http.Response(
          jsonEncode(<String, Object?>{
            'stakeInstruction': 'encoded-instruction',
            'accounts': <Object?>['acc1', 'acc2'],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final instructions = await helius.staking.getStakeInstructions(
        CreateStakeTransactionRequest(from: 'owner-address', amount: 1000000),
      );

      expect(instructions, isA<Map<String, Object?>>());
      expect(instructions['stakeInstruction'], 'encoded-instruction');
      expect(instructions['accounts'], isA<List<Object?>>());
    });

    test('throws on HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.staking.getStakeInstructions(
          CreateStakeTransactionRequest(from: 'owner', amount: 100),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
