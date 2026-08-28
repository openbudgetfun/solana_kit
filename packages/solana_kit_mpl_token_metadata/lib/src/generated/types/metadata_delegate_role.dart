// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum MetadataDelegateRole {
  authorityItem,
  collection,
  use,
  data,
  programmableConfig,
  dataItem,
  collectionItem,
  programmableConfigItem,
}

Encoder<MetadataDelegateRole> getMetadataDelegateRoleEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (MetadataDelegateRole value) => value.index,
  );
}

Decoder<MetadataDelegateRole> getMetadataDelegateRoleDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) =>
        MetadataDelegateRole.values[value],
  );
}

Codec<MetadataDelegateRole, MetadataDelegateRole>
getMetadataDelegateRoleCodec() {
  return combineCodec(
    getMetadataDelegateRoleEncoder(),
    getMetadataDelegateRoleDecoder(),
  );
}
