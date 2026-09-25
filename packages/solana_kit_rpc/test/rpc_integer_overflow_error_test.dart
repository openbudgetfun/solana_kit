import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
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
        2,
      ], BigInt.one);
      expect(error.code, SolanaErrorCode.rpcIntegerOverflow);
    });

    test('creates a SolanaError with the correct context for a path-less '
        'violation', () {
      final error = createSolanaJsonRpcIntegerOverflowError('someMethod', [
        2 /* third argument */,
      ], BigInt.one);
      expect(error.context['argumentLabel'], '3rd');
      expect(error.context['keyPath'], [2]);
      expect(error.context['methodName'], 'someMethod');
      expect(error.context['optionalPathLabel'], '');
      expect(error.context['value'], BigInt.one);
      expect(error.context.containsKey('path'), isFalse);
    });

    test('creates a SolanaError with the correct context for a violation '
        'with a deep path', () {
      final error = createSolanaJsonRpcIntegerOverflowError('someMethod', [
        0 /* first argument */,
        'foo',
        'bar',
      ], BigInt.one);
      expect(error.context['optionalPathLabel'], ' at path `foo.bar`');
      expect(error.context['path'], 'foo.bar');
    });

    test('creates a SolanaError with the correct context for a string '
        'key path', () {
      final error = createSolanaJsonRpcIntegerOverflowError('someMethod', [
        'myKey',
      ], BigInt.one);
      expect(error.context['argumentLabel'], '`myKey`');
    });

    group('ordinal suffixes', () {
      // Generate expected ordinals for 0..99 (argument index 0 = "1st", etc.)
      final expectedOrdinals = <int, String>{};
      for (var ii = 0; ii < 100; ii++) {
        final pos = ii + 1;
        final lastDigit = pos % 10;
        if (lastDigit == 1) {
          expectedOrdinals[ii] = '${pos}st';
        } else if (lastDigit == 2) {
          expectedOrdinals[ii] = '${pos}nd';
        } else if (lastDigit == 3) {
          expectedOrdinals[ii] = '${pos}rd';
        } else {
          expectedOrdinals[ii] = '${pos}th';
        }
      }
      // Override the special cases for 11th, 12th, 13th
      expectedOrdinals[10] = '11th';
      expectedOrdinals[11] = '12th';
      expectedOrdinals[12] = '13th';

      for (final entry in expectedOrdinals.entries) {
        test('computes the correct ordinal for index ${entry.key} '
            '(${entry.value})', () {
          final error = createSolanaJsonRpcIntegerOverflowError('someMethod', [
            entry.key,
          ], BigInt.one);
          expect(error.context['argumentLabel'], entry.value);
        });
      }
    });
  });
}
