// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class DataSectionUpdateInfo {
  const DataSectionUpdateInfo();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataSectionUpdateInfo &&
          runtimeType == other.runtimeType &&
          true;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'DataSectionUpdateInfo()';
}

Encoder<DataSectionUpdateInfo> getDataSectionUpdateInfoEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[]);

  return transformEncoder(
    structEncoder,
    (DataSectionUpdateInfo value) => <String, Object?>{},
  );
}

Decoder<DataSectionUpdateInfo> getDataSectionUpdateInfoDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        DataSectionUpdateInfo(),
  );
}

Codec<DataSectionUpdateInfo, DataSectionUpdateInfo>
getDataSectionUpdateInfoCodec() {
  return combineCodec(
    getDataSectionUpdateInfoEncoder(),
    getDataSectionUpdateInfoDecoder(),
  );
}
