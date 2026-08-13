// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';


typedef DecryptableBalance = Uint8List;

Encoder<DecryptableBalance> getDecryptableBalanceEncoder() {
  return fixEncoderSize(getBytesEncoder(), 36);
}

Decoder<DecryptableBalance> getDecryptableBalanceDecoder() {
  return fixDecoderSize(getBytesDecoder(), 36);
}

Codec<DecryptableBalance, DecryptableBalance> getDecryptableBalanceCodec() {
  return combineCodec(getDecryptableBalanceEncoder(), getDecryptableBalanceDecoder());
}
