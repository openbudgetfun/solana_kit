import 'package:solana_kit_rpc_transformers/src/request_transformer_integer_overflow_internal.dart';
import 'package:solana_kit_rpc_transformers/src/tree_traversal.dart';
import 'package:test/test.dart';

const _maxSafeInteger = 9007199254740991; // 2^53 - 1

const _mockTraversalState = TraversalState(keyPath: [1, 'foo', 'bar']);

void main() {
  group('integer overflow visitor', () {
    late List<(KeyPath, BigInt)> overflowCalls;
    late NodeVisitor visitNode;

    setUp(() {
      overflowCalls = [];
      visitNode = getIntegerOverflowNodeVisitor((keyPath, value) {
        overflowCalls.add((keyPath, value));
      });
    });

    test('returns int values as-is', () {
      expect(visitNode(10, _mockTraversalState), equals(10));
    });

    test('returns BigInt values as-is', () {
      final value = BigInt.from(10);
      expect(visitNode(value, _mockTraversalState), equals(value));
    });

    test('returns string values as-is', () {
      expect(visitNode('10', _mockTraversalState), equals('10'));
    });

    test('returns null values as-is', () {
      expect(visitNode(null, _mockTraversalState), isNull);
    });

    group('when passed a value above MAX_SAFE_INTEGER', () {
      final value = BigInt.from(_maxSafeInteger) + BigInt.one;

      test('calls onIntegerOverflow with the key path and value', () {
        visitNode(value, _mockTraversalState);
        expect(overflowCalls, hasLength(1));
        expect(overflowCalls[0].$1, _mockTraversalState.keyPath);
        expect(overflowCalls[0].$2, value);
      });
    });

    group('when passed a value below negative MAX_SAFE_INTEGER', () {
      final value = BigInt.from(-_maxSafeInteger) - BigInt.one;

      test('calls onIntegerOverflow with the key path and value', () {
        visitNode(value, _mockTraversalState);
        expect(overflowCalls, hasLength(1));
        expect(overflowCalls[0].$1, _mockTraversalState.keyPath);
        expect(overflowCalls[0].$2, value);
      });
    });

    test('does not call onIntegerOverflow when passed MAX_SAFE_INTEGER', () {
      visitNode(BigInt.from(_maxSafeInteger), _mockTraversalState);
      expect(overflowCalls, isEmpty);
    });
  });
}
