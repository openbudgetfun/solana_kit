import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('array codec', () {
    test('encodes with u32 prefix by default', () {
      final codec = getArrayCodec(getU8Codec());
      expect(hex(codec.encode([1, 2, 3])), equals('03000000010203'));
    });

    test('decodes with u32 prefix by default', () {
      final codec = getArrayCodec(getU8Codec());
      final result = codec.decode(b('03000000010203'));
      expect(result, equals([1, 2, 3]));
    });

    test('encodes empty array', () {
      final codec = getArrayCodec(getU8Codec());
      expect(hex(codec.encode([])), equals('00000000'));
    });

    test('decodes empty array', () {
      final codec = getArrayCodec(getU8Codec());
      expect(codec.decode(b('00000000')), isEmpty);
    });

    test('uses custom prefix codec', () {
      final codec = getArrayCodec(
        getU8Codec(),
        size: PrefixedArraySize(getU8Codec()),
      );
      expect(hex(codec.encode([1, 2, 3])), equals('03010203'));
      expect(codec.decode(b('03010203')), equals([1, 2, 3]));
    });

    test('uses a BigInt prefix codec', () {
      final codec = getArrayCodec(
        getU8Codec(),
        size: PrefixedArraySize(getU64Codec()),
      );
      const encoded = '0300000000000000010203';

      expect(hex(codec.encode([1, 2, 3])), equals(encoded));
      expect(codec.decode(b(encoded)), equals([1, 2, 3]));
    });

    test('uses fixed size', () {
      final codec = getArrayCodec(getU8Codec(), size: const FixedArraySize(3));
      expect(hex(codec.encode([1, 2, 3])), equals('010203'));
      expect(codec.decode(b('010203')), equals([1, 2, 3]));
    });

    test('throws on wrong number of items for fixed size', () {
      final codec = getArrayCodec(getU8Codec(), size: const FixedArraySize(3));
      expect(
        () => codec.encode([1, 2]),
        throwsA(
          predicate(
            (e) => isSolanaError(e, SolanaErrorCode.codecsInvalidNumberOfItems),
          ),
        ),
      );
    });

    test('uses remainder size', () {
      final codec = getArrayCodec(
        getU8Codec(),
        size: const RemainderArraySize(),
      );
      expect(hex(codec.encode([1, 2, 3])), equals('010203'));
      expect(codec.decode(b('010203')), equals([1, 2, 3]));
    });

    test('encodes sentinel-terminated arrays with required by default', () {
      final sentinel = SentinelArraySize(b('00'));

      // Empty (writes only the sentinel).
      final codec = getArrayCodec(getU8Codec(), size: sentinel);
      expect(hex(codec.encode([])), equals('00'));
      final (empty, emptyOffset) = codec.read(b('00'), 0);
      expect(empty, isEmpty);
      expect(emptyOffset, 1);

      // Numbers (the sentinel is appended after the items).
      expect(hex(codec.encode([42, 1, 2])), equals('2a010200'));
      final (values, offset) = codec.read(b('2a010200'), 0);
      expect(values, equals([42, 1, 2]));
      expect(offset, 4);
      final (atOffset, newOffset) = codec.read(b('ffff2a010200'), 2);
      expect(atOffset, equals([42, 1, 2]));
      expect(newOffset, 6);

      // Multi-byte sentinels.
      final wide = SentinelArraySize(b('ffff'));
      final wideCodec = getArrayCodec(getU8Codec(), size: wide);
      expect(hex(wideCodec.encode([42, 1, 2])), equals('2a0102ffff'));
      final (wideValues, wideOffset) = wideCodec.read(b('2a0102ffff'), 0);
      expect(wideValues, equals([42, 1, 2]));
      expect(wideOffset, 5);
    });

    test(
      'sentinel is only compared at item boundaries, not inside items',
      () {
        // Each big-endian u16 item contains a `00` byte (e.g. 256 encodes
        // to `0100`), which is the sentinel — yet decoding does not stop
        // mid-item because only item boundaries are checked. This only
        // holds because every item is >= 256; a value in [0, 255] would
        // encode to `00xx`, starting with the sentinel byte and terminating
        // the array early (see the class documentation invariants).
        final u16Be = getU16Codec(const NumberCodecConfig(endian: Endian.big));
        final codec = getArrayCodec(u16Be, size: SentinelArraySize(b('00')));
        expect(hex(codec.encode([256, 258])), equals('0100010200'));
        final (beValues, beOffset) = codec.read(b('0100010200'), 0);
        expect(beValues, equals([256, 258]));
        expect(beOffset, 5);
      },
    );

    test('throws when a required sentinel is missing', () {
      final codec = getArrayCodec(
        getU8Codec(),
        size: SentinelArraySize(b('00')),
      );
      expect(
        () => codec.decode(b('2a0102')),
        throwsA(
          isA<SolanaError>()
              .having(
                (e) => e.code,
                'code',
                SolanaErrorCode.codecsSentinelMissingAtEndOfBytes,
              )
              .having(
                (e) => e.context,
                'context',
                {
                  'codecDescription': 'array',
                  'hexSentinel': '00',
                  'sentinel': b('00'),
                },
              ),
        ),
      );

      // The codec description is used in the error when provided.
      final described = getArrayCodec(
        getU8Codec(),
        size: SentinelArraySize(b('00')),
        description: 'myList',
      );
      expect(
        () => described.decode(b('2a0102')),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.context,
            'context',
            containsPair('codecDescription', 'myList'),
          ),
        ),
      );
    });

    test('encodes sentinel-terminated arrays with the optional strategy', () {
      final optional = SentinelArraySize(
        b('00'),
        strategy: SentinelCountStrategy.optional,
      );
      final codec = getArrayCodec(getU8Codec(), size: optional);

      // The sentinel is written when encoding.
      expect(hex(codec.encode([42, 1, 2])), equals('2a010200'));

      // The sentinel is consumed when present.
      final (present, presentOffset) = codec.read(b('2a010200'), 0);
      expect(present, equals([42, 1, 2]));
      expect(presentOffset, 4);

      // A missing sentinel is tolerated: the array ends at the end of the
      // byte array.
      final (absent, absentOffset) = codec.read(b('2a0102'), 0);
      expect(absent, equals([42, 1, 2]));
      expect(absentOffset, 3);
      final (fromEmpty, emptyEndOffset) = codec.read(b(''), 0);
      expect(fromEmpty, isEmpty);
      expect(emptyEndOffset, 0);
    });

    test('encodes sentinel-terminated arrays with the omitted strategy', () {
      final omitted = SentinelArraySize(
        b('00'),
        strategy: SentinelCountStrategy.omitted,
      );
      final codec = getArrayCodec(getU8Codec(), size: omitted);

      // The sentinel is never written when encoding.
      expect(hex(codec.encode([42, 1, 2])), equals('2a0102'));
      expect(hex(codec.encode([])), equals(''));

      // The array ends at the end of the byte array.
      final (tailValues, tailOffset) = codec.read(b('2a0102'), 0);
      expect(tailValues, equals([42, 1, 2]));
      expect(tailOffset, 3);

      // A sentinel that is present is still consumed.
      final (consumedValues, consumedOffset) = codec.read(b('2a010200'), 0);
      expect(consumedValues, equals([42, 1, 2]));
      expect(consumedOffset, 4);
    });

    test('rejects an empty sentinel at construction time', () {
      // An empty sentinel cannot delimit a collection, so both the encoder
      // and decoder throw.
      final empty = SentinelArraySize(b(''));
      const expectedCode = SolanaErrorCode.codecsSentinelMustNotBeEmpty;
      expect(
        () => getArrayEncoder(getU8Encoder(), size: empty),
        throwsA(
          isA<SolanaError>().having((e) => e.code, 'code', expectedCode),
        ),
      );
      expect(
        () => getArrayDecoder(getU8Decoder(), size: empty),
        throwsA(
          isA<SolanaError>().having((e) => e.code, 'code', expectedCode),
        ),
      );
      expect(
        () => getArrayCodec(getU8Codec(), size: empty),
        throwsA(
          isA<SolanaError>().having((e) => e.code, 'code', expectedCode),
        ),
      );
    });

    test(
      'stops decoding early when an item begins with the sentinel bytes',
      () {
        // INVARIANT: no valid item may begin with the sentinel's bytes. This
        // is the caller's responsibility; the codec cannot tell a leading
        // sentinel apart from a terminator.
        final codec = getArrayCodec(
          getU16Codec(),
          size: SentinelArraySize(b('00')),
        );

        // The sentinel bytes may appear *inside* an item without
        // terminating the array. Here each little-endian u16 item's high
        // byte is `00`, but decoding reads all three items because the
        // comparison only happens at the start of each item slot.
        final (insideValues, insideOffset) = codec.read(
          b(
            '010002000300'
            '00',
          ),
          0,
        );
        expect(insideValues, equals([1, 2, 3]));
        expect(insideOffset, 7);

        // But an item that *begins* with the sentinel bytes is
        // indistinguishable from the terminator, so decoding stops at that
        // boundary. Here `[1, 0]` would encode as `0100 0000`, and decoding
        // it back stops at the second item because it begins with `00`.
        final (leadingValues, leadingOffset) = codec.read(b('01000000'), 0);
        expect(leadingValues, equals([1]));
        expect(leadingOffset, 3);
      },
    );

    test(
      'skips a valid short tail when an optional sentinel is wider than the smallest item',
      () {
        // INVARIANT: under optional/omitted, the sentinel must be no wider
        // than the smallest possible item. Otherwise a trailing item shorter
        // than the sentinel is never read, because decoding stops as soon as
        // fewer bytes than the sentinel remain.
        final optional = SentinelArraySize(
          b('ffff'),
          strategy: SentinelCountStrategy.optional,
        );

        // A trailing single-byte `2a` item is silently dropped because only
        // one byte (< the 2-byte sentinel) remains at its boundary, so
        // decoding stops there without consuming it.
        final codec = getArrayCodec(getU8Codec(), size: optional);
        final (skippedValues, skippedOffset) = codec.read(b('01022a'), 0);
        expect(skippedValues, equals([1, 2]));
        expect(skippedOffset, 2);

        // With a sentinel no wider than the item, the same tail decodes
        // correctly.
        final safe = SentinelArraySize(
          b('ff'),
          strategy: SentinelCountStrategy.optional,
        );
        final safeCodec = getArrayCodec(getU8Codec(), size: safe);
        final (safeValues, safeOffset) = safeCodec.read(b('01022a'), 0);
        expect(safeValues, equals([1, 2, 42]));
        expect(safeOffset, 3);
      },
    );

    test('account for the sentinel in encoded size', () {
      // A required or optional sentinel adds its length to the size; an
      // omitted one does not.
      final encoder = getArrayEncoder(
        getU8Encoder(),
        size: SentinelArraySize(b('00')),
      );
      expect(getEncodedSize([1, 2], encoder), equals(3));
      final wideEncoder = getArrayEncoder(
        getU8Encoder(),
        size: SentinelArraySize(b('ffff')),
      );
      expect(getEncodedSize([1, 2], wideEncoder), equals(4));
      final omittedEncoder = getArrayEncoder(
        getU8Encoder(),
        size: SentinelArraySize(
          b('00'),
          strategy: SentinelCountStrategy.omitted,
        ),
      );
      expect(getEncodedSize([1, 2], omittedEncoder), equals(2));
    });

    test('encodes with u32 items', () {
      final codec = getArrayCodec(getU32Codec());
      expect(hex(codec.encode([1, 2])), equals('020000000100000002000000'));
    });

    test('rejects a missing size prefix', () {
      final codec = getArrayCodec(getU8Codec());
      expect(() => codec.decode(b('')), throwsA(anything));
    });

    test('throws on oversized prefix that would exhaust memory', () {
      final decoder = getArrayDecoder(
        getU8Decoder(),
        size: PrefixedArraySize(getU32Decoder()),
      );
      // u32 prefix says 0xFFFFFFFF (4294967295) items but only 0 bytes of
      // content follow. The decoder should fail when it runs out of bytes
      // trying to read items, not allocate billions of entries.
      expect(() => decoder.decode(b('ffffffff')), throwsA(anything));
    });
  });
}
