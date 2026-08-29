// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class UpdateDelegate {
  const UpdateDelegate({
    required this.additionalDelegates,
  });

  final List<Address> additionalDelegates;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateDelegate &&
          runtimeType == other.runtimeType &&
          _listEquals(additionalDelegates, other.additionalDelegates);

  @override
  int get hashCode => _listHashCode(additionalDelegates);

  @override
  String toString() =>
      'UpdateDelegate(additionalDelegates: $additionalDelegates)';
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

int _listHashCode<T>(List<T>? a) {
  if (a == null) return 0;
  return Object.hashAll(a);
}

Encoder<UpdateDelegate> getUpdateDelegateEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'additionalDelegates',
      getArrayEncoder(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateDelegate value) => <String, Object?>{
      'additionalDelegates': value.additionalDelegates,
    },
  );
}

Decoder<UpdateDelegate> getUpdateDelegateDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('additionalDelegates', getArrayDecoder(getAddressDecoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UpdateDelegate(
      additionalDelegates: map['additionalDelegates']! as List<Address>,
    ),
  );
}

Codec<UpdateDelegate, UpdateDelegate> getUpdateDelegateCodec() {
  return combineCodec(getUpdateDelegateEncoder(), getUpdateDelegateDecoder());
}
