import 'dart:typed_data';

import 'package:solana_kit_privacy_rings/src/exception.dart';

/// Little-endian writer matching the TypeScript `Writer` in
/// `sdk-libs/ts/src/interface/internal.ts`.
class ByteWriter {
  final List<int> _bytes = [];

  /// Appends one byte.
  void u8(int value, String name) {
    if (value < 0 || value > 0xff) {
      throw PrivacyRingsException(
        '$name is outside 0..255',
        code: 'integer_range',
      );
    }
    _bytes.add(value);
  }

  /// Appends a little-endian u16.
  void u16(int value, String name) {
    if (value < 0 || value > 0xffff) {
      throw PrivacyRingsException(
        '$name is outside 0..65535',
        code: 'integer_range',
      );
    }
    _bytes
      ..add(value & 0xff)
      ..add((value >> 8) & 0xff);
  }

  /// Appends a little-endian u32.
  void u32(int value, String name) {
    if (value < 0 || value > 0xffffffff) {
      throw PrivacyRingsException(
        '$name is outside 0..4294967295',
        code: 'integer_range',
      );
    }
    _bytes
      ..add(value & 0xff)
      ..add((value >> 8) & 0xff)
      ..add((value >> 16) & 0xff)
      ..add((value >> 24) & 0xff);
  }

  /// Appends a little-endian u64.
  void u64(BigInt value, String name) {
    if (value.isNegative || value.bitLength > 64) {
      throw PrivacyRingsException(
        '$name is outside 0..2^64-1',
        code: 'integer_range',
      );
    }
    var rest = value;
    for (var i = 0; i < 8; i++) {
      _bytes.add((rest & BigInt.from(0xff)).toInt());
      rest >>= 8;
    }
  }

  /// Appends [value], which must be [length] bytes when [length] is set.
  void bytes(List<int> value, {int? length, String name = 'bytes'}) {
    if (length != null && value.length != length) {
      throw PrivacyRingsException(
        '$name must be $length bytes, got ${value.length}',
        code: 'invalid_length',
      );
    }
    _bytes.addAll(value);
  }

  /// Wincode option flag, then [write] when [value] is non-null.
  void option<T>(T? value, void Function(ByteWriter writer, T value) write) {
    u8(value == null ? 0 : 1, 'option');
    if (value != null) write(this, value);
  }

  /// The bytes written so far.
  Uint8List finish() => Uint8List.fromList(_bytes);
}

/// Little-endian reader matching the TypeScript `Reader`.
class ByteReader {
  /// Reads the buffer from the start.
  ByteReader(this._input);

  final Uint8List _input;
  int _offset = 0;

  /// Reads [length] bytes.
  Uint8List bytes(int length, String name) {
    final end = _offset + length;
    if (length < 0 || end > _input.length) {
      throw PrivacyRingsException(
        '$name overruns the buffer at offset $_offset',
        code: 'truncated',
      );
    }
    final value = Uint8List.sublistView(_input, _offset, end);
    _offset = end;
    return Uint8List.fromList(value);
  }

  /// Reads one byte.
  int u8(String name) => bytes(1, name)[0];

  /// Reads a 0 or 1 byte.
  bool flag(String name) {
    final value = u8(name);
    if (value != 0 && value != 1) {
      throw PrivacyRingsException(
        '$name is not a 0 or 1 flag',
        code: 'invalid_flag',
      );
    }
    return value == 1;
  }

  /// Reads a little-endian u16.
  int u16(String name) {
    final value = bytes(2, name);
    return value[0] | (value[1] << 8);
  }

  /// Reads a little-endian u32.
  int u32(String name) {
    final value = bytes(4, name);
    return value[0] | (value[1] << 8) | (value[2] << 16) | (value[3] << 24);
  }

  /// Reads a little-endian u64.
  BigInt u64(String name) {
    final value = bytes(8, name);
    var result = BigInt.zero;
    for (var i = 7; i >= 0; i--) {
      result = (result << 8) | BigInt.from(value[i]);
    }
    return result;
  }

  /// Reads an option flag and [read] when the flag is set.
  T? option<T>(T Function() read) {
    if (!flag('option')) return null;
    return read();
  }

  /// Throws when unread bytes remain.
  void done() {
    if (_offset != _input.length) {
      throw PrivacyRingsException(
        '${_input.length - _offset} trailing bytes',
        code: 'trailing_bytes',
      );
    }
  }
}

/// Copies [bytes] and requires [length].
Uint8List copyBytes(List<int> bytes, int length, String name) {
  if (bytes.length != length) {
    throw PrivacyRingsException(
      '$name must be $length bytes, got ${bytes.length}',
      code: 'invalid_length',
    );
  }
  return Uint8List.fromList(bytes);
}

/// Big-endian u32.
Uint8List u32be(int value) {
  final data = ByteData(4)..setUint32(0, value);
  return data.buffer.asUint8List();
}

/// Big-endian u64.
Uint8List u64be(int value) {
  if (value < 0) {
    throw PrivacyRingsException(
      'unsigned counter is negative',
      code: 'integer_range',
    );
  }
  final data = ByteData(8)..setUint64(0, value);
  return data.buffer.asUint8List();
}
