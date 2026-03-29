/// Composite data-structure codecs for the Solana Kit Dart SDK.
///
/// Provides codecs for arrays, structs, tuples, unions, maps, sets, nullable
/// values, booleans, and other higher-level binary layouts.
///
/// <!-- {=typedUnionHelpersSection} -->
///
/// ### Typed Union Helpers
///
/// Prefer typed union helpers when a codec has a fixed, small number of variants.
/// They improve IDE type inference, make exhaustive matching easier, and reduce
/// unstructured casting in downstream code.
///
/// ```dart
/// import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
/// import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
///
/// void main() {
///   final codec = getUnion2Codec(
///     getU8Codec(),
///     getU32Codec(),
///     (bytes, offset) => bytes.length - offset > 1 ? 1 : 0,
///   );
///
///   final encoded = codec.encode(const Union2Variant1<int, int>(1000));
///   final decoded = codec.decode(encoded);
///
///   print(encoded);
///   print(decoded);
/// }
/// ```
///
/// Use these helpers when your wire format has “one of a few known cases” and you
/// want the Dart type system to preserve that fact.
///
/// <!-- {/typedUnionHelpersSection} -->
///
/// <!-- {=docsPatternMatchCodecSection} -->
///
/// ### Pattern-match codecs
///
/// Use pattern-match codecs when you need to choose a codec based on either the
/// incoming bytes or the value being encoded.
///
/// ```dart
/// import 'dart:typed_data';
///
/// import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
/// import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
///
/// void main() {
///   final codec = getPatternMatchCodec<num, int>([
///     ((value) => value < 256, (bytes) => bytes.length == 1, getU8Codec()),
///     ((value) => value >= 256, (bytes) => bytes.length == 2, getU16Codec()),
///   ]);
///
///   final encoded = codec.encode(513);
///   final decoded = codec.decode(Uint8List.fromList(encoded));
///
///   print(decoded);
/// }
/// ```
///
/// Reach for this when a layout cannot be described as a single fixed struct or
/// union discriminator alone.
///
/// <!-- {/docsPatternMatchCodecSection} -->
library;

export 'src/array.dart';
export 'src/assertions.dart';
export 'src/bit_array.dart';
export 'src/boolean.dart';
export 'src/bytes.dart';
export 'src/constant.dart';
export 'src/discriminated_union.dart';
export 'src/hidden_prefix.dart';
export 'src/hidden_suffix.dart';
export 'src/literal_union.dart';
export 'src/map.dart';
export 'src/nullable.dart';
export 'src/pattern_match.dart';
export 'src/predicate.dart';
export 'src/set.dart';
export 'src/struct.dart';
export 'src/tuple.dart';
export 'src/union.dart';
export 'src/unit.dart';
export 'src/utils.dart';
