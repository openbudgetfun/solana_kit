// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';


typedef FixedName = String;

Encoder<FixedName> getFixedNameEncoder() {
  return fixEncoderSize(getUtf8Encoder(), 4, allowTruncation: false);
}

Decoder<FixedName> getFixedNameDecoder() {
  return fixDecoderSize(getUtf8Decoder(), 4);
}

Codec<FixedName, FixedName> getFixedNameCodec() {
  return combineCodec(getFixedNameEncoder(), getFixedNameDecoder());
}
