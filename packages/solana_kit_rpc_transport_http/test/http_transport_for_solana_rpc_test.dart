import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';
import 'package:test/test.dart';

void main() {
  group('createHttpTransportForSolanaRpc', () {
    group('when the request is from the Solana RPC API', () {
      test(
        'passes all BigInts as large numerical values in the request body',
        () async {
          late http.Request capturedRequest;
          final mockClient = MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              '{"ok":true}',
              200,
              headers: {'content-type': 'application/json'},
            );
          });

          final transport = createHttpTransportForSolanaRpc(
            url: 'http://localhost',
            client: mockClient,
          );

          final maxSafeInteger = BigInt.from(9007199254740991);
          final maxSafeIntegerPlusOne = maxSafeInteger + BigInt.one;

          await transport(
            RpcTransportConfig(
              payload: <String, Object?>{
                'jsonrpc': '2.0',
                'method': 'getBalance',
                'params': <String, Object?>{
                  'numbersInString': 'He said: "1, 2, 3, Soleil!"',
                  'safeNumber': maxSafeInteger,
                  'unsafeNumber': maxSafeIntegerPlusOne,
                },
              },
            ),
          );

          // BigInts should be serialized as raw numeric values, not quoted strings
          expect(
            capturedRequest.body,
            contains('"safeNumber":$maxSafeInteger'),
          );
          expect(
            capturedRequest.body,
            contains('"unsafeNumber":$maxSafeIntegerPlusOne'),
          );
          // Strings with numbers should remain as strings
          expect(
            capturedRequest.body,
            contains(r'"numbersInString":"He said: \"1, 2, 3, Soleil!\""'),
          );
        },
      );

      test('gets all integers as BigInts within the response', () async {
        final maxSafeInteger = BigInt.from(9007199254740991);
        final maxSafeIntegerPlusOne = maxSafeInteger + BigInt.one;

        final mockClient = MockClient(
          (request) async => http.Response(
            '{"safeNumber": $maxSafeInteger, '
            '"unsafeNumber": $maxSafeIntegerPlusOne, '
            r'"numbersInString": "He said: \"1, 2, 3, Soleil!\""}',
            200,
            headers: {'content-type': 'application/json'},
          ),
        );

        final transport = createHttpTransportForSolanaRpc(
          url: 'http://localhost',
          client: mockClient,
        );

        final result = await transport(
          const RpcTransportConfig(
            payload: <String, Object?>{
              'jsonrpc': '2.0',
              'method': 'getBalance',
              'params': <Object?>['1234..5678'],
            },
          ),
        );

        final resultMap = result! as Map<String, Object?>;
        expect(resultMap['safeNumber'], maxSafeInteger);
        expect(resultMap['unsafeNumber'], maxSafeIntegerPlusOne);
        expect(resultMap['numbersInString'], 'He said: "1, 2, 3, Soleil!"');
      });
    });

    group('when the request is not from the Solana RPC API', () {
      test('uses standard JSON encoding (BigInts will throw)', () async {
        final mockClient = MockClient(
          (request) async => http.Response(
            '{"ok":true}',
            200,
            headers: {'content-type': 'application/json'},
          ),
        );

        final transport = createHttpTransportForSolanaRpc(
          url: 'http://localhost',
          client: mockClient,
        );

        final maxSafeIntegerPlusOne =
            BigInt.from(9007199254740991) + BigInt.one;

        // Standard jsonEncode cannot serialize BigInt values, so this should
        // throw a JsonUnsupportedObjectError.
        expect(
          () => transport(
            RpcTransportConfig(
              payload: <String, Object?>{
                'jsonrpc': '2.0',
                'method': 'getAssetsByOwner',
                'params': <Object?>[maxSafeIntegerPlusOne],
              },
            ),
          ),
          throwsA(isA<JsonUnsupportedObjectError>()),
        );
      });

      test('uses standard JSON decoding for responses', () async {
        final maxSafeInteger = BigInt.from(9007199254740991);

        final mockClient = MockClient(
          (request) async => http.Response(
            '{"safeNumber": $maxSafeInteger, '
            r'"numbersInString": "He said: \"1, 2, 3, Soleil!\""}',
            200,
            headers: {'content-type': 'application/json'},
          ),
        );

        final transport = createHttpTransportForSolanaRpc(
          url: 'http://localhost',
          client: mockClient,
        );

        final result = await transport(
          const RpcTransportConfig(
            payload: <String, Object?>{
              'jsonrpc': '2.0',
              'method': 'getAssetsByOwner',
              'params': <Object?>['1234..5678'],
            },
          ),
        );

        final resultMap = result! as Map<String, Object?>;
        // Standard jsonDecode returns numbers as num (int or double), not BigInt
        expect(resultMap['safeNumber'], isA<num>());
        expect(resultMap['numbersInString'], 'He said: "1, 2, 3, Soleil!"');
      });
    });
  });
}
