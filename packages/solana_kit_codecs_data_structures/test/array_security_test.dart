import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('array decoder security boundaries', () {
    test(
      'rejects a missing size prefix instead of inventing an empty list',
      () {
        final decoder = getArrayDecoder(getU8Decoder());
        expect(() => decoder.decode(Uint8List(0)), throwsA(isA<SolanaError>()));
      },
    );

    test(
      'rejects zero-byte remainder items at construction (upstream v8.5.0)',
      () {
        // A zero-byte item can never advance a remainder decoder, so the
        // combination is now rejected when the decoder is built instead of
        // during the decode loop.
        expect(
          () => getArrayDecoder(
            FixedSizeDecoder<void>(
              fixedSize: 0,
              read: (bytes, offset) {
                throw StateError('must never be reached');
              },
            ),
            size: const RemainderArraySize(),
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode
                  .codecsUnexpectedZeroFixedSizeItemForArrayLikeSizeStrategy,
            ),
          ),
        );
      },
    );

    test(
      'rejects zero-byte sentinel items at construction (upstream v8.5.0)',
      () {
        expect(
          () => getArrayDecoder(
            FixedSizeDecoder<void>(
              fixedSize: 0,
              read: (bytes, offset) {
                throw StateError('must never be reached');
              },
            ),
            size: SentinelArraySize(Uint8List.fromList([0])),
          ),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode
                  .codecsUnexpectedZeroFixedSizeItemForArrayLikeSizeStrategy,
            ),
          ),
        );
      },
    );

    test(
      'rejects an attacker-sized unit count before allocating its items',
      () {
        var reads = 0;
        final unit = getUnitDecoder();
        final guardedUnit = FixedSizeDecoder<void>(
          fixedSize: 0,
          read: (bytes, offset) {
            // Four hostile bytes request over four billion list entries.
            if (++reads > 10) throw StateError('unbounded count expansion');
            return unit.read(bytes, offset);
          },
        );
        final decoder = getArrayDecoder(guardedUnit);

        expect(
          () => decoder.decode(Uint8List.fromList([255, 255, 255, 255])),
          throwsA(isA<SolanaError>()),
        );
        expect(reads, 0);
      },
    );

    test('rejects fractional size prefixes instead of truncating them', () {
      final decoder = getArrayDecoder(
        getU8Decoder(),
        size: PrefixedArraySize(getF64Decoder()),
      );
      final bytes = Uint8List.fromList([...getF64Encoder().encode(1.5), 42]);
      expect(() => decoder.decode(bytes), throwsA(isA<SolanaError>()));
    });

    test('allows callers to choose a smaller item limit', () {
      final decoder = getArrayDecoder(getU8Decoder(), maxItems: 1);
      expect(
        () => decoder.decode(Uint8List.fromList([2, 0, 0, 0, 1, 2])),
        throwsA(isA<SolanaError>()),
      );
    });

    test('applies the item limit to BigInt prefixes', () {
      final decoder = getArrayDecoder(
        getU8Decoder(),
        size: PrefixedArraySize(getU64Decoder()),
        maxItems: 1,
      );
      expect(
        () => decoder.decode(
          Uint8List.fromList([2, 0, 0, 0, 0, 0, 0, 0, 1, 2]),
        ),
        throwsA(isA<SolanaError>()),
      );
    });

    test('rejects a negative configured item limit', () {
      expect(
        () => getArrayDecoder(getU8Decoder(), maxItems: -1),
        throwsArgumentError,
      );
    });
  });
}
