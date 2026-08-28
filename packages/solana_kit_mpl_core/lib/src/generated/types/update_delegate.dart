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
          additionalDelegates == other.additionalDelegates;

  @override
  int get hashCode => additionalDelegates.hashCode;

  @override
  String toString() =>
      'UpdateDelegate(additionalDelegates: $additionalDelegates)';
}

Encoder<UpdateDelegate> getUpdateDelegateEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'additionalDelegates',
      getArrayEncoder<Address>(
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
