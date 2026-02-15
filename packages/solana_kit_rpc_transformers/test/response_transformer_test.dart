import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';
import 'package:test/test.dart';

void main() {
  group('getDefaultResponseTransformerForSolanaRpc', () {
    group('given an array as input', () {
      test('casts the numbers in the array to BigInt, recursively', () {
        final input = [
          10,
          BigInt.from(10),
          '10',
          [
            '10',
            [BigInt.from(10), 10],
            10,
          ],
        ];
        const request = RpcRequest<Object?>(methodName: '', params: null);
        final response = <String, Object?>{'result': input};
        final transformer = getDefaultResponseTransformerForSolanaRpc();
        expect(transformer(response, request), [
          BigInt.from(10),
          BigInt.from(10),
          '10',
          [
            '10',
            [BigInt.from(10), BigInt.from(10)],
            BigInt.from(10),
          ],
        ]);
      });
    });

    group('given an object as input', () {
      test('casts the numbers in the object to BigInts, recursively', () {
        final input = {
          'a': 10,
          'b': BigInt.from(10),
          'c': {'c1': '10', 'c2': 10},
        };
        const request = RpcRequest<Object?>(methodName: '', params: null);
        final response = <String, Object?>{'result': input};
        final transformer = getDefaultResponseTransformerForSolanaRpc();
        expect(transformer(response, request), {
          'a': BigInt.from(10),
          'b': BigInt.from(10),
          'c': {'c1': '10', 'c2': BigInt.from(10)},
        });
      });
    });

    group('where allowlisted numeric values are concerned', () {
      test('nested array of numeric responses', () {
        final transformer = getDefaultResponseTransformerForSolanaRpc(
          const ResponseTransformerConfig(
            allowedNumericKeyPaths: {
              'getFoo': [
                [0],
                [1, 1],
                [1, 2, 1],
              ],
            },
          ),
        );
        const request = RpcRequest<Object?>(methodName: 'getFoo', params: null);
        final response = <String, Object?>{
          'result': [
            10,
            [
              10,
              10,
              [10, 10],
            ],
          ],
        };
        expect(transformer(response, request), [
          10,
          [
            BigInt.from(10),
            10,
            [BigInt.from(10), 10],
          ],
        ]);
      });

      test('nested array of numeric responses with wildcard', () {
        final transformer = getDefaultResponseTransformerForSolanaRpc(
          const ResponseTransformerConfig(
            allowedNumericKeyPaths: {
              'getFoo': [
                [KEYPATH_WILDCARD],
                [2, KEYPATH_WILDCARD],
              ],
            },
          ),
        );
        const request = RpcRequest<Object?>(methodName: 'getFoo', params: null);
        final response = <String, Object?>{
          'result': [
            1,
            [2],
            [3, 33, 333],
            4,
          ],
        };
        expect(transformer(response, request), [
          1,
          [BigInt.from(2)],
          [3, 33, 333],
          4,
        ]);
      });

      test('nested array of objects with numeric responses', () {
        final transformer = getDefaultResponseTransformerForSolanaRpc(
          const ResponseTransformerConfig(
            allowedNumericKeyPaths: {
              'getFoo': [
                ['a', 'b', KEYPATH_WILDCARD, 'c'],
              ],
            },
          ),
        );
        const request = RpcRequest<Object?>(methodName: 'getFoo', params: null);
        final response = <String, Object?>{
          'result': {
            'a': {
              'b': [
                {'c': 5, 'd': 5},
                {'c': 10, 'd': 10},
              ],
            },
          },
        };
        expect(transformer(response, request), {
          'a': {
            'b': [
              {'c': 5, 'd': BigInt.from(5)},
              {'c': 10, 'd': BigInt.from(10)},
            ],
          },
        });
      });

      test('nested object of numeric responses', () {
        final transformer = getDefaultResponseTransformerForSolanaRpc(
          const ResponseTransformerConfig(
            allowedNumericKeyPaths: {
              'getFoo': [
                ['a'],
                ['b', 'b2', 'b2_1'],
                ['b', 'b2', 'b2_3'],
              ],
            },
          ),
        );
        const request = RpcRequest<Object?>(methodName: 'getFoo', params: null);
        final response = <String, Object?>{
          'result': {
            'a': 10,
            'b': {
              'b1': 10,
              'b2': {'b2_1': 10, 'b2_2': 10, 'b2_3': 10},
            },
          },
        };
        expect(transformer(response, request), {
          'a': 10,
          'b': {
            'b1': BigInt.from(10),
            'b2': {'b2_1': 10, 'b2_2': BigInt.from(10), 'b2_3': 10},
          },
        });
      });

      test('numeric response at root', () {
        final transformer = getDefaultResponseTransformerForSolanaRpc(
          const ResponseTransformerConfig(
            allowedNumericKeyPaths: {
              'getFoo': [<Object>[]],
            },
          ),
        );
        const request = RpcRequest<Object?>(methodName: 'getFoo', params: null);
        final response = <String, Object?>{'result': 10};
        expect(transformer(response, request), 10);
      });
    });

    group('given a JSON RPC error as input', () {
      test('throws it as a SolanaError', () {
        const request = RpcRequest<Object?>(methodName: '', params: null);
        final response = <String, Object?>{
          'error': {
            'code': SolanaErrorCode.jsonRpcParseError,
            'message': 'o no',
          },
        };
        final transformer = getDefaultResponseTransformerForSolanaRpc();

        try {
          transformer(response, request);
          fail('Expected SolanaError to be thrown');
        } on SolanaError catch (e) {
          expect(e.code, SolanaErrorCode.jsonRpcParseError);
        }
      });
    });
  });

  group('getDefaultResponseTransformerForSolanaRpcSubscriptions', () {
    test('upcasts integers to BigInt', () {
      final transformer =
          getDefaultResponseTransformerForSolanaRpcSubscriptions();
      const request = RpcRequest<Object?>(methodName: '', params: null);
      final response = {
        'value': 42,
        'context': {'slot': 100},
      };
      final result = transformer(response, request)! as Map<String, Object?>;
      expect(result['value'], BigInt.from(42));
      final context = result['context']! as Map<String, Object?>;
      expect(context['slot'], BigInt.from(100));
    });

    test('respects allowed numeric key paths', () {
      final transformer =
          getDefaultResponseTransformerForSolanaRpcSubscriptions(
            const ResponseTransformerConfig(
              allowedNumericKeyPaths: {
                'getFoo': [
                  ['value'],
                ],
              },
            ),
          );
      const request = RpcRequest<Object?>(methodName: 'getFoo', params: null);
      final response = {'value': 42, 'slot': 100};
      final result = transformer(response, request)! as Map<String, Object?>;
      expect(result['value'], 42); // stays as int
      expect(result['slot'], BigInt.from(100)); // upcasted to BigInt
    });
  });
}
