import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('offsetCodec', () {
    group('with relative offsets', () {
      test('keeps the same pre-offset', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 4);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(preOffset: (scope) => scope.preOffset),
        );
        expectNewPreOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          writeCalls: mock.writeCalls,
          readCalls: mock.readCalls,
          preOffset: 3,
          expectedNewPreOffset: 3,
        );
      });

      test('keeps the same post-offset', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 4);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(postOffset: (scope) => scope.postOffset),
        );
        expectNewPostOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          preOffset: 3,
          expectedNewPostOffset: 7,
        );
      });

      test('doubles the pre-offset', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 4);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(preOffset: (scope) => scope.preOffset * 2),
        );
        expectNewPreOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          writeCalls: mock.writeCalls,
          readCalls: mock.readCalls,
          preOffset: 3,
          expectedNewPreOffset: 6,
        );
      });

      test('doubles the post-offset', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 1);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(postOffset: (scope) => scope.postOffset * 2),
        );
        expectNewPostOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          preOffset: 3,
          expectedNewPostOffset: 8,
        );
      });

      test('goes forwards and restores the original offset', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 2);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(
            preOffset: (scope) => scope.preOffset + 2,
            postOffset: (scope) => scope.preOffset,
          ),
        );
        expectNewPreOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          writeCalls: mock.writeCalls,
          readCalls: mock.readCalls,
          preOffset: 3,
          expectedNewPreOffset: 5,
        );
        expectNewPostOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          preOffset: 3,
          expectedNewPostOffset: 3,
        );
      });

      test('goes backwards and restores the original offset', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 2);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(
            preOffset: (scope) => scope.preOffset - 3,
            postOffset: (scope) => scope.preOffset,
          ),
        );
        expectNewPreOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          writeCalls: mock.writeCalls,
          readCalls: mock.readCalls,
          preOffset: 5,
          expectedNewPreOffset: 2,
        );
        expectNewPostOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          preOffset: 5,
          expectedNewPostOffset: 5,
        );
      });
    });

    group('with absolute offsets', () {
      test('sets an absolute pre-offset', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 4);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(preOffset: (_) => 6),
        );
        expectNewPreOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          writeCalls: mock.writeCalls,
          readCalls: mock.readCalls,
          preOffset: 3,
          expectedNewPreOffset: 6,
        );
      });

      test('sets an absolute post-offset', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 1);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(postOffset: (_) => 8),
        );
        expectNewPostOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          preOffset: 3,
          expectedNewPostOffset: 8,
        );
      });
    });

    group('with wrapped relative offsets', () {
      test('uses the provided pre-offset as-is if within the byte range', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 4);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(
            preOffset: (scope) => scope.wrapBytes(scope.preOffset + 2),
          ),
        );
        expectNewPreOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          writeCalls: mock.writeCalls,
          readCalls: mock.readCalls,
          preOffset: 3,
          expectedNewPreOffset: 5,
        );
      });

      test('uses the provided post-offset as-is if within the byte range', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 4);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(
            postOffset: (scope) => scope.wrapBytes(scope.postOffset + 2),
          ),
        );
        expectNewPostOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          preOffset: 3,
          expectedNewPostOffset: 9,
        );
      });

      test('wraps the pre-offset if it is below the byte range', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 4);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(
            preOffset: (scope) => scope.wrapBytes(scope.preOffset - 12),
          ),
        );
        expectNewPreOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          writeCalls: mock.writeCalls,
          readCalls: mock.readCalls,
          preOffset: 3,
          expectedNewPreOffset: 1,
        );
      });

      test('wraps the post-offset if it is below the byte range', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 4);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(
            postOffset: (scope) => scope.wrapBytes(scope.postOffset - 12),
          ),
        );
        expectNewPostOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          preOffset: 3,
          expectedNewPostOffset: 5,
        );
      });

      test('wraps the pre-offset if it is above the byte range', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 4);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(
            preOffset: (scope) => scope.wrapBytes(scope.preOffset + 12),
          ),
        );
        expectNewPreOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          writeCalls: mock.writeCalls,
          readCalls: mock.readCalls,
          preOffset: 3,
          expectedNewPreOffset: 5,
        );
      });

      test('wraps the post-offset if it is above the byte range', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 4);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(
            postOffset: (scope) => scope.wrapBytes(scope.postOffset + 12),
          ),
        );
        expectNewPostOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          preOffset: 3,
          expectedNewPostOffset: 9,
        );
      });

      test('always uses a zero offset if the byte array is empty', () {
        final mock = getMockFixedCodec(size: 0, innerSize: 0);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(
            preOffset: (scope) => scope.wrapBytes(scope.preOffset + 42),
            postOffset: (scope) => scope.wrapBytes(scope.postOffset - 42),
          ),
        );
        expectNewPreOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          writeCalls: mock.writeCalls,
          readCalls: mock.readCalls,
          preOffset: 0,
          expectedNewPreOffset: 0,
        );
        expectNewPostOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          preOffset: 0,
          expectedNewPostOffset: 0,
        );
      });
    });

    group('with wrapped absolute offsets', () {
      test('uses the provided pre-offset as-is if within the byte range', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 4);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(preOffset: (scope) => scope.wrapBytes(5)),
        );
        expectNewPreOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          writeCalls: mock.writeCalls,
          readCalls: mock.readCalls,
          preOffset: 3,
          expectedNewPreOffset: 5,
        );
      });

      test('uses the provided post-offset as-is if within the byte range', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 4);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(postOffset: (scope) => scope.wrapBytes(9)),
        );
        expectNewPostOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          preOffset: 3,
          expectedNewPostOffset: 9,
        );
      });

      test('wraps the pre-offset if it is below the byte range', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 4);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(preOffset: (scope) => scope.wrapBytes(-19)),
        );
        expectNewPreOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          writeCalls: mock.writeCalls,
          readCalls: mock.readCalls,
          preOffset: 3,
          expectedNewPreOffset: 1,
        );
      });

      test('wraps the post-offset if it is below the byte range', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 4);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(postOffset: (scope) => scope.wrapBytes(-15)),
        );
        expectNewPostOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          preOffset: 3,
          expectedNewPostOffset: 5,
        );
      });

      test('wraps the pre-offset if it is above the byte range', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 4);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(preOffset: (scope) => scope.wrapBytes(105)),
        );
        expectNewPreOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          writeCalls: mock.writeCalls,
          readCalls: mock.readCalls,
          preOffset: 3,
          expectedNewPreOffset: 5,
        );
      });

      test('wraps the post-offset if it is above the byte range', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 4);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(postOffset: (scope) => scope.wrapBytes(109)),
        );
        expectNewPostOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          preOffset: 3,
          expectedNewPostOffset: 9,
        );
      });

      test('always uses a zero offset if the byte array is empty', () {
        final mock = getMockFixedCodec(size: 0, innerSize: 0);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(
            preOffset: (scope) => scope.wrapBytes(42),
            postOffset: (scope) => scope.wrapBytes(-42),
          ),
        );
        expectNewPreOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          writeCalls: mock.writeCalls,
          readCalls: mock.readCalls,
          preOffset: 0,
          expectedNewPreOffset: 0,
        );
        expectNewPostOffset(
          codec: codec as FixedSizeCodec<Object?, Object?>,
          preOffset: 0,
          expectedNewPostOffset: 0,
        );
      });
    });

    group('with offset overflow', () {
      test('throws an error if the pre-offset is negative', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 0);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(preOffset: (_) => -1),
        );

        expect(
          () => codec.encode(42),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.codecsOffsetOutOfRange,
            ),
          ),
        );
        expect(
          () => codec.decode(Uint8List(10)),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.codecsOffsetOutOfRange,
            ),
          ),
        );
      });

      test('throws an error if the pre-offset is above the byte array length',
          () {
        final mock = getMockFixedCodec(size: 10, innerSize: 0);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(preOffset: (_) => 11),
        );

        expect(
          () => codec.encode(42),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.codecsOffsetOutOfRange,
            ),
          ),
        );
        expect(
          () => codec.decode(Uint8List(10)),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.codecsOffsetOutOfRange,
            ),
          ),
        );
      });

      test(
        'does not throw an error if the pre-offset is equal to the '
        'byte array length',
        () {
          final mock = getMockFixedCodec(size: 10, innerSize: 0);
          final codec = offsetCodec(
            mock.codec,
            OffsetConfig(preOffset: (_) => 10),
          );

          expect(() => codec.encode(42), returnsNormally);
          expect(() => codec.decode(Uint8List(10)), returnsNormally);
        },
      );

      test('throws an error if the post-offset is negative', () {
        final mock = getMockFixedCodec(size: 10, innerSize: 0);
        final codec = offsetCodec(
          mock.codec,
          OffsetConfig(postOffset: (_) => -1),
        );

        expect(
          () => codec.encode(42),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.codecsOffsetOutOfRange,
            ),
          ),
        );
        expect(
          () => codec.decode(Uint8List(10)),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.codecsOffsetOutOfRange,
            ),
          ),
        );
      });

      test(
        'throws an error if the post-offset is above the byte array length',
        () {
          final mock = getMockFixedCodec(size: 10, innerSize: 0);
          final codec = offsetCodec(
            mock.codec,
            OffsetConfig(postOffset: (_) => 11),
          );

          expect(
            () => codec.encode(42),
            throwsA(
              isA<SolanaError>().having(
                (e) => e.code,
                'code',
                SolanaErrorCode.codecsOffsetOutOfRange,
              ),
            ),
          );
          expect(
            () => codec.decode(Uint8List(10)),
            throwsA(
              isA<SolanaError>().having(
                (e) => e.code,
                'code',
                SolanaErrorCode.codecsOffsetOutOfRange,
              ),
            ),
          );
        },
      );

      test(
        'does not throw an error if the post-offset is equal to the '
        'byte array length',
        () {
          final mock = getMockFixedCodec(size: 10, innerSize: 0);
          final codec = offsetCodec(
            mock.codec,
            OffsetConfig(postOffset: (_) => 10),
          );

          expect(() => codec.encode(42), returnsNormally);
          expect(() => codec.decode(Uint8List(10)), returnsNormally);
        },
      );
    });
  });
}
