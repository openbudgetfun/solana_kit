import 'dart:typed_data';

import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

void main() {
  group('equalsBytes', () {
    test('matches identical byte arrays', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      expect(bytes, equalsBytes(Uint8List.fromList([1, 2, 3])));
    });

    test('does not match different byte arrays', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      expect(bytes, isNot(equalsBytes(Uint8List.fromList([1, 2, 4]))));
    });

    test('does not match byte arrays of different lengths', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      expect(bytes, isNot(equalsBytes(Uint8List.fromList([1, 2]))));
    });

    test('does not match non-Uint8List objects', () {
      expect('not bytes', isNot(equalsBytes(Uint8List(0))));
    });

    test('matches empty byte arrays', () {
      expect(Uint8List(0), equalsBytes(Uint8List(0)));
    });
  });

  group('hasByteLength', () {
    test('matches when byte array has correct length', () {
      expect(Uint8List(32), hasByteLength(32));
    });

    test('does not match when length differs', () {
      expect(Uint8List(32), isNot(hasByteLength(64)));
    });
  });

  group('startsWithBytes', () {
    test('matches when byte array starts with prefix', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      expect(bytes, startsWithBytes(Uint8List.fromList([1, 2, 3])));
    });

    test('does not match when prefix differs', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      expect(bytes, isNot(startsWithBytes(Uint8List.fromList([1, 3]))));
    });

    test('does not match when byte array is shorter than prefix', () {
      final bytes = Uint8List.fromList([1, 2]);
      expect(bytes, isNot(startsWithBytes(Uint8List.fromList([1, 2, 3]))));
    });

    test('matches empty prefix', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      expect(bytes, startsWithBytes(Uint8List(0)));
    });
  });
}
