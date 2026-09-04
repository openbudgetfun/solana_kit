import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_surfpool/src/errors.dart';
import 'package:solana_kit_surfpool/src/internal/json_rpc_client.dart';
import 'package:test/test.dart';

void main() {
  group('Surfpool response integrity', () {
    final invalidEnvelopes = <String, Map<String, Object?>>{
      'another request id': {'jsonrpc': '2.0', 'id': 2, 'result': null},
      'a string id': {'jsonrpc': '2.0', 'id': '1', 'result': null},
      'a missing id': {'jsonrpc': '2.0', 'result': null},
      'a null id': {'jsonrpc': '2.0', 'id': null, 'result': null},
      'a missing version': {'id': 1, 'result': null},
      'an unsupported version': {'jsonrpc': '1.0', 'id': 1, 'result': null},
      'a missing result': {'jsonrpc': '2.0', 'id': 1},
      'a null error': {'jsonrpc': '2.0', 'id': 1, 'error': null},
      'both result and error': {
        'jsonrpc': '2.0',
        'id': 1,
        'result': null,
        'error': null,
      },
    };

    for (final entry in invalidEnvelopes.entries) {
      test('rejects ${entry.key} instead of confirming a mutation', () async {
        final client = SurfpoolJsonRpcClient(
          url: Uri.parse('http://127.0.0.1:8899'),
          client: MockClient(
            (_) async => http.Response(jsonEncode(entry.value), 200),
          ),
        );

        await expectLater(
          client.call('surfnet_setAccount'),
          throwsA(isA<SurfpoolRpcException>()),
        );
      });
    }

    test('accepts a correlated mutation response with a null result', () async {
      final client = SurfpoolJsonRpcClient(
        url: Uri.parse('http://127.0.0.1:8899'),
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': null}),
            200,
          ),
        ),
      );

      expect(await client.call('surfnet_setAccount'), isNull);
    });
  });
}
