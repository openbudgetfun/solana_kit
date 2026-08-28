// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class PermanentFreezeDelegate {
  const PermanentFreezeDelegate({
    required this.frozen,
  });

  final bool frozen;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermanentFreezeDelegate &&
          runtimeType == other.runtimeType &&
          frozen == other.frozen;

  @override
  int get hashCode => frozen.hashCode;

  @override
  String toString() => 'PermanentFreezeDelegate(frozen: $frozen)';
}

Encoder<PermanentFreezeDelegate> getPermanentFreezeDelegateEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('frozen', getBooleanEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (PermanentFreezeDelegate value) => <String, Object?>{
      'frozen': value.frozen,
    },
  );
}

Decoder<PermanentFreezeDelegate> getPermanentFreezeDelegateDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('frozen', getBooleanDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        PermanentFreezeDelegate(
          frozen: map['frozen']! as bool,
        ),
  );
}

Codec<PermanentFreezeDelegate, PermanentFreezeDelegate>
getPermanentFreezeDelegateCodec() {
  return combineCodec(
    getPermanentFreezeDelegateEncoder(),
    getPermanentFreezeDelegateDecoder(),
  );
}
