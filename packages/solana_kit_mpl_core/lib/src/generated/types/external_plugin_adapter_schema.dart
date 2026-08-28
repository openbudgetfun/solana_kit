// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum ExternalPluginAdapterSchema {
  binary,
  json,
  msgPack,
}

Encoder<ExternalPluginAdapterSchema> getExternalPluginAdapterSchemaEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (ExternalPluginAdapterSchema value) => value.index,
  );
}

Decoder<ExternalPluginAdapterSchema> getExternalPluginAdapterSchemaDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) =>
        ExternalPluginAdapterSchema.values[value],
  );
}

Codec<ExternalPluginAdapterSchema, ExternalPluginAdapterSchema>
getExternalPluginAdapterSchemaCodec() {
  return combineCodec(
    getExternalPluginAdapterSchemaEncoder(),
    getExternalPluginAdapterSchemaDecoder(),
  );
}
