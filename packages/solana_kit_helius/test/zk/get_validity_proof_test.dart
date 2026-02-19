import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('ZkClient.getValidityProof', () {
    test('sends correct request and deserializes response', () async {
      final mockResult = <String, Object?>{
        'compressedProof': <Object?>['p1'],
      };

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getValidityProof');
        expect(body['jsonrpc'], '2.0');
        expect(body['params'], {
          'hashes': ['h1'],
        });
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResult}),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final result = await helius.zk.getValidityProof(
        GetValidityProofRequest(hashes: ['h1']),
      );

      expect(result.compressedProof, ['p1']);
    });
  });
}
