import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:test/test.dart';

void main() {
  // A simple 1-byte number codec used for testing transforms.
  final numberCodec = FixedSizeCodec<int, int>(
    fixedSize: 1,
    read: (bytes, offset) => (bytes[offset], offset + 1),
    write: (value, bytes, offset) {
      bytes[offset] = value;
      return offset + 1;
    },
  );

  group('transformCodec', () {
    test('can loosen the codec input with a map', () {
      // From Codec<int, int> to Codec<Object, int>.
      // Accept Object (int or String), always decode as int.
      final mappedCodec = transformCodec<int, Object, int, int>(
        numberCodec,
        (value) => value is int ? value : (value as String).length,
      );

      final bytesA = mappedCodec.encode(42);
      expect(mappedCodec.decode(bytesA), equals(42));

      final bytesB = mappedCodec.encode('Hello world');
      expect(mappedCodec.decode(bytesB), equals(11));
    });

    test('can map both the input and output of a codec', () {
      // From Codec<int, int> to Codec<Object, String>.
      final mappedCodec = transformCodec<int, Object, int, String>(
        numberCodec,
        (value) => value is int ? value : (value as String).length,
        (value, _, __) => 'x' * value,
      );

      final bytesA = mappedCodec.encode(42);
      expect(mappedCodec.decode(bytesA), equals('x' * 42));

      final bytesB = mappedCodec.encode('Hello world');
      expect(mappedCodec.decode(bytesB), equals('x' * 11));
    });

    test('can map the input and output of a codec to the same type', () {
      // From Codec<int, int> to Codec<String, String>.
      final mappedCodec = transformCodec<int, String, int, String>(
        numberCodec,
        (value) => value.length,
        (value, _, __) => 'x' * value,
      );

      final bytesA = mappedCodec.encode('42');
      expect(mappedCodec.decode(bytesA), equals('xx'));

      final bytesB = mappedCodec.encode('Hello world');
      expect(mappedCodec.decode(bytesB), equals('xxxxxxxxxxx'));
    });

    test('can wrap a codec type in a map using a map', () {
      // From Codec<int, int> to Codec<Map<String, int>, Map<String, int>>.
      final mappedCodec =
          transformCodec<int, Map<String, int>, int, Map<String, int>>(
            numberCodec,
            (value) => value['value']!,
            (value, _, __) => {'value': value},
          );

      final bytes = mappedCodec.encode({'value': 42});
      expect(mappedCodec.decode(bytes), equals({'value': 42}));
    });

    test('can map a codec to loosen its input by providing default values', () {
      // Strict codec that requires both 'discriminator' and 'label'.
      final strictCodec =
          FixedSizeCodec<Map<String, Object>, Map<String, Object>>(
            fixedSize: 2,
            read: (bytes, offset) => (
              {
                'discriminator': bytes[offset],
                'label': 'x' * bytes[offset + 1],
              },
              offset + 2,
            ),
            write: (value, bytes, offset) {
              bytes[offset] = value['discriminator']! as int;
              bytes[offset + 1] = (value['label']! as String).length;
              return offset + 2;
            },
          );

      final bytesA = strictCodec.encode({
        'discriminator': 5,
        'label': 'Hello world',
      });
      expect(
        strictCodec.decode(bytesA),
        equals({'discriminator': 5, 'label': 'xxxxxxxxxxx'}),
      );

      // Loose codec: discriminator is optional with default 42.
      final looseCodec =
          transformCodec<
            Map<String, Object>,
            Map<String, Object>,
            Map<String, Object>,
            Map<String, Object>
          >(
            strictCodec,
            (value) => {
              'discriminator': 42, // default
              ...value,
            },
          );

      // With explicit discriminator.
      final bytesB = looseCodec.encode({
        'discriminator': 5,
        'label': 'Hello world',
      });
      expect(
        looseCodec.decode(bytesB),
        equals({'discriminator': 5, 'label': 'xxxxxxxxxxx'}),
      );

      // With implicit discriminator (uses default 42).
      final bytesC = looseCodec.encode({'label': 'Hello world'});
      expect(
        looseCodec.decode(bytesC),
        equals({'discriminator': 42, 'label': 'xxxxxxxxxxx'}),
      );
    });

    test('can loosen a tuple codec', () {
      // A codec for (int, String) tuples.
      final tupleCodec = FixedSizeCodec<(int, String), (int, String)>(
        fixedSize: 2,
        read: (bytes, offset) =>
            ((bytes[offset], 'x' * bytes[offset + 1]), offset + 2),
        write: (value, bytes, offset) {
          bytes[offset] = value.$1;
          bytes[offset + 1] = value.$2.length;
          return offset + 2;
        },
      );

      final bytesA = tupleCodec.encode((42, 'Hello world'));
      expect(tupleCodec.decode(bytesA), equals((42, 'xxxxxxxxxxx')));

      // Map to loosen the tuple: first element can be null.
      final mappedCodec =
          transformCodec<
            (int, String),
            (int?, String),
            (int, String),
            (int, String)
          >(tupleCodec, (value) => (value.$1 ?? value.$2.length, value.$2));

      final bytesB = mappedCodec.encode((null, 'Hello world'));
      expect(mappedCodec.decode(bytesB), equals((11, 'xxxxxxxxxxx')));

      final bytesC = mappedCodec.encode((42, 'Hello world'));
      expect(mappedCodec.decode(bytesC), equals((42, 'xxxxxxxxxxx')));
    });
  });

  group('transformEncoder', () {
    test('can map an encoder to another encoder', () {
      final encoderA = FixedSizeEncoder<int>(
        fixedSize: 1,
        write: (value, bytes, offset) {
          bytes[offset] = value;
          return offset + 1;
        },
      );

      final encoderB = transformEncoder<int, String>(
        encoderA,
        (value) => value.length,
      );

      expect(encoderB, isA<FixedSizeEncoder<String>>());
      expect((encoderB as FixedSizeEncoder).fixedSize, equals(1));
      expect(encoderB.encode('helloworld'), equals(Uint8List.fromList([10])));
    });

    test('preserves variable-size properties', () {
      final encoderA = VariableSizeEncoder<int>(
        getSizeFromValue: (_) => 1,
        write: (value, bytes, offset) {
          bytes[offset] = value;
          return offset + 1;
        },
        maxSize: 10,
      );

      final encoderB = transformEncoder<int, String>(
        encoderA,
        (value) => value.length,
      );

      expect(encoderB, isA<VariableSizeEncoder<String>>());
      expect((encoderB as VariableSizeEncoder).maxSize, equals(10));
    });
  });

  group('transformDecoder', () {
    test('can map a decoder to another decoder', () {
      final decoder = FixedSizeDecoder<int>(
        fixedSize: 1,
        read: (bytes, offset) => (bytes[offset], offset + 1),
      );

      final decoderB = transformDecoder<int, String>(
        decoder,
        (value, _, __) => 'x' * value,
      );

      expect(decoderB, isA<FixedSizeDecoder<String>>());
      expect((decoderB as FixedSizeDecoder).fixedSize, equals(1));
      expect(decoderB.decode(Uint8List.fromList([10])), equals('xxxxxxxxxx'));
    });

    test('preserves variable-size properties', () {
      final decoder = VariableSizeDecoder<int>(
        read: (bytes, offset) => (bytes[offset], offset + 1),
        maxSize: 10,
      );

      final decoderB = transformDecoder<int, String>(
        decoder,
        (value, _, __) => 'x' * value,
      );

      expect(decoderB, isA<VariableSizeDecoder<String>>());
      expect((decoderB as VariableSizeDecoder).maxSize, equals(10));
    });
  });
}
