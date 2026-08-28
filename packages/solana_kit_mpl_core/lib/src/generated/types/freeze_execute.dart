// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class FreezeExecute {
  const FreezeExecute({
    required this.frozen,
  });

  final bool frozen;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreezeExecute &&
          runtimeType == other.runtimeType &&
          frozen == other.frozen;

  @override
  int get hashCode => frozen.hashCode;

  @override
  String toString() => 'FreezeExecute(frozen: $frozen)';
}

Encoder<FreezeExecute> getFreezeExecuteEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('frozen', getBooleanEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (FreezeExecute value) => <String, Object?>{
      'frozen': value.frozen,
    },
  );
}

Decoder<FreezeExecute> getFreezeExecuteDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('frozen', getBooleanDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => FreezeExecute(
      frozen: map['frozen']! as bool,
    ),
  );
}

Codec<FreezeExecute, FreezeExecute> getFreezeExecuteCodec() {
  return combineCodec(getFreezeExecuteEncoder(), getFreezeExecuteDecoder());
}
