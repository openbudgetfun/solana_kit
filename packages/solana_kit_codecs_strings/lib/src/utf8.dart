import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_strings/src/null_characters.dart';

/// Options controlling UTF-8 encoding and decoding.
///
/// These mirror the options upstream `@solana/kit` added to its UTF-8 codec.
/// `ignoreBOM` defaults to the same value as upstream, but `fatal` and
/// `removeNullCharacters` default to the stricter behavior, because decoding
/// account or instruction data leniently loses information silently. Upstream
/// defaults are `fatal: false` (malformed bytes become `U+FFFD`) and
/// `removeNullCharacters: true` (null characters are stripped). To match
/// upstream, ask for them explicitly:
///
/// ```dart
/// final decoder = getUtf8Decoder(
///   const Utf8CodecConfig(
///     fatal: false,
///     ignoreBOM: false,
///     removeNullCharacters: true,
///   ),
/// );
/// ```
class Utf8CodecConfig {
  /// Creates UTF-8 codec options.
  const Utf8CodecConfig({
    this.fatal = true,
    this.ignoreBOM = false,
    this.removeNullCharacters = false,
  });

  /// Whether malformed input is rejected instead of replaced.
  ///
  /// When `true`, decoding bytes that are not well-formed UTF-8 throws a
  /// [FormatException], and encoding a string containing lone surrogates
  /// throws one too. When `false`, decoding replaces malformed byte sequences
  /// with `U+FFFD` and encoding replaces lone surrogates the same way.
  ///
  /// Upstream defaults this to `false`; this port defaults to `true`.
  final bool fatal;

  /// Whether a leading byte order mark (`U+FEFF`) is preserved.
  ///
  /// When `true` the mark stays as the first character of the decoded string.
  /// When `false` it is stripped, matching both Dart's `Utf8Decoder` and
  /// upstream's default.
  final bool ignoreBOM;

  /// Whether null characters (`U+0000`) are stripped from decoded strings.
  ///
  /// When `true` they are removed, which suits wire formats that pad
  /// fixed-size strings with nulls. When `false` they are preserved, so the
  /// decoded value reflects the bytes exactly.
  ///
  /// Upstream defaults this to `true`; this port defaults to `false`.
  final bool removeNullCharacters;
}

/// Returns an encoder for UTF-8 strings.
///
/// This encoder serializes strings using UTF-8 encoding. The encoded output
/// contains as many bytes as needed to represent the string.
///
/// With the default [Utf8CodecConfig.fatal], a string containing lone
/// surrogates throws a [FormatException] instead of being encoded with
/// `U+FFFD` replacements.
///
/// For more details, see [getUtf8Codec].
VariableSizeEncoder<String> getUtf8Encoder([
  Utf8CodecConfig config = const Utf8CodecConfig(),
]) {
  return VariableSizeEncoder<String>(
    getSizeFromValue: (value) => convert.utf8.encode(value).length,
    write: (value, bytes, offset) {
      if (config.fatal) {
        _assertIsWellFormedUtf8String(value);
      }
      final encoded = Uint8List.fromList(convert.utf8.encode(value));
      bytes.setAll(offset, encoded);
      return offset + encoded.length;
    },
  );
}

/// Returns a decoder for UTF-8 strings.
///
/// This decoder deserializes UTF-8 encoded strings from a byte array. It reads
/// all available bytes starting from the given offset.
///
/// By default it rejects malformed UTF-8, preserves a leading byte order mark,
/// and preserves null (`\u0000`) characters. Pass a [Utf8CodecConfig] to ask
/// for upstream `@solana/kit`'s lenient behavior instead.
///
/// For more details, see [getUtf8Codec].
VariableSizeDecoder<String> getUtf8Decoder([
  Utf8CodecConfig config = const Utf8CodecConfig(),
]) {
  return VariableSizeDecoder<String>(
    read: (bytes, offset) {
      final slice = bytes.sublist(offset);
      var value = convert.utf8.decode(slice, allowMalformed: !config.fatal);

      // Dart's `Utf8Decoder` strips a leading byte order mark, which is the
      // default for both this port and upstream. Put it back when the caller
      // asked to keep it.
      if (config.ignoreBOM &&
          _startsWithByteOrderMark(slice) &&
          (value.isEmpty || value.codeUnitAt(0) != 0xfeff)) {
        value = '\ufeff$value';
      }
      if (config.removeNullCharacters) {
        value = removeNullCharacters(value);
      }
      return (value, bytes.length);
    },
  );
}

/// Returns a codec for encoding and decoding UTF-8 strings.
///
/// This codec serializes strings using UTF-8 encoding. The encoded output
/// contains as many bytes as needed to represent the string.
///
/// For more details, see [getUtf8Encoder] and [getUtf8Decoder].
VariableSizeCodec<String, String> getUtf8Codec([
  Utf8CodecConfig config = const Utf8CodecConfig(),
]) {
  return combineCodec(
    getUtf8Encoder(config),
    getUtf8Decoder(config),
  ) as VariableSizeCodec<String, String>;
}

/// Returns `true` if [bytes] begins with the UTF-8 encoding of `U+FEFF`.
bool _startsWithByteOrderMark(Uint8List bytes) =>
    bytes.length >= 3 &&
    bytes[0] == 0xef &&
    bytes[1] == 0xbb &&
    bytes[2] == 0xbf;

/// Throws a [FormatException] if [value] contains an unpaired surrogate.
///
/// Dart's `utf8.encode` substitutes `U+FFFD` for lone surrogates rather than
/// reporting them, so the check has to happen before encoding.
void _assertIsWellFormedUtf8String(String value) {
  for (var index = 0; index < value.length; index++) {
    final unit = value.codeUnitAt(index);
    if (unit >= 0xd800 && unit <= 0xdbff) {
      final next = index + 1 < value.length ? value.codeUnitAt(index + 1) : 0;
      if (next < 0xdc00 || next > 0xdfff) {
        throw FormatException(
          'Malformed UTF-8 string: unpaired high surrogate at index $index',
          value,
          index,
        );
      }
      index++;
    } else if (unit >= 0xdc00 && unit <= 0xdfff) {
      throw FormatException(
        'Malformed UTF-8 string: unpaired low surrogate at index $index',
        value,
        index,
      );
    }
  }
}
