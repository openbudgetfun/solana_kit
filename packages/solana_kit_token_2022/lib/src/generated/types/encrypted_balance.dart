// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';


typedef EncryptedBalance = Uint8List;

Encoder<EncryptedBalance> getEncryptedBalanceEncoder() {
  return fixEncoderSize(getBytesEncoder(), 64);
}

Decoder<EncryptedBalance> getEncryptedBalanceDecoder() {
  return fixDecoderSize(getBytesDecoder(), 64);
}

Codec<EncryptedBalance, EncryptedBalance> getEncryptedBalanceCodec() {
  return combineCodec(getEncryptedBalanceEncoder(), getEncryptedBalanceDecoder());
}
