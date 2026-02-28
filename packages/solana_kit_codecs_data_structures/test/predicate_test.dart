import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:test/test.dart';

final _encodeToZero = FixedSizeEncoder<int>(
  fixedSize: 1,
  write: (_, bytes, offset) {
    bytes[offset] = 0;
    return offset + 1;
  },
);

final _encodeToOne = FixedSizeEncoder<int>(
  fixedSize: 1,
  write: (_, bytes, offset) {
    bytes[offset] = 1;
    return offset + 1;
  },
);

final _decodeToZero = FixedSizeDecoder<int>(
  fixedSize: 1,
  read: (_, offset) => (0, offset + 1),
);

final _decodeToOne = FixedSizeDecoder<int>(
  fixedSize: 1,
  read: (_, offset) => (1, offset + 1),
);

void main() {
  group('getPredicateEncoder', () {
    test('encodes using true encoder when predicate is true', () {
      final encoder = getPredicateEncoder<int>(
        (_) => true,
        _encodeToOne,
        _encodeToZero,
      );
      expect(encoder.encode(42), [1]);
    });

    test('encodes using false encoder when predicate is false', () {
      final encoder = getPredicateEncoder<int>(
        (_) => false,
        _encodeToOne,
        _encodeToZero,
      );
      expect(encoder.encode(42), [0]);
    });
  });

  group('getPredicateDecoder', () {
    test('decodes using true decoder when predicate is true', () {
      final decoder = getPredicateDecoder<int>(
        (_) => true,
        _decodeToOne,
        _decodeToZero,
      );
      expect(decoder.decode(Uint8List.fromList([42])), 1);
    });

    test('decodes using false decoder when predicate is false', () {
      final decoder = getPredicateDecoder<int>(
        (_) => false,
        _decodeToOne,
        _decodeToZero,
      );
      expect(decoder.decode(Uint8List.fromList([42])), 0);
    });
  });

  group('getPredicateCodec', () {
    final codecZero = combineCodec(_encodeToZero, _decodeToZero);
    final codecOne = combineCodec(_encodeToOne, _decodeToOne);

    test('encodes using true encoder when encode predicate is true', () {
      final codec = getPredicateCodec<int, int>(
        (_) => true,
        (_) => false,
        codecOne,
        codecZero,
      );
      expect(codec.encode(42), [1]);
    });

    test('encodes using false encoder when encode predicate is false', () {
      final codec = getPredicateCodec<int, int>(
        (_) => false,
        (_) => true,
        codecOne,
        codecZero,
      );
      expect(codec.encode(42), [0]);
    });

    test('decodes using true decoder when decode predicate is true', () {
      final codec = getPredicateCodec<int, int>(
        (_) => false,
        (_) => true,
        codecOne,
        codecZero,
      );
      expect(codec.decode(Uint8List.fromList([42])), 1);
    });

    test('decodes using false decoder when decode predicate is false', () {
      final codec = getPredicateCodec<int, int>(
        (_) => true,
        (_) => false,
        codecOne,
        codecZero,
      );
      expect(codec.decode(Uint8List.fromList([42])), 0);
    });
  });
}
