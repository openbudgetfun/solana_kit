// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class EventAuthority {
  const EventAuthority();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAuthority && runtimeType == other.runtimeType && true;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'EventAuthority()';
}

Encoder<EventAuthority> getEventAuthorityEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[]);

  return transformEncoder(
    structEncoder,
    (EventAuthority value) => <String, Object?>{},
  );
}

Decoder<EventAuthority> getEventAuthorityDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => EventAuthority(),
  );
}

Codec<EventAuthority, EventAuthority> getEventAuthorityCodec() {
  return combineCodec(getEventAuthorityEncoder(), getEventAuthorityDecoder());
}

Account<EventAuthority> decodeEventAuthority(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getEventAuthorityDecoder());
}
