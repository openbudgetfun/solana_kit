import 'dart:typed_data';

import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';
import 'package:test/test.dart';

void main() {
  group('getSignatoriesComparator()', () {
    Uint8List arr(List<int> values) => Uint8List.fromList(values);

    test('sorts byte arrays lexicographically', () {
      final input = [
        arr([0, 0]),
        arr([1]),
        arr([1, 1, 0]),
        arr([0, 1, 0]),
        arr([0, 0, 0]),
        arr([1, 1, 1]),
        arr([0]),
        arr([0, 1, 1]),
        arr([0, 0, 1]),
      ]..sort(getSignatoriesComparator());

      final expected = [
        arr([0]),
        arr([1]),
        arr([0, 0]),
        arr([0, 0, 0]),
        arr([0, 0, 1]),
        arr([0, 1, 0]),
        arr([0, 1, 1]),
        arr([1, 1, 0]),
        arr([1, 1, 1]),
      ];

      expect(input.length, equals(expected.length));
      for (var i = 0; i < input.length; i++) {
        expect(input[i], equals(expected[i]));
      }
    });
  });
}
