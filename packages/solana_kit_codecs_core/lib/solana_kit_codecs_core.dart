/// Core codec interfaces and composition helpers for the Solana Kit Dart SDK.
///
/// Use this library when you need foundational `Encoder`, `Decoder`, and
/// `Codec` abstractions plus size, padding, transform, and sentinel helpers.
///
/// <!-- {=docsCoreCodecSection} -->
///
/// ## Compose core codecs
///
/// Use `solana_kit_codecs_core` when you need to adapt, wrap, or combine lower-
/// level encoders and decoders.
///
/// ```dart
/// import 'dart:typed_data';
///
/// import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
/// import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
///
/// void main() {
///   final codec = addCodecSentinel(getU8Codec(), Uint8List.fromList([255]));
///
///   final encoded = codec.encode(42);
///   final decoded = codec.decode(encoded);
///
///   print(encoded);
///   print(decoded);
/// }
/// ```
///
/// These helpers are the glue layer between simple primitive codecs and the more
/// specialized Solana-facing structures built on top of them.
///
/// <!-- {/docsCoreCodecSection} -->
library;

export 'src/add_codec_sentinel.dart';
export 'src/add_codec_size_prefix.dart';
export 'src/assertions.dart';
export 'src/bytes.dart';
export 'src/codec.dart';
export 'src/codec_utils.dart';
export 'src/combine_codec.dart';
export 'src/decoder_entire_byte_array.dart';
export 'src/fix_codec_size.dart';
export 'src/offset_codec.dart';
export 'src/pad_codec.dart';
export 'src/resize_codec.dart';
export 'src/reverse_codec.dart';
export 'src/transform_codec.dart';
