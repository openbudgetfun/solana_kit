import 'package:solana_kit_functional/solana_kit_functional.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  group('standalone pipe', () {
    test('returns the initial value when there are no transforms', () {
      expect(pipe(true), isTrue);
      expect(pipe('test'), equals('test'));
      expect(pipe(1), equals(1));
      expect(pipe(null), isNull);
    });

    test('applies a single transform', () {
      expect(
        pipe('test', [(value) => (value! as String).toUpperCase()]),
        equals('TEST'),
      );
    });

    test('applies multiple transforms in order', () {
      expect(
        pipe('test', [
          (value) => (value! as String).toUpperCase(),
          (value) => '$value!',
          (value) => '$value$value$value',
        ]),
        equals('TEST!TEST!TEST!'),
      );
      expect(
        pipe(1, [
          (value) => (value! as int) + 1,
          (value) => (value! as int) + 2,
          (value) => (value! as int) + 3,
        ]),
        equals(7),
      );
    });

    test('threads a value through transforms that change its type', () {
      expect(
        pipe(2, [
          (value) => (value! as int) * 3,
          (value) => 'value=$value',
        ]),
        equals('value=6'),
      );
    });

    test('accepts a list literal of transforms', () {
      expect(
        pipe(10, [(v) => (v! as int) + 5, (v) => (v! as int) * 2]),
        equals(30),
      );
    });
  });

  group('method-chaining pipe extension', () {
    test('is available alongside the standalone form', () {
      expect('test'.pipe((value) => value.toUpperCase()), equals('TEST'));
    });
  });
}
