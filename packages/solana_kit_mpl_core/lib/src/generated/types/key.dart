// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum Key {
  uninitialized,
  assetV1,
  hashedAssetV1,
  pluginHeaderV1,
  pluginRegistryV1,
  collectionV1,
  groupV1,
}

Encoder<Key> getKeyEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (Key value) => value.index,
  );
}

Decoder<Key> getKeyDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => Key.values[value],
  );
}

Codec<Key, Key> getKeyCodec() {
  return combineCodec(getKeyEncoder(), getKeyDecoder());
}
