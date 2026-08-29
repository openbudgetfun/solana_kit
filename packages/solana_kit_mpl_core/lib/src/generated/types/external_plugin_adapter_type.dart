// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum ExternalPluginAdapterType {
  lifecycleHook,
  oracle,
  appData,
  linkedLifecycleHook,
  linkedAppData,
  dataSection,
  agentIdentity,
}

Encoder<ExternalPluginAdapterType> getExternalPluginAdapterTypeEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (ExternalPluginAdapterType value) => value.index,
  );
}

Decoder<ExternalPluginAdapterType> getExternalPluginAdapterTypeDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) =>
        ExternalPluginAdapterType.values[value],
  );
}

Codec<ExternalPluginAdapterType, ExternalPluginAdapterType>
getExternalPluginAdapterTypeCodec() {
  return combineCodec(
    getExternalPluginAdapterTypeEncoder(),
    getExternalPluginAdapterTypeDecoder(),
  );
}
