/// String and base-encoding codecs for the Solana Kit Dart SDK.
///
/// Provides utf8, base16, base58, base64, base10, and generic baseX codecs
/// for Solana-facing textual and binary conversions.
///
/// <!-- {=docsStringCodecSection} -->
///
/// ## Encode base58 and UTF-8 strings
///
/// Use the string codecs for base58/base64/base16 conversions plus UTF-8 handling
/// when a Solana API crosses between bytes and text.
///
/// ```dart
/// import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
///
/// void main() {
///   final codec = getBase58Codec();
///
///   final encoded = codec.encode('11111111111111111111111111111111');
///   final decoded = codec.decode(encoded);
///
///   print(decoded);
/// }
/// ```
///
/// These codecs are especially useful for addresses, signatures, blockhashes, and
/// other values that appear as base-encoded strings at API boundaries.
///
/// For UTF-8 specifically, `getUtf8Codec()` preserves `@solana/kit`
/// compatibility by stripping decoded null characters. Prefer
/// `getStrictUtf8Codec()` or
/// `getUtf8Codec(nullCharacterMode: Utf8NullCharacterMode.reject)` when silent
/// null-byte stripping would be risky.
///
/// <!-- {/docsStringCodecSection} -->
///
/// <!-- {=compatibilityNoteCalloutSection|replace:"__COMPATIBILITY_BEHAVIOR__":"`getUtf8Codec()` keeps `@solana/kit` compatibility by stripping decoded null characters after UTF-8 decode."|replace:"__PREFERRED_BEHAVIOR__":"Prefer `getStrictUtf8Codec()` or `Utf8NullCharacterMode.reject` in new Dart code when silent data loss would be unsafe, and use `Utf8NullCharacterMode.preserve` when you need to surface null bytes explicitly."} -->
///
/// > **Compatibility note**
/// >
/// > **COMPATIBILITY_BEHAVIOR**
/// >
/// > **PREFERRED_BEHAVIOR**
///
/// <!-- {/compatibilityNoteCalloutSection} -->
library;

export 'src/assertions.dart';
export 'src/base10.dart';
export 'src/base16.dart';
export 'src/base58.dart';
export 'src/base64.dart';
export 'src/base_x.dart';
export 'src/base_x_reslice.dart';
export 'src/null_characters.dart';
export 'src/utf8.dart';
