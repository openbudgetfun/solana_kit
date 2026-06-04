// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

@immutable
class UpdatePlanData {
  const UpdatePlanData({
    required this.status,
    required this.endTs,
    required this.pullers,
    required this.metadataUri,
  });

  final int status;
  final BigInt endTs;
  final List<Address> pullers;
  final String metadataUri;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatePlanData &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          endTs == other.endTs &&
          pullers == other.pullers &&
          metadataUri == other.metadataUri;

  @override
  int get hashCode => Object.hash(status, endTs, pullers, metadataUri);

  @override
  String toString() =>
      'UpdatePlanData(status: $status, endTs: $endTs, pullers: $pullers, metadataUri: $metadataUri)';
}

Encoder<UpdatePlanData> getUpdatePlanDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('status', getU8Encoder()),
    ('endTs', getI64Encoder()),
    ('pullers', getArrayEncoder(getAddressEncoder(), size: FixedArraySize(4))),
    ('metadataUri', fixEncoderSize(getUtf8Encoder(), 128)),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdatePlanData value) => <String, Object?>{
      'status': value.status,
      'endTs': value.endTs,
      'pullers': value.pullers,
      'metadataUri': value.metadataUri,
    },
  );
}

Decoder<UpdatePlanData> getUpdatePlanDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('status', getU8Decoder()),
    ('endTs', getI64Decoder()),
    ('pullers', getArrayDecoder(getAddressDecoder(), size: FixedArraySize(4))),
    ('metadataUri', fixDecoderSize(getUtf8Decoder(), 128)),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UpdatePlanData(
      status: map['status']! as int,
      endTs: map['endTs']! as BigInt,
      pullers: map['pullers']! as List<Address>,
      metadataUri: map['metadataUri']! as String,
    ),
  );
}

Codec<UpdatePlanData, UpdatePlanData> getUpdatePlanDataCodec() {
  return combineCodec(getUpdatePlanDataEncoder(), getUpdatePlanDataDecoder());
}
