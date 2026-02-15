import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:test/test.dart';

/// A simple hex codec for testing.
///
/// Encodes a hex string to bytes, decodes bytes to a hex string.
final VariableSizeCodec<String, String> base16Codec =
    VariableSizeCodec<String, String>(
      getSizeFromValue: (value) => (value.length / 2).ceil(),
      write: (value, bytes, offset) {
        final matches = RegExp('.{1,2}').allMatches(value.toLowerCase());
        final hexBytes = matches
            .map((m) => int.parse(m.group(0)!, radix: 16))
            .toList();
        bytes.setAll(offset, hexBytes);
        return offset + hexBytes.length;
      },
      read: (bytes, offset) {
        final value = bytes
            .sublist(offset)
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join();
        return (value, bytes.length);
      },
    );

/// Encode a hex string to [Uint8List].
Uint8List b(String hex) => base16Codec.encode(hex);

/// Decode a [Uint8List] to hex string.
String h(Uint8List bytes) => base16Codec.decode(bytes);

/// Creates a fixed-size mock codec for testing.
///
/// Returns a record with the codec and tracking lists for verifying calls.
({
  FixedSizeCodec<Object?, String> codec,
  List<(Object? value, Uint8List bytes, int offset)> writeCalls,
  List<(Uint8List bytes, int offset)> readCalls,
})
getMockFixedCodec({
  required int size,
  int? innerSize,
  String defaultValue = '',
  int Function(Object?, Uint8List, int)? writeOverride,
}) {
  final effectiveInnerSize = innerSize ?? size;

  final writeCalls = <(Object? value, Uint8List bytes, int offset)>[];
  final readCalls = <(Uint8List bytes, int offset)>[];

  int writeImpl(Object? value, Uint8List bytes, int offset) {
    writeCalls.add((value, bytes, offset));
    if (writeOverride != null) {
      return writeOverride(value, bytes, offset);
    }
    return offset + effectiveInnerSize;
  }

  (String, int) readImpl(Uint8List bytes, int offset) {
    readCalls.add((bytes, offset));
    return (defaultValue, offset + effectiveInnerSize);
  }

  final codec = FixedSizeCodec<Object?, String>(
    fixedSize: size,
    write: writeImpl,
    read: readImpl,
  );

  return (codec: codec, writeCalls: writeCalls, readCalls: readCalls);
}

/// Creates a variable-size mock codec for testing.
///
/// Returns a record with the codec, tracking lists, and a function to
/// set the size returned by getSizeFromValue.
({
  VariableSizeCodec<Object?, String> codec,
  List<(Object? value, Uint8List bytes, int offset)> writeCalls,
  List<(Uint8List bytes, int offset)> readCalls,
  void Function(int size) setSizeFromValue,
})
getMockVariableCodec({
  int initialSize = 0,
  int? innerSize,
  String defaultValue = '',
  int Function(Object?, Uint8List, int)? writeOverride,
}) {
  final effectiveInnerSize = innerSize ?? 0;
  var currentSize = initialSize;

  final writeCalls = <(Object? value, Uint8List bytes, int offset)>[];
  final readCalls = <(Uint8List bytes, int offset)>[];

  int writeImpl(Object? value, Uint8List bytes, int offset) {
    writeCalls.add((value, bytes, offset));
    if (writeOverride != null) {
      return writeOverride(value, bytes, offset);
    }
    return offset + effectiveInnerSize;
  }

  (String, int) readImpl(Uint8List bytes, int offset) {
    readCalls.add((bytes, offset));
    return (defaultValue, offset + effectiveInnerSize);
  }

  final codec = VariableSizeCodec<Object?, String>(
    getSizeFromValue: (_) => currentSize,
    write: writeImpl,
    read: readImpl,
  );

  return (
    codec: codec,
    writeCalls: writeCalls,
    readCalls: readCalls,
    setSizeFromValue: (int size) {
      currentSize = size;
    },
  );
}

/// Verifies that encoding and decoding with an offset codec uses the
/// expected new pre-offset for the inner codec.
void expectNewPreOffset({
  required FixedSizeCodec<Object?, Object?> codec,
  required List<(Object? value, Uint8List bytes, int offset)> writeCalls,
  required List<(Uint8List bytes, int offset)> readCalls,
  required int preOffset,
  required int expectedNewPreOffset,
}) {
  final bytes = Uint8List(codec.fixedSize);

  writeCalls.clear();
  codec.write(null, bytes, preOffset);
  expect(
    writeCalls.last.$3,
    equals(expectedNewPreOffset),
    reason:
        'Expected write pre-offset $expectedNewPreOffset, '
        'got ${writeCalls.last.$3}',
  );

  readCalls.clear();
  codec.read(bytes, preOffset);
  expect(
    readCalls.last.$2,
    equals(expectedNewPreOffset),
    reason:
        'Expected read pre-offset $expectedNewPreOffset, '
        'got ${readCalls.last.$2}',
  );
}

/// Verifies that encoding and decoding with an offset codec produces the
/// expected new post-offset.
void expectNewPostOffset({
  required FixedSizeCodec<Object?, Object?> codec,
  required int preOffset,
  required int expectedNewPostOffset,
}) {
  final bytes = Uint8List(codec.fixedSize);

  final writeResult = codec.write(null, bytes, preOffset);
  expect(
    writeResult,
    equals(expectedNewPostOffset),
    reason:
        'Expected write post-offset $expectedNewPostOffset, '
        'got $writeResult',
  );

  final (_, readOffset) = codec.read(bytes, preOffset);
  expect(
    readOffset,
    equals(expectedNewPostOffset),
    reason:
        'Expected read post-offset $expectedNewPostOffset, '
        'got $readOffset',
  );
}
