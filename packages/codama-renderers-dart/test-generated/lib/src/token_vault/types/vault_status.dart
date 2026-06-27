// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum VaultStatus {
  active,
  paused,
  closed,
  frozen,
}

Encoder<VaultStatus> getVaultStatusEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (VaultStatus value) => value.index,
  );
}

Decoder<VaultStatus> getVaultStatusDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => VaultStatus.values[value],
  );
}

Codec<VaultStatus, VaultStatus> getVaultStatusCodec() {
  return combineCodec(getVaultStatusEncoder(), getVaultStatusDecoder());
}
