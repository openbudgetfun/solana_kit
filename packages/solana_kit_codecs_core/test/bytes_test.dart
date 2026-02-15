import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:test/test.dart';

void main() {
  group('mergeBytes', () {
    test('can merge multiple arrays of bytes together', () {
      final merged = mergeBytes([
        Uint8List.fromList([1, 2, 3]),
        Uint8List.fromList([4, 5]),
        Uint8List.fromList([6, 7, 8, 9]),
      ]);
      expect(merged, equals(Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9])));
    });

    test('reuses the original byte array when applicable', () {
      final emptyBytesA = Uint8List(0);
      final emptyBytesB = Uint8List(0);
      final nonEmptyBytesA = Uint8List.fromList([1, 2, 3]);
      final nonEmptyBytesB = Uint8List.fromList([4, 5, 6]);

      // A new byte array is created when merging an empty list.
      expect(mergeBytes([]), equals(Uint8List(0)));

      // The first empty byte array is returned when merging
      // multiple empty byte arrays.
      expect(identical(mergeBytes([emptyBytesA]), emptyBytesA), isTrue);
      expect(
        identical(mergeBytes([emptyBytesA, emptyBytesB]), emptyBytesA),
        isTrue,
      );
      expect(
        identical(mergeBytes([emptyBytesB, emptyBytesA]), emptyBytesB),
        isTrue,
      );

      // The first non-empty byte array is returned when merging multiple
      // byte arrays such that only one is non-empty.
      expect(
        identical(
          mergeBytes([nonEmptyBytesA, emptyBytesA, emptyBytesB]),
          nonEmptyBytesA,
        ),
        isTrue,
      );
      expect(
        identical(
          mergeBytes([emptyBytesA, emptyBytesB, nonEmptyBytesA]),
          nonEmptyBytesA,
        ),
        isTrue,
      );

      // A new byte array is created when merging multiple non-empty byte
      // arrays.
      final merged = mergeBytes([nonEmptyBytesA, nonEmptyBytesB, emptyBytesA]);
      expect(identical(merged, nonEmptyBytesA), isFalse);
      expect(identical(merged, nonEmptyBytesB), isFalse);
    });
  });

  group('padBytes', () {
    test('can pad an array of bytes to the specified length', () {
      expect(
        padBytes(Uint8List.fromList([1, 2, 3]), 5),
        equals(Uint8List.fromList([1, 2, 3, 0, 0])),
      );
      // Shorter length returns as-is.
      expect(
        padBytes(Uint8List.fromList([1, 2, 3]), 2),
        equals(Uint8List.fromList([1, 2, 3])),
      );
    });

    test('reuses the original byte array when applicable', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      expect(identical(padBytes(bytes, 5), bytes), isTrue);
      expect(identical(padBytes(bytes, 2), bytes), isTrue);
      expect(identical(padBytes(bytes, 10), bytes), isFalse);
    });
  });

  group('fixBytes', () {
    test('can fix an array of bytes to the specified length', () {
      // Pad shorter.
      expect(
        fixBytes(Uint8List.fromList([1, 2, 3]), 5),
        equals(Uint8List.fromList([1, 2, 3, 0, 0])),
      );
      // Truncate longer.
      expect(
        fixBytes(Uint8List.fromList([1, 2, 3]), 2),
        equals(Uint8List.fromList([1, 2])),
      );
    });

    test('reuses the original byte array when applicable', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      expect(identical(fixBytes(bytes, 5), bytes), isTrue);
      expect(identical(fixBytes(bytes, 2), bytes), isFalse);
      expect(identical(fixBytes(bytes, 10), bytes), isFalse);
    });
  });

  group('containsBytes', () {
    test('finds bytes at offset', () {
      final data = Uint8List.fromList([0, 1, 2, 3, 4]);
      expect(containsBytes(data, Uint8List.fromList([1, 2, 3]), 1), isTrue);
      expect(containsBytes(data, Uint8List.fromList([1, 2, 3]), 0), isFalse);
    });

    test('returns false when offset exceeds range', () {
      final data = Uint8List.fromList([0, 1, 2]);
      expect(containsBytes(data, Uint8List.fromList([2, 3]), 2), isFalse);
    });

    test('handles matching entire array', () {
      final data = Uint8List.fromList([1, 2, 3]);
      expect(containsBytes(data, Uint8List.fromList([1, 2, 3]), 0), isTrue);
    });
  });

  group('bytesEqual', () {
    test('can check if two byte arrays are equal', () {
      expect(
        bytesEqual(
          Uint8List.fromList([1, 2, 3]),
          Uint8List.fromList([1, 2, 3]),
        ),
        isTrue,
      );
      expect(
        bytesEqual(
          Uint8List.fromList([1, 2, 3]),
          Uint8List.fromList([1, 2, 4]),
        ),
        isFalse,
      );
    });

    test('treats empty byte arrays as equal', () {
      expect(bytesEqual(Uint8List(0), Uint8List(0)), isTrue);
      expect(
        bytesEqual(Uint8List(0), Uint8List.fromList([0])),
        isFalse,
      );
      expect(
        bytesEqual(Uint8List.fromList([0]), Uint8List(0)),
        isFalse,
      );
    });

    test('returns false when byte arrays are different lengths', () {
      expect(
        bytesEqual(
          Uint8List.fromList([1, 2, 3]),
          Uint8List.fromList([1, 2, 3, 4]),
        ),
        isFalse,
      );
      expect(
        bytesEqual(
          Uint8List.fromList([1, 2, 3, 4]),
          Uint8List.fromList([1, 2, 3]),
        ),
        isFalse,
      );
    });
  });
}
