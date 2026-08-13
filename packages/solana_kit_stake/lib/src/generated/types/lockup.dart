// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './epoch.dart';
import './unix_timestamp.dart';

@immutable
class Lockup {
  const Lockup({
    required this.unixTimestamp,
    required this.epoch,
    required this.custodian,
  });

  final UnixTimestamp unixTimestamp;
  final Epoch epoch;
  final Address custodian;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lockup &&
          runtimeType == other.runtimeType &&
          unixTimestamp == other.unixTimestamp &&
          epoch == other.epoch &&
          custodian == other.custodian;

  @override
  int get hashCode => Object.hash(unixTimestamp, epoch, custodian);

  @override
  String toString() =>
      'Lockup(unixTimestamp: $unixTimestamp, epoch: $epoch, custodian: $custodian)';
}

Encoder<Lockup> getLockupEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('unixTimestamp', getUnixTimestampEncoder()),
    ('epoch', getEpochEncoder()),
    ('custodian', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Lockup value) => <String, Object?>{
      'unixTimestamp': value.unixTimestamp,
      'epoch': value.epoch,
      'custodian': value.custodian,
    },
  );
}

Decoder<Lockup> getLockupDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('unixTimestamp', getUnixTimestampDecoder()),
    ('epoch', getEpochDecoder()),
    ('custodian', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Lockup(
      unixTimestamp: map['unixTimestamp']! as UnixTimestamp,
      epoch: map['epoch']! as Epoch,
      custodian: map['custodian']! as Address,
    ),
  );
}

Codec<Lockup, Lockup> getLockupCodec() {
  return combineCodec(getLockupEncoder(), getLockupDecoder());
}
