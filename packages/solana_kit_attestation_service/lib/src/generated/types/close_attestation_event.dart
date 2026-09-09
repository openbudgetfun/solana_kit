// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class CloseAttestationEvent {
  const CloseAttestationEvent({
    required this.discriminator,
    required this.schema,
    required this.attestationData,
  });

  final int discriminator;
  final Address schema;
  final Uint8List attestationData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloseAttestationEvent &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          schema == other.schema &&
          _listEquals(attestationData, other.attestationData);

  @override
  int get hashCode =>
      Object.hash(discriminator, schema, _listHashCode(attestationData));

  @override
  String toString() =>
      'CloseAttestationEvent(discriminator: $discriminator, schema: $schema, attestationData: $attestationData)';
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

Encoder<CloseAttestationEvent> getCloseAttestationEventEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('schema', getAddressEncoder()),
    (
      'attestationData',
      addEncoderSizePrefix(getBytesEncoder(), getU32Encoder()),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (CloseAttestationEvent value) => <String, Object?>{
      'discriminator': value.discriminator,
      'schema': value.schema,
      'attestationData': value.attestationData,
    },
  );
}

Decoder<CloseAttestationEvent> getCloseAttestationEventDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('schema', getAddressDecoder()),
    (
      'attestationData',
      addDecoderSizePrefix(getBytesDecoder(), getU32Decoder()),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CloseAttestationEvent(
          discriminator: map['discriminator']! as int,
          schema: map['schema']! as Address,
          attestationData: map['attestationData']! as Uint8List,
        ),
  );
}

Codec<CloseAttestationEvent, CloseAttestationEvent>
getCloseAttestationEventCodec() {
  return combineCodec(
    getCloseAttestationEventEncoder(),
    getCloseAttestationEventDecoder(),
  );
}
