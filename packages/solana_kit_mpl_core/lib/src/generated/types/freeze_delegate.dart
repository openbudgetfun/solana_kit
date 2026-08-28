// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class FreezeDelegate {
  const FreezeDelegate({
    required this.frozen,
  });

  final bool frozen;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreezeDelegate &&
          runtimeType == other.runtimeType &&
          frozen == other.frozen;

  @override
  int get hashCode => frozen.hashCode;

  @override
  String toString() => 'FreezeDelegate(frozen: $frozen)';
}

Encoder<FreezeDelegate> getFreezeDelegateEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('frozen', getBooleanEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (FreezeDelegate value) => <String, Object?>{
      'frozen': value.frozen,
    },
  );
}

Decoder<FreezeDelegate> getFreezeDelegateDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('frozen', getBooleanDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => FreezeDelegate(
      frozen: map['frozen']! as bool,
    ),
  );
}

Codec<FreezeDelegate, FreezeDelegate> getFreezeDelegateCodec() {
  return combineCodec(getFreezeDelegateEncoder(), getFreezeDelegateDecoder());
}
