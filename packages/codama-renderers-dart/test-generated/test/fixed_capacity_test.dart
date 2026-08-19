// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';
import 'package:test_generated/src/fixed_capacity/types/fixed_name.dart';
import 'package:test_generated/src/fixed_capacity/types/fixed_values.dart';

void main() {
  group('generated fixed-capacity string encoder', () {
    test('pads under-capacity UTF-8 values', () {
      final encoder = getFixedNameEncoder();

      expect(
        encoder.encode('é'),
        equals(Uint8List.fromList([0xc3, 0xa9, 0, 0])),
      );
    });

    test('preserves exact-capacity UTF-8 values', () {
      final encoder = getFixedNameEncoder();

      expect(
        encoder.encode('éé'),
        equals(Uint8List.fromList([0xc3, 0xa9, 0xc3, 0xa9])),
      );
    });

    test('rejects over-capacity UTF-8 values without writing', () {
      final encoder = getFixedNameEncoder();
      final destination = Uint8List.fromList([9, 9, 9, 9, 9, 9]);

      expect(
        () => encoder.write('ééa', destination, 1),
        throwsA(_isOverCapacityError(expected: 4, actual: 5)),
      );
      expect(destination, equals(Uint8List.fromList([9, 9, 9, 9, 9, 9])));
    });
  });

  group('generated fixed-capacity array encoder', () {
    test('pads under-capacity arrays', () {
      final encoder = getFixedValuesEncoder();

      expect(
        encoder.encode([1, 2]),
        equals(Uint8List.fromList([1, 2, 0, 0])),
      );
    });

    test('preserves exact-capacity arrays', () {
      final encoder = getFixedValuesEncoder();

      expect(
        encoder.encode([1, 2, 3, 4]),
        equals(Uint8List.fromList([1, 2, 3, 4])),
      );
    });

    test('rejects over-capacity arrays without writing', () {
      final encoder = getFixedValuesEncoder();
      final destination = Uint8List.fromList([9, 9, 9, 9, 9, 9]);

      expect(
        () => encoder.write([1, 2, 3, 4, 5], destination, 1),
        throwsA(_isOverCapacityError(expected: 4, actual: 5)),
      );
      expect(destination, equals(Uint8List.fromList([9, 9, 9, 9, 9, 9])));
    });
  });
}

Matcher _isOverCapacityError({required int expected, required int actual}) {
  return isA<SolanaError>()
      .having(
        (error) => error.code,
        'code',
        SolanaErrorCode.codecsInvalidByteLength,
      )
      .having(
        (error) => error.context['expected'],
        'expected',
        expected,
      )
      .having(
        (error) => error.context['bytesLength'],
        'bytesLength',
        actual,
      );
}
