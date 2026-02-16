import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:test/test.dart';

void main() {
  group('createSolanaJsonRpcIntegerOverflowError()', () {
    test('creates a SolanaError', () {
      final error = createSolanaJsonRpcIntegerOverflowError('someMethod', [
        2 /* third argument */,
      ], BigInt.one);
      expect(error, isA<SolanaError>());
    });

    test('creates a SolanaError with the code rpcIntegerOverflow', () {
      final error = createSolanaJsonRpcIntegerOverflowError('someMethod', [
        2 /* third argument */,
      ], BigInt.one);
      expect(error.code, equals(SolanaErrorCode.rpcIntegerOverflow));
    });

    test('creates a SolanaError with the correct context for a path-less '
        'violation', () {
      final error = createSolanaJsonRpcIntegerOverflowError('someMethod', [
        2 /* third argument */,
      ], BigInt.one);
      expect(error.code, equals(SolanaErrorCode.rpcIntegerOverflow));
      expect(error.context['argumentLabel'], equals('3rd'));
      expect(error.context['keyPath'], equals([2]));
      expect(error.context['methodName'], equals('someMethod'));
      expect(error.context['optionalPathLabel'], equals(''));
      expect(error.context['value'], equals(BigInt.one));
      expect(error.context.containsKey('path'), isFalse);
    });

    test(
      'creates a SolanaError with the correct context for a violation with a '
      'deep path',
      () {
        final error = createSolanaJsonRpcIntegerOverflowError('someMethod', [
          0 /* first argument */,
          'foo',
          'bar',
        ], BigInt.one);
        expect(
          error.context['optionalPathLabel'],
          equals(' at path `foo.bar`'),
        );
        expect(error.context['path'], equals('foo.bar'));
      },
    );

    group('computes the correct ordinal for the argument label', () {
      final testCases = <int, String>{};

      for (var ii = 0; ii < 100; ii++) {
        final argPosition = ii + 1;
        final lastDigit = ii % 10;

        if (lastDigit == 0) {
          testCases[ii] = '${argPosition}st';
        } else if (lastDigit == 1) {
          testCases[ii] = '${argPosition}nd';
        } else if (lastDigit == 2) {
          testCases[ii] = '${argPosition}rd';
        } else {
          testCases[ii] = '${argPosition}th';
        }
      }

      // Override the special teen cases.
      testCases[10] = '11th';
      testCases[11] = '12th';
      testCases[12] = '13th';

      for (final entry in testCases.entries) {
        test('index ${entry.key} -> ${entry.value}', () {
          final error = createSolanaJsonRpcIntegerOverflowError('someMethod', [
            entry.key,
          ], BigInt.one);
          expect(error.context['argumentLabel'], equals(entry.value));
        });
      }
    });

    test('uses backtick label for string key path entries', () {
      final error = createSolanaJsonRpcIntegerOverflowError('someMethod', [
        'namedParam',
      ], BigInt.one);
      expect(error.context['argumentLabel'], equals('`namedParam`'));
    });

    test('includes array indices in path with brackets', () {
      final error = createSolanaJsonRpcIntegerOverflowError('someMethod', [
        0,
        'foo',
        1,
        'bar',
      ], BigInt.one);
      expect(error.context['path'], equals('foo.[1].bar'));
    });
  });
}
