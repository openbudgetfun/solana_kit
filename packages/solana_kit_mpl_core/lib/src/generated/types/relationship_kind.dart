// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum RelationshipKind {
  collection,
  childGroup,
  parentGroup,
  asset,
}

Encoder<RelationshipKind> getRelationshipKindEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (RelationshipKind value) => value.index,
  );
}

Decoder<RelationshipKind> getRelationshipKindDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => RelationshipKind.values[value],
  );
}

Codec<RelationshipKind, RelationshipKind> getRelationshipKindCodec() {
  return combineCodec(
    getRelationshipKindEncoder(),
    getRelationshipKindDecoder(),
  );
}
