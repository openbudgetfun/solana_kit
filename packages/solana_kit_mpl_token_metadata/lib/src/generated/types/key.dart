// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum Key {
  uninitialized,
  editionV1,
  masterEditionV1,
  reservationListV1,
  metadataV1,
  reservationListV2,
  masterEditionV2,
  editionMarker,
  useAuthorityRecord,
  collectionAuthorityRecord,
  tokenOwnedEscrow,
  tokenRecord,
  metadataDelegate,
  editionMarkerV2,
  holderDelegate,
}

Encoder<Key> getKeyEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (Key value) => value.index,
  );
}

Decoder<Key> getKeyDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => Key.values[value],
  );
}

Codec<Key, Key> getKeyCodec() {
  return combineCodec(getKeyEncoder(), getKeyDecoder());
}
