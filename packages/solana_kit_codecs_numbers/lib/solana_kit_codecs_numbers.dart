/// Numeric codecs for the Solana Kit Dart SDK.
///
/// Includes little-endian integer and floating-point codecs commonly used in
/// Solana instruction data and account layouts.
///
/// <!-- {=docsNumberCodecSection} -->
///
/// ## Encode fixed-width numbers
///
/// Use the number codecs when your binary format needs explicit integer widths and
/// endianness.
///
/// ```dart
/// import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
///
/// void main() {
///   final codec = getU64Codec();
///
///   final encoded = codec.encode(BigInt.from(1_000_000));
///   final decoded = codec.decode(encoded);
///
///   print(decoded);
/// }
/// ```
///
/// Reach for these codecs in instruction layouts, account state structs, and any
/// wire format that needs exact byte-for-byte compatibility.
///
/// <!-- {/docsNumberCodecSection} -->
library;

export 'src/assertions.dart';
export 'src/common.dart';
export 'src/f32.dart';
export 'src/f64.dart';
export 'src/i128.dart';
export 'src/i16.dart';
export 'src/i32.dart';
export 'src/i64.dart';
export 'src/i8.dart';
export 'src/short_u16.dart';
export 'src/u128.dart';
export 'src/u16.dart';
export 'src/u32.dart';
export 'src/u64.dart';
export 'src/u8.dart';
export 'src/utils.dart';
