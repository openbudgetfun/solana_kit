import 'dart:typed_data';

/// Configuration for number codecs.
///
/// The [endian] parameter controls the byte order used when encoding and
/// decoding multi-byte numbers. Defaults to [Endian.little].
class NumberCodecConfig {
  /// Creates a [NumberCodecConfig] with the given [endian] byte order.
  const NumberCodecConfig({this.endian = Endian.little});

  /// The byte order to use when encoding and decoding multi-byte numbers.
  final Endian endian;
}
