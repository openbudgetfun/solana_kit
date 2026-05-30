// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './epoch.dart';
import './unix_timestamp.dart';

@immutable
class LockupCheckedParams {
  const LockupCheckedParams({required this.unixTimestamp, required this.epoch});

  final UnixTimestamp? unixTimestamp;
  final Epoch? epoch;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LockupCheckedParams &&
          runtimeType == other.runtimeType &&
          unixTimestamp == other.unixTimestamp &&
          epoch == other.epoch;

  @override
  int get hashCode => Object.hash(unixTimestamp, epoch);

  @override
  String toString() =>
      'LockupCheckedParams(unixTimestamp: $unixTimestamp, epoch: $epoch)';
}

Encoder<LockupCheckedParams> getLockupCheckedParamsEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'unixTimestamp',
      getNullableEncoder<UnixTimestamp>(getUnixTimestampEncoder()),
    ),
    ('epoch', getNullableEncoder<Epoch>(getEpochEncoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (LockupCheckedParams value) => <String, Object?>{
      'unixTimestamp': value.unixTimestamp,
      'epoch': value.epoch,
    },
  );
}

Decoder<LockupCheckedParams> getLockupCheckedParamsDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    (
      'unixTimestamp',
      getNullableDecoder<UnixTimestamp>(getUnixTimestampDecoder()),
    ),
    ('epoch', getNullableDecoder<Epoch>(getEpochDecoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        LockupCheckedParams(
          unixTimestamp: map['unixTimestamp'] as UnixTimestamp?,
          epoch: map['epoch'] as Epoch?,
        ),
  );
}

Codec<LockupCheckedParams, LockupCheckedParams> getLockupCheckedParamsCodec() {
  return combineCodec(
    getLockupCheckedParamsEncoder(),
    getLockupCheckedParamsDecoder(),
  );
}
