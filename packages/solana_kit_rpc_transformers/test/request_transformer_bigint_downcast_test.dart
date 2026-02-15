import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';
import 'package:test/test.dart';

void main() {
  group('bigint downcast visitor', () {
    test('returns int values as-is', () {
      final transformer = getBigIntDowncastRequestTransformer();
      const request = RpcRequest<Object?>(methodName: 'getFoo', params: 10);
      expect(transformer(request).params, equals(10));
    });

    test('returns string values as-is', () {
      final transformer = getBigIntDowncastRequestTransformer();
      const request = RpcRequest<Object?>(methodName: 'getFoo', params: '10');
      expect(transformer(request).params, equals('10'));
    });

    test('returns null values as-is', () {
      final transformer = getBigIntDowncastRequestTransformer();
      const request = RpcRequest<Object?>(methodName: 'getFoo', params: null);
      expect(transformer(request).params, isNull);
    });

    group('given a BigInt as input', () {
      test('casts the input to an int', () {
        final transformer = getBigIntDowncastRequestTransformer();
        final input = BigInt.from(10);
        final request = RpcRequest<Object?>(
          methodName: 'getFoo',
          params: input,
        );
        expect(transformer(request).params, equals(10));
      });
    });

    group('given a BigInt larger than MAX_SAFE_INTEGER as input', () {
      test('casts the input to an int (with potential precision loss)', () {
        final transformer = getBigIntDowncastRequestTransformer();
        // 9007199254740993
        final input = BigInt.from(9007199254740991) + BigInt.two;
        final request = RpcRequest<Object?>(
          methodName: 'getFoo',
          params: input,
        );
        // In Dart VM, int is 64-bit, so this actually works without precision
        // loss (unlike JavaScript).
        expect(transformer(request).params, equals(input.toInt()));
      });
    });

    test('recursively downcasts BigInts in arrays', () {
      final transformer = getBigIntDowncastRequestTransformer();
      final request = RpcRequest<Object?>(
        methodName: 'getFoo',
        params: [
          BigInt.from(10),
          10,
          '10',
          [
            '10',
            [10, BigInt.from(10)],
            BigInt.from(10),
          ],
        ],
      );
      expect(transformer(request).params, [
        10,
        10,
        '10',
        [
          '10',
          [10, 10],
          10,
        ],
      ]);
    });

    test('recursively downcasts BigInts in objects', () {
      final transformer = getBigIntDowncastRequestTransformer();
      final request = RpcRequest<Object?>(
        methodName: 'getFoo',
        params: {
          'a': BigInt.from(10),
          'b': 10,
          'c': {'c1': '10', 'c2': BigInt.from(10)},
        },
      );
      expect(transformer(request).params, {
        'a': 10,
        'b': 10,
        'c': {'c1': '10', 'c2': 10},
      });
    });
  });
}
