// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum PluginType {
  royalties,
  freezeDelegate,
  burnDelegate,
  transferDelegate,
  updateDelegate,
  permanentFreezeDelegate,
  attributes,
  permanentTransferDelegate,
  permanentBurnDelegate,
  edition,
  masterEdition,
  addBlocker,
  immutableMetadata,
  verifiedCreators,
  autograph,
  bubblegumV2,
  freezeExecute,
  permanentFreezeExecute,
  groups,
}

Encoder<PluginType> getPluginTypeEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (PluginType value) => value.index,
  );
}

Decoder<PluginType> getPluginTypeDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => PluginType.values[value],
  );
}

Codec<PluginType, PluginType> getPluginTypeCodec() {
  return combineCodec(getPluginTypeEncoder(), getPluginTypeDecoder());
}
