// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class PermanentFreezeExecute {
  const PermanentFreezeExecute({
    required this.frozen,
  });

  final bool frozen;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermanentFreezeExecute &&
          runtimeType == other.runtimeType &&
          frozen == other.frozen;

  @override
  int get hashCode => frozen.hashCode;

  @override
  String toString() => 'PermanentFreezeExecute(frozen: $frozen)';
}

Encoder<PermanentFreezeExecute> getPermanentFreezeExecuteEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('frozen', getBooleanEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (PermanentFreezeExecute value) => <String, Object?>{
      'frozen': value.frozen,
    },
  );
}

Decoder<PermanentFreezeExecute> getPermanentFreezeExecuteDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('frozen', getBooleanDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        PermanentFreezeExecute(
          frozen: map['frozen']! as bool,
        ),
  );
}

Codec<PermanentFreezeExecute, PermanentFreezeExecute>
getPermanentFreezeExecuteCodec() {
  return combineCodec(
    getPermanentFreezeExecuteEncoder(),
    getPermanentFreezeExecuteDecoder(),
  );
}
