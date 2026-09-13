import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:test/test.dart';

Uint8List _b(String hex) {
  final matches = RegExp('.{1,2}').allMatches(hex.toLowerCase());
  return Uint8List.fromList(
    matches.map((m) => int.parse(m.group(0)!, radix: 16)).toList(),
  );
}

/// A fixed-size u8 encoder used to exercise the tap wrappers.
FixedSizeEncoder<num> _u8Encoder() => FixedSizeEncoder<num>(
  fixedSize: 1,
  write: (value, bytes, offset) {
    bytes[offset] = value.toInt();
    return offset + 1;
  },
);

/// A fixed-size u8 decoder used to exercise the tap wrappers.
FixedSizeDecoder<int> _u8Decoder() => FixedSizeDecoder<int>(
  fixedSize: 1,
  read: (bytes, offset) {
    return (bytes[offset], offset + 1);
  },
);

/// A fixed-size u8 codec used to exercise the codec-level tap wrappers.
FixedSizeCodec<num, int> _u8Codec() => FixedSizeCodec<num, int>(
  fixedSize: 1,
  write: (value, bytes, offset) {
    bytes[offset] = value.toInt();
    return offset + 1;
  },
  read: (bytes, offset) {
    return (bytes[offset], offset + 1);
  },
);

/// A variable-size, length-prefixed bytes encoder, used to check that the tap
/// wrappers preserve size characteristics.
VariableSizeEncoder<Uint8List> _bytesEncoder() =>
    VariableSizeEncoder<Uint8List>(
      getSizeFromValue: (value) => value.length + 1,
      maxSize: 256,
      write: (value, bytes, offset) {
        bytes[offset] = value.length;
        bytes.setRange(offset + 1, offset + 1 + value.length, value);
        return offset + 1 + value.length;
      },
    );

/// The matching variable-size decoder for [_bytesEncoder].
VariableSizeDecoder<Uint8List> _bytesDecoder() =>
    VariableSizeDecoder<Uint8List>(
      maxSize: 256,
      read: (bytes, offset) {
        final length = bytes[offset];
        return (
          Uint8List.sublistView(bytes, offset + 1, offset + 1 + length),
          offset + 1 + length,
        );
      },
    );

/// A variable-size codec combining [_bytesEncoder] and [_bytesDecoder].
VariableSizeCodec<Uint8List, Uint8List> _bytesCodec() =>
    VariableSizeCodec<Uint8List, Uint8List>(
      getSizeFromValue: (value) => value.length + 1,
      maxSize: 256,
      write: (value, bytes, offset) {
        bytes[offset] = value.length;
        bytes.setRange(offset + 1, offset + 1 + value.length, value);
        return offset + 1 + value.length;
      },
      read: (bytes, offset) {
        final length = bytes[offset];
        return (
          Uint8List.sublistView(bytes, offset + 1, offset + 1 + length),
          offset + 1 + length,
        );
      },
    );

void main() {
  group('tapEncoder', () {
    test('observes the value before it is written', () {
      final seen = <num>[];
      final encoder = tapEncoder<num>(_u8Encoder(), seen.add);

      final bytes = encoder.encode(42);

      expect(seen, equals(<num>[42]));
      expect(bytes, equals(_b('2a')));
    });

    test('preserves fixed-size characteristics', () {
      final encoder = tapEncoder<num>(_u8Encoder(), (_) {});
      expect(encoder, isA<FixedSizeEncoder<num>>());
      expect((encoder as FixedSizeEncoder<num>).fixedSize, equals(1));
      expect(isFixedSize(encoder), isTrue);
    });

    test('preserves variable-size characteristics', () {
      final seen = <Uint8List>[];
      final encoder = tapEncoder<Uint8List>(_bytesEncoder(), seen.add);

      expect(encoder, isA<VariableSizeEncoder<Uint8List>>());
      expect(getEncodedSize(_b('0102'), encoder), equals(3));

      final bytes = encoder.encode(_b('0102'));
      expect(seen, hasLength(1));
      expect(bytes, equals(_b('020102')));
    });

    test('propagates a thrown error and aborts the write', () {
      final encoder = tapEncoder<num>(_u8Encoder(), (value) {
        throw StateError('rejected $value');
      });

      expect(() => encoder.encode(1), throwsStateError);
    });
  });

  group('tapDecoder', () {
    test('observes the decoded value', () {
      final seen = <int>[];
      final decoder = tapDecoder<int>(_u8Decoder(), seen.add);

      expect(decoder.decode(_b('2a')), equals(42));
      expect(seen, equals(<int>[42]));
    });

    test('preserves fixed-size characteristics', () {
      final decoder = tapDecoder<int>(_u8Decoder(), (_) {});
      expect(decoder, isA<FixedSizeDecoder<int>>());
      expect((decoder as FixedSizeDecoder<int>).fixedSize, equals(1));
    });

    test('preserves variable-size characteristics', () {
      final seen = <Uint8List>[];
      final decoder = tapDecoder<Uint8List>(_bytesDecoder(), seen.add);

      expect(decoder, isA<VariableSizeDecoder<Uint8List>>());
      expect((decoder as VariableSizeDecoder<Uint8List>).maxSize, equals(256));

      expect(decoder.decode(_b('020102')), equals(_b('0102')));
      expect(seen, hasLength(1));
    });

    test('propagates a thrown error and aborts the read', () {
      final decoder = tapDecoder<int>(_u8Decoder(), (value) {
        if (value > 1) throw StateError('bad value');
      });

      expect(() => decoder.decode(_b('02')), throwsStateError);
    });
  });

  group('tapCodec', () {
    test('observes both directions and round-trips', () {
      final encoded = <num>[];
      final decoded = <int>[];
      final codec = tapCodec<num, int>(_u8Codec(), encoded.add, decoded.add);

      final bytes = codec.encode(7);
      expect(encoded, equals(<num>[7]));

      expect(codec.decode(bytes), equals(7));
      expect(decoded, equals(<int>[7]));
    });

    test('leaves reading untouched when no decode tap is given', () {
      final codec = tapCodec<num, int>(_u8Codec(), (_) {});
      expect(codec.decode(_b('05')), equals(5));
    });

    test('preserves variable-size characteristics', () {
      final encoded = <Uint8List>[];
      final decoded = <Uint8List>[];
      final codec = tapCodec<Uint8List, Uint8List>(
        _bytesCodec(),
        encoded.add,
        decoded.add,
      );

      final variableCodec = codec as VariableSizeCodec<Uint8List, Uint8List>;
      expect(variableCodec.maxSize, equals(256));
      expect(variableCodec.getSizeFromValue(_b('0102')), equals(3));

      final bytes = codec.encode(_b('0102'));
      expect(encoded, hasLength(1));
      expect(codec.decode(bytes), equals(_b('0102')));
      expect(decoded, hasLength(1));
    });

    test('skips the decode tap for a variable-size codec when omitted', () {
      final codec = tapCodec<Uint8List, Uint8List>(_bytesCodec(), (_) {});
      expect(codec.decode(_b('020102')), equals(_b('0102')));
    });
  });

  group('tapEncoderBytes', () {
    test('observes the written span', () {
      final spans = <(String, int, int)>[];
      final encoded = tapEncoderBytes<num>(_u8Encoder(), (bytes, pre, post) {
        spans.add((bytes.map((b) => b.toRadixString(16)).join(), pre, post));
      }).encode(9);

      expect(spans, equals(<(String, int, int)>[('9', 0, 1)]));
      expect(encoded, equals(_b('09')));
    });

    test('preserves variable-size characteristics', () {
      final spans = <(int, int)>[];
      final encoder = tapEncoderBytes<Uint8List>(
        _bytesEncoder(),
        (_, pre, post) => spans.add((pre, post)),
      );

      expect(encoder, isA<VariableSizeEncoder<Uint8List>>());
      expect((encoder as VariableSizeEncoder<Uint8List>).maxSize, equals(256));

      expect(encoder.encode(_b('0102')), equals(_b('020102')));
      expect(spans, equals(<(int, int)>[(0, 3)]));
    });
  });

  group('tapDecoderBytes', () {
    test('observes the bytes before they are read', () {
      final offsets = <int>[];
      final decoder = tapDecoderBytes<int>(
        _u8Decoder(),
        (bytes, offset) => offsets.add(offset),
      );

      expect(decoder.decode(_b('2a')), equals(42));
      expect(offsets, equals(<int>[0]));
    });

    test('preserves variable-size characteristics', () {
      final offsets = <int>[];
      final decoder = tapDecoderBytes<Uint8List>(
        _bytesDecoder(),
        (_, offset) => offsets.add(offset),
      );

      expect(decoder, isA<VariableSizeDecoder<Uint8List>>());
      expect((decoder as VariableSizeDecoder<Uint8List>).maxSize, equals(256));

      expect(decoder.decode(_b('020102')), equals(_b('0102')));
      expect(offsets, equals(<int>[0]));
    });
  });

  group('tapCodecBytes', () {
    test('observes both directions and round-trips', () {
      final encodeSpans = <(int, int)>[];
      final decodeOffsets = <int>[];
      final codec = tapCodecBytes<num, int>(
        _u8Codec(),
        (_, pre, post) => encodeSpans.add((pre, post)),
        (_, offset) => decodeOffsets.add(offset),
      );

      final bytes = codec.encode(3);
      expect(encodeSpans, equals(<(int, int)>[(0, 1)]));

      expect(codec.decode(bytes), equals(3));
      expect(decodeOffsets, equals(<int>[0]));
    });

    test('leaves reading untouched when no decode tap is given', () {
      final codec = tapCodecBytes<num, int>(_u8Codec(), (_, _, _) {});
      expect(codec.decode(_b('06')), equals(6));
    });

    test('preserves variable-size characteristics', () {
      final spans = <(int, int)>[];
      final offsets = <int>[];
      final codec = tapCodecBytes<Uint8List, Uint8List>(
        _bytesCodec(),
        (_, pre, post) => spans.add((pre, post)),
        (_, offset) => offsets.add(offset),
      );

      final variableCodec = codec as VariableSizeCodec<Uint8List, Uint8List>;
      expect(variableCodec.maxSize, equals(256));

      final bytes = codec.encode(_b('0102'));
      expect(spans, equals(<(int, int)>[(0, 3)]));
      expect(codec.decode(bytes), equals(_b('0102')));
      expect(offsets, equals(<int>[0]));
    });

    test('skips the decode tap for a variable-size codec when omitted', () {
      final codec = tapCodecBytes<Uint8List, Uint8List>(
        _bytesCodec(),
        (_, _, _) {},
      );
      expect(codec.decode(_b('020102')), equals(_b('0102')));
    });
  });
}
