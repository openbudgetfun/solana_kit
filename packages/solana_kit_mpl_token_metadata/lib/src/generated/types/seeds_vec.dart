// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class SeedsVec {
  const SeedsVec({
    required this.seeds,
  });

  final List<Uint8List> seeds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeedsVec &&
          runtimeType == other.runtimeType &&
          _listEquals(seeds, other.seeds);

  @override
  int get hashCode => _listHashCode(seeds);

  @override
  String toString() => 'SeedsVec(seeds: $seeds)';
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final left = a[i];
    final right = b[i];
    if (left is List<Object?> && right is List<Object?>) {
      if (!_listEquals(left, right)) return false;
    } else if (left != right) {
      return false;
    }
  }
  return true;
}

Object? _deepHash(Object? value) {
  if (value is List<Object?>) {
    return Object.hashAll(value.map(_deepHash));
  }
  return value;
}

int _listHashCode<T>(List<T>? a) {
  if (a == null) return 0;
  return Object.hashAll(a.map(_deepHash));
}

Encoder<SeedsVec> getSeedsVecEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'seeds',
      getArrayEncoder(
        transformEncoder(
          addEncoderSizePrefix(getBytesEncoder(), getU32Encoder()),
          (Uint8List value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (SeedsVec value) => <String, Object?>{
      'seeds': value.seeds,
    },
  );
}

Decoder<SeedsVec> getSeedsVecDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    (
      'seeds',
      getArrayDecoder(addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => SeedsVec(
      seeds: map['seeds']! as List<Uint8List>,
    ),
  );
}

Codec<SeedsVec, SeedsVec> getSeedsVecCodec() {
  return combineCodec(getSeedsVecEncoder(), getSeedsVecDecoder());
}
