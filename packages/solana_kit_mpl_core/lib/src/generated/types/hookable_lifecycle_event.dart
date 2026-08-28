// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum HookableLifecycleEvent {
  create,
  transfer,
  burn,
  update,
  execute,
}

Encoder<HookableLifecycleEvent> getHookableLifecycleEventEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (HookableLifecycleEvent value) => value.index,
  );
}

Decoder<HookableLifecycleEvent> getHookableLifecycleEventDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) =>
        HookableLifecycleEvent.values[value],
  );
}

Codec<HookableLifecycleEvent, HookableLifecycleEvent>
getHookableLifecycleEventCodec() {
  return combineCodec(
    getHookableLifecycleEventEncoder(),
    getHookableLifecycleEventDecoder(),
  );
}
