import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

import 'setup.dart';

/// Helper: FixedSizeEncoder that writes a single fixed byte.
Encoder<num> _fixedNumEncoder(int byte) => FixedSizeEncoder<num>(
  fixedSize: 1,
  write: (_, bytes, offset) {
    bytes[offset] = byte;
    return offset + 1;
  },
);

/// Helper: FixedSizeDecoder that reads a single byte and returns a constant.
Decoder<num> _fixedNumDecoder(num value) => FixedSizeDecoder<num>(
  fixedSize: 1,
  read: (_, offset) => (value, offset + 1),
);

void main() {
  // ---- utils.dart coverage ----
  group('utils: getFixedSize', () {
    test('returns fixedSize for FixedSizeCodec', () {
      final codec = getU8Codec();
      expect(getFixedSize(codec), equals(1));
    });
  });

  group('utils: getMaxSize', () {
    test('returns fixedSize for FixedSizeCodec', () {
      final codec = getU8Codec();
      expect(getMaxSize(codec), equals(1));
    });

    test('returns maxSize for VariableSizeEncoder', () {
      final encoder = VariableSizeEncoder<num>(
        getSizeFromValue: (_) => 5,
        write: (v, bytes, offset) {
          bytes[offset] = v.toInt();
          return offset + 1;
        },
        maxSize: 10,
      );
      expect(getMaxSize(encoder), equals(10));
    });

    test('returns maxSize for VariableSizeDecoder', () {
      final decoder = VariableSizeDecoder<num>(
        read: (bytes, offset) => (bytes[offset], offset + 1),
        maxSize: 10,
      );
      expect(getMaxSize(decoder), equals(10));
    });

    test('returns maxSize for VariableSizeCodec', () {
      final codec = combineCodec(
        VariableSizeEncoder<num>(
          getSizeFromValue: (_) => 5,
          write: (v, bytes, offset) {
            bytes[offset] = v.toInt();
            return offset + 1;
          },
          maxSize: 10,
        ),
        VariableSizeDecoder<num>(
          read: (bytes, offset) => (bytes[offset], offset + 1),
          maxSize: 10,
        ),
      );
      expect(getMaxSize(codec), equals(10));
    });
  });

  // ---- boolean.dart coverage ----
  group('BooleanCodecConfig', () {
    test('creates with null size by default', () {
      const config = BooleanCodecConfig();
      expect(config.size, isNull);
    });

    test('creates with custom size', () {
      final codec = getU32Codec();
      final config = BooleanCodecConfig(size: codec);
      expect(config.size, equals(codec));
    });
  });

  // ---- array.dart coverage ----
  group('array decoder: negative size', () {
    test('throws on negative prefix size', () {
      final negDecoder = transformDecoder<num, num>(
        getU8Decoder(),
        (_, _, _) => -1,
      );
      final customDecoder = getArrayDecoder<Object?>(
        getUnitDecoder() as Decoder<Object?>,
        size: PrefixedArraySize(negDecoder),
      );
      expect(
        () => customDecoder.decode(Uint8List.fromList([0])),
        throwsA(
          predicate(
            (e) => isSolanaError(e, SolanaErrorCode.codecsInvalidNumberOfItems),
          ),
        ),
      );
    });
  });

  // ---- nullable.dart coverage ----
  group('nullable: ConstantNoneValue', () {
    test('creates ConstantNoneValue with bytes', () {
      final noneVal = ConstantNoneValue(Uint8List.fromList([0xff, 0xff]));
      expect(noneVal.bytes, equals(Uint8List.fromList([0xff, 0xff])));
    });

    test('encodes null with ConstantNoneValue and prefix', () {
      final codec = getNullableCodec<num>(
        getU8Codec(),
        noneValue: ConstantNoneValue(Uint8List.fromList([0xff])),
      );
      expect(hex(codec.encode(null)), equals('00ff'));
      expect(hex(codec.encode(42)), equals('012a'));
    });

    test('decodes null with ConstantNoneValue and prefix', () {
      final codec = getNullableCodec<num>(
        getU8Codec(),
        noneValue: ConstantNoneValue(Uint8List.fromList([0xff])),
      );
      expect(codec.decode(b('00ff')), isNull);
      expect(codec.decode(b('012a')), equals(42));
    });

    test('ConstantNoneValue without prefix', () {
      final codec = getNullableCodec<num>(
        getU8Codec(),
        hasPrefix: false,
        noneValue: ConstantNoneValue(Uint8List.fromList([0xff])),
      );
      expect(hex(codec.encode(null)), equals('ff'));
      expect(hex(codec.encode(42)), equals('2a'));
      expect(codec.decode(b('ff')), isNull);
      expect(codec.decode(b('2a')), equals(42));
    });
  });

  group('nullable: getNullableCodec with prefix codec', () {
    test('encodes and decodes with u32 prefix codec', () {
      final codec = getNullableCodec<num>(getU8Codec(), prefix: getU32Codec());
      expect(hex(codec.encode(null)), equals('00000000'));
      expect(hex(codec.encode(42)), equals('010000002a'));
      expect(codec.decode(b('00000000')), isNull);
      expect(codec.decode(b('010000002a')), equals(42));
    });
  });

  // ---- struct.dart coverage ----
  group('struct: variable-size fields', () {
    test('encodes variable-size struct fields', () {
      final encoder = getStructEncoder([
        ('x', getU8Encoder() as Encoder<Object?>),
        ('arr', getArrayEncoder<Object?>(getU8Encoder() as Encoder<Object?>)),
      ]);
      final result = encoder.encode({
        'x': 5,
        'arr': [1, 2, 3],
      });
      expect(hex(result), equals('0503000000010203'));
    });

    test('decodes variable-size struct fields', () {
      final decoder = getStructDecoder([
        ('x', getU8Decoder() as Decoder<Object?>),
        ('arr', getArrayDecoder<Object?>(getU8Decoder() as Decoder<Object?>)),
      ]);
      final result = decoder.decode(b('0503000000010203'));
      expect(result['x'], equals(5));
      expect(result['arr'], equals([1, 2, 3]));
    });
  });

  // ---- tuple.dart coverage ----
  group('tuple: variable-size items', () {
    test('encodes variable-size tuple items', () {
      final encoder = getTupleEncoder([
        getU8Encoder() as Encoder<Object?>,
        getArrayEncoder<Object?>(getU8Encoder() as Encoder<Object?>),
      ]);
      final result = encoder.encode([
        5,
        [1, 2, 3],
      ]);
      expect(hex(result), equals('0503000000010203'));
    });

    test('decodes variable-size tuple items', () {
      final decoder = getTupleDecoder([
        getU8Decoder() as Decoder<Object?>,
        getArrayDecoder<Object?>(getU8Decoder() as Decoder<Object?>),
      ]);
      final result = decoder.decode(b('0503000000010203'));
      expect(result[0], equals(5));
      expect(result[1], equals([1, 2, 3]));
    });
  });

  // ---- map.dart coverage ----
  group('map codec: PrefixedArraySize with Codec prefix', () {
    test('splits codec prefix into encoder/decoder', () {
      final codec = getMapCodec<num, num>(
        getU8Codec(),
        getU8Codec(),
        size: PrefixedArraySize(getU8Codec()),
      );
      expect(hex(codec.encode({1: 10, 2: 20})), equals('02010a0214'));
      final decoded = codec.decode(b('02010a0214'));
      expect(decoded[1], equals(10));
      expect(decoded[2], equals(20));
    });
  });

  // ---- set.dart coverage ----
  group('set codec: PrefixedArraySize with Codec prefix', () {
    test('splits codec prefix into encoder/decoder', () {
      final codec = getSetCodec<num>(
        getU8Codec(),
        size: PrefixedArraySize(getU8Codec()),
      );
      expect(hex(codec.encode({1, 2, 3})), equals('03010203'));
      expect(codec.decode(b('03010203')), equals({1, 2, 3}));
    });
  });

  // ---- discriminated_union.dart coverage ----
  group('discriminated union: codec with custom size', () {
    test('splits u32 size for encoder/decoder', () {
      final encoder = getDiscriminatedUnionEncoder([
        ('A', getUnitEncoder() as Encoder<Object?>),
        (
          'B',
          getStructEncoder([
            ('x', getU8Encoder() as Encoder<Object?>),
            ('y', getU8Encoder() as Encoder<Object?>),
          ]),
        ),
      ], size: getU32Encoder());
      final decoder = getDiscriminatedUnionDecoder([
        ('A', getUnitDecoder() as Decoder<Object?>),
        (
          'B',
          getStructDecoder([
            ('x', getU8Decoder() as Decoder<Object?>),
            ('y', getU8Decoder() as Decoder<Object?>),
          ]),
        ),
      ], size: getU32Decoder());
      // A = index 0, u32 prefix
      expect(hex(encoder.encode({'__kind': 'A'})), equals('00000000'));
      // B = index 1, u32 prefix + struct
      expect(
        hex(encoder.encode({'__kind': 'B', 'x': 5, 'y': 6})),
        equals('010000000506'),
      );
      expect(decoder.decode(b('00000000'))['__kind'], equals('A'));
      expect(decoder.decode(b('010000000506'))['__kind'], equals('B'));
      expect(decoder.decode(b('010000000506'))['x'], equals(5));
    });
  });

  group('discriminated union: invalid variant index', () {
    test('throws on encode with out-of-range discriminator', () {
      final encoder = getDiscriminatedUnionEncoder([
        ('A', getUnitEncoder() as Encoder<Object?>),
      ]);
      expect(
        () => encoder.encode({'__kind': 'Unknown'}),
        throwsA(
          predicate(
            (e) => isSolanaError(
              e,
              SolanaErrorCode.codecsInvalidDiscriminatedUnionVariant,
            ),
          ),
        ),
      );
    });

    test('throws on decode with out-of-range index', () {
      final decoder = getDiscriminatedUnionDecoder([
        ('A', getUnitDecoder() as Decoder<Object?>),
      ]);
      expect(
        () => decoder.decode(b('05')),
        throwsA(
          predicate(
            (e) =>
                isSolanaError(e, SolanaErrorCode.codecsUnionVariantOutOfRange),
          ),
        ),
      );
    });
  });

  // ---- predicate.dart coverage ----
  group('predicate: fixed-size encoders', () {
    test('returns FixedSizeEncoder when both sides are fixed', () {
      final encoder = getPredicateEncoder<num>(
        (v) => v > 0,
        _fixedNumEncoder(1),
        _fixedNumEncoder(0),
      );
      expect(encoder, isA<FixedSizeEncoder<num>>());
      expect(encoder.encode(5), [1]);
      expect(encoder.encode(-1), [0]);
    });
  });

  group('predicate: fixed-size decoders', () {
    test('returns FixedSizeDecoder when both sides are fixed', () {
      final decoder = getPredicateDecoder<num>(
        (bytes) => bytes[0] == 1,
        _fixedNumDecoder(100),
        _fixedNumDecoder(0),
      );
      expect(decoder, isA<FixedSizeDecoder<num>>());
      expect(decoder.decode(Uint8List.fromList([1])), equals(100));
      expect(decoder.decode(Uint8List.fromList([0])), equals(0));
    });
  });

  // ---- pattern_match.dart coverage ----
  group('pattern match encoder', () {
    test('encodes using matching pattern', () {
      final encoder = getPatternMatchEncoder<num>([
        ((n) => n < 256, getU8Encoder()),
        ((n) => true, getU32Encoder()),
      ]);
      expect(hex(encoder.encode(42)), equals('2a'));
      expect(hex(encoder.encode(1000)), equals('e8030000'));
    });

    test('throws when no pattern matches', () {
      final encoder = getPatternMatchEncoder<num>([
        ((n) => n < 0, getU8Encoder()),
      ]);
      expect(
        () => encoder.encode(42),
        throwsA(
          predicate(
            (e) => isSolanaError(
              e,
              SolanaErrorCode.codecsInvalidPatternMatchValue,
            ),
          ),
        ),
      );
    });

    test('returns FixedSizeEncoder when all patterns are fixed', () {
      final encoder = getPatternMatchEncoder<num>([
        ((n) => n < 256, getU8Encoder()),
        ((n) => true, getU8Encoder()),
      ]);
      expect(encoder, isA<FixedSizeEncoder<num>>());
    });

    test('returns VariableSizeEncoder with correct size', () {
      final encoder = getPatternMatchEncoder<num>([
        ((n) => n < 256, getU8Encoder()),
        ((n) => true, getU32Encoder()),
      ]);
      expect(encoder, isA<VariableSizeEncoder<num>>());
      expect(encoder.encode(42), hasLength(1));
      expect(encoder.encode(1000), hasLength(4));
    });
  });

  group('pattern match decoder', () {
    test('decodes using matching pattern', () {
      final decoder = getPatternMatchDecoder<num>([
        ((bytes) => bytes.length == 1, getU8Decoder()),
        ((bytes) => bytes.length <= 4, getU32Decoder()),
      ]);
      expect(decoder.decode(b('2a')), equals(42));
      expect(decoder.decode(b('e8030000')), equals(1000));
    });

    test('throws when no pattern matches', () {
      final decoder = getPatternMatchDecoder<num>([
        ((bytes) => false, getU8Decoder()),
      ]);
      expect(
        () => decoder.decode(b('2a')),
        throwsA(
          predicate(
            (e) => isSolanaError(
              e,
              SolanaErrorCode.codecsInvalidPatternMatchBytes,
            ),
          ),
        ),
      );
    });

    test('returns FixedSizeDecoder when all patterns are fixed', () {
      final decoder = getPatternMatchDecoder<num>([
        ((bytes) => bytes.length == 1, getU8Decoder()),
        ((bytes) => true, getU8Decoder()),
      ]);
      expect(decoder, isA<FixedSizeDecoder<num>>());
    });

    test('returns VariableSizeDecoder with correct size', () {
      final decoder = getPatternMatchDecoder<num>([
        ((bytes) => bytes.length == 1, getU8Decoder()),
        ((bytes) => bytes.length <= 4, getU32Decoder()),
      ]);
      expect(decoder, isA<VariableSizeDecoder<num>>());
    });
  });

  group('pattern match codec', () {
    test('encodes and decodes with matching patterns', () {
      final codec = getPatternMatchCodec<num, num>([
        ((n) => n < 256, (bytes) => bytes.length == 1, getU8Codec()),
        ((n) => true, (bytes) => bytes.length <= 4, getU32Codec()),
      ]);
      expect(codec.decode(codec.encode(42)), equals(42));
      expect(codec.decode(codec.encode(1000)), equals(1000));
    });

    test('throws on encode when no value pattern matches', () {
      final codec = getPatternMatchCodec<num, num>([
        ((n) => false, (bytes) => true, getU8Codec()),
      ]);
      expect(
        () => codec.encode(42),
        throwsA(
          predicate(
            (e) => isSolanaError(
              e,
              SolanaErrorCode.codecsInvalidPatternMatchValue,
            ),
          ),
        ),
      );
    });

    test('throws on decode when no bytes pattern matches', () {
      final codec = getPatternMatchCodec<num, num>([
        ((n) => true, (bytes) => false, getU8Codec()),
      ]);
      expect(
        () => codec.decode(b('2a')),
        throwsA(
          predicate(
            (e) => isSolanaError(
              e,
              SolanaErrorCode.codecsInvalidPatternMatchBytes,
            ),
          ),
        ),
      );
    });
  });

  // ---- union.dart coverage ----
  group('union: typed union index getters', () {
    test('Union2Variant0.index is 0', () {
      expect(const Union2Variant0<int, int>(42).index, equals(0));
    });

    test('Union2Variant1.index is 1', () {
      expect(const Union2Variant1<int, int>(42).index, equals(1));
    });

    test('Union3Variant0.index is 0', () {
      expect(const Union3Variant0<int, int, int>(42).index, equals(0));
    });

    test('Union3Variant1.index is 1', () {
      expect(const Union3Variant1<int, int, int>(42).index, equals(1));
    });

    test('Union3Variant2.index is 2', () {
      expect(const Union3Variant2<int, int, int>(42).index, equals(2));
    });
  });

  group('union: getUnionEncoder fixed-size', () {
    test('returns FixedSizeEncoder when all variants are fixed-size', () {
      final encoder = getUnionEncoder([
        getU8Encoder() as Encoder<Object?>,
        getU8Encoder() as Encoder<Object?>,
      ], (value) => (value! as num).toInt() > 127 ? 1 : 0);
      expect(encoder, isA<FixedSizeEncoder<Object?>>());
      expect(encoder.encode(42), [42]);
      expect(encoder.encode(200), [200]);
    });
  });

  group('union: getUnionDecoder fixed-size', () {
    test('returns FixedSizeDecoder when all variants are fixed-size', () {
      final decoder = getUnionDecoder([
        getU8Decoder() as Decoder<Object?>,
        getU8Decoder() as Decoder<Object?>,
      ], (bytes, offset) => bytes[offset] > 127 ? 1 : 0);
      expect(decoder, isA<FixedSizeDecoder<Object?>>());
      expect(decoder.decode(b('2a')), equals(42));
      expect(decoder.decode(b('c8')), equals(200));
    });
  });

  group('union2: fixed-size encoder', () {
    test('returns FixedSizeEncoder when both variants are fixed', () {
      final encoder = getUnion2Encoder<num, num>(
        getU8Encoder(),
        getU8Encoder(),
      );
      expect(encoder, isA<FixedSizeEncoder<Union2<num, num>>>());
      expect(encoder.encode(const Union2Variant0(42)), [42]);
      expect(encoder.encode(const Union2Variant1(99)), [99]);
    });
  });

  group('union2: fixed-size decoder', () {
    test('returns FixedSizeDecoder when both variants are fixed', () {
      final decoder = getUnion2Decoder<num, num>(
        getU8Decoder(),
        getU8Decoder(),
        (bytes, offset) => bytes[offset] > 127 ? 1 : 0,
      );
      expect(decoder, isA<FixedSizeDecoder<Union2<num, num>>>());
      final (v0, _) = decoder.read(Uint8List.fromList([42]), 0);
      expect(v0, isA<Union2Variant0<num, num>>());
      final (v1, _) = decoder.read(Uint8List.fromList([200]), 0);
      expect(v1, isA<Union2Variant1<num, num>>());
    });
  });

  group('union2: invalid variant index', () {
    test('throws SolanaError for out-of-range index', () {
      final decoder = getUnion2Decoder<num, num>(
        getU8Decoder(),
        getU8Decoder(),
        (bytes, offset) => 5,
      );
      expect(
        () => decoder.decode(Uint8List.fromList([0])),
        throwsA(
          predicate(
            (e) =>
                isSolanaError(e, SolanaErrorCode.codecsUnionVariantOutOfRange),
          ),
        ),
      );
    });
  });

  group('union3: fixed-size encoder', () {
    test('returns FixedSizeEncoder when all variants are fixed', () {
      final encoder = getUnion3Encoder<num, num, num>(
        getU8Encoder(),
        getU8Encoder(),
        getU8Encoder(),
      );
      expect(encoder, isA<FixedSizeEncoder<Union3<num, num, num>>>());
      expect(encoder.encode(const Union3Variant0(1)), [1]);
      expect(encoder.encode(const Union3Variant1(2)), [2]);
      expect(encoder.encode(const Union3Variant2(3)), [3]);
    });
  });

  group('union3: fixed-size decoder', () {
    test('returns FixedSizeDecoder when all variants are fixed', () {
      final decoder = getUnion3Decoder<num, num, num>(
        getU8Decoder(),
        getU8Decoder(),
        getU8Decoder(),
        (bytes, offset) => offset,
      );
      expect(decoder, isA<FixedSizeDecoder<Union3<num, num, num>>>());
    });
  });

  group('union3: invalid variant index', () {
    test('throws SolanaError for out-of-range index', () {
      final decoder = getUnion3Decoder<num, num, num>(
        getU8Decoder(),
        getU8Decoder(),
        getU8Decoder(),
        (bytes, offset) => 5,
      );
      expect(
        () => decoder.decode(Uint8List.fromList([0])),
        throwsA(
          predicate(
            (e) =>
                isSolanaError(e, SolanaErrorCode.codecsUnionVariantOutOfRange),
          ),
        ),
      );
    });
  });
}
