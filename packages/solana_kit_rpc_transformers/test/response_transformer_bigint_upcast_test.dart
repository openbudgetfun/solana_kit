import 'package:solana_kit_rpc_transformers/src/response_transformer_bigint_upcast_internal.dart';
import 'package:solana_kit_rpc_transformers/src/tree_traversal.dart';
import 'package:test/test.dart';

const _mockTraversalState = TraversalState(keyPath: []);

void main() {
  group('bigint upcast visitor', () {
    group('given no allowed numeric keypaths', () {
      late NodeVisitor visitNode;

      setUp(() {
        visitNode = getBigIntUpcastVisitor([]);
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

      group('given an int as input', () {
        test('casts the input to a BigInt', () {
          expect(visitNode(10, _mockTraversalState), equals(BigInt.from(10)));
        });
      });

      group('given a non-integer double as input', () {
        test('returns the value as-is', () {
          expect(visitNode(10.5, _mockTraversalState), equals(10.5));
        });
      });
    });

    group('given an allowed numeric keypath', () {
      late NodeVisitor visitNode;

      setUp(() {
        visitNode = getBigIntUpcastVisitor([
          [0, 1, 2],
        ]);
      });

      test('casts the input to a BigInt when the key path does not match', () {
        expect(
          visitNode(10, const TraversalState(keyPath: [0, 1, 3])),
          equals(BigInt.from(10)),
        );
      });

      test('does not cast the input to a BigInt when the key path matches', () {
        expect(
          visitNode(10, const TraversalState(keyPath: [0, 1, 2])),
          equals(10),
        );
      });
    });
  });
}
