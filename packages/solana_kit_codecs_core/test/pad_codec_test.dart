import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('padLeftCodec', () {
    test('offsets and resizes the codec', () {
      final mock = getMockFixedCodec(size: 8);
      final codec = padLeftCodec(mock.codec, 4);
      final fixedCodec = codec as FixedSizeCodec<Object?, String>;

      expect(fixedCodec.fixedSize, equals(12));

      expectNewPreOffset(
        codec: fixedCodec,
        writeCalls: mock.writeCalls,
        readCalls: mock.readCalls,
        preOffset: 0,
        expectedNewPreOffset: 4,
      );
      expectNewPostOffset(
        codec: fixedCodec,
        preOffset: 0,
        expectedNewPostOffset: 12,
      );
    });

    test('does nothing with a zero offset', () {
      final mock = getMockFixedCodec(size: 8);
      final codec = padLeftCodec(mock.codec, 0);
      final fixedCodec = codec as FixedSizeCodec<Object?, String>;

      expect(fixedCodec.fixedSize, equals(8));

      expectNewPreOffset(
        codec: fixedCodec,
        writeCalls: mock.writeCalls,
        readCalls: mock.readCalls,
        preOffset: 0,
        expectedNewPreOffset: 0,
      );
      expectNewPostOffset(
        codec: fixedCodec,
        preOffset: 0,
        expectedNewPostOffset: 8,
      );
    });
  });

  group('padRightCodec', () {
    test('offsets and resizes the codec', () {
      final mock = getMockFixedCodec(size: 8);
      final codec = padRightCodec(mock.codec, 4);
      final fixedCodec = codec as FixedSizeCodec<Object?, String>;

      expect(fixedCodec.fixedSize, equals(12));

      expectNewPreOffset(
        codec: fixedCodec,
        writeCalls: mock.writeCalls,
        readCalls: mock.readCalls,
        preOffset: 0,
        expectedNewPreOffset: 0,
      );
      expectNewPostOffset(
        codec: fixedCodec,
        preOffset: 0,
        expectedNewPostOffset: 12,
      );
    });

    test('does nothing with a zero offset', () {
      final mock = getMockFixedCodec(size: 8);
      final codec = padRightCodec(mock.codec, 0);
      final fixedCodec = codec as FixedSizeCodec<Object?, String>;

      expect(fixedCodec.fixedSize, equals(8));

      expectNewPreOffset(
        codec: fixedCodec,
        writeCalls: mock.writeCalls,
        readCalls: mock.readCalls,
        preOffset: 0,
        expectedNewPreOffset: 0,
      );
      expectNewPostOffset(
        codec: fixedCodec,
        preOffset: 0,
        expectedNewPostOffset: 8,
      );
    });
  });
}
