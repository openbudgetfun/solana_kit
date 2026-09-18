// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

sealed class TokenMetadataField {
  const TokenMetadataField();
}

final class TokenMetadataFieldName extends TokenMetadataField {
  const TokenMetadataFieldName();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TokenMetadataFieldName;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'TokenMetadataField.Name()';
}

final class TokenMetadataFieldSymbol extends TokenMetadataField {
  const TokenMetadataFieldSymbol();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TokenMetadataFieldSymbol;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'TokenMetadataField.Symbol()';
}

final class TokenMetadataFieldUri extends TokenMetadataField {
  const TokenMetadataFieldUri();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TokenMetadataFieldUri;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'TokenMetadataField.Uri()';
}

final class TokenMetadataFieldKey extends TokenMetadataField {
  const TokenMetadataFieldKey(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenMetadataFieldKey && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'TokenMetadataField.Key($value)';
}

Encoder<TokenMetadataField> getTokenMetadataFieldEncoder() {
  return transformEncoder<Map<String, Object?>, TokenMetadataField>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (1, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (2, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (
        3,
        transformEncoder<String, Map<String, Object?>>(
          addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
          (Map<String, Object?> map) => map['value']! as String,
        ),
      ),
    ], size: getU8Encoder()),
    (TokenMetadataField value) => switch (value) {
      TokenMetadataFieldName() => <String, Object?>{'__kind': 0},
      TokenMetadataFieldSymbol() => <String, Object?>{'__kind': 1},
      TokenMetadataFieldUri() => <String, Object?>{'__kind': 2},
      TokenMetadataFieldKey(value: final value) => <String, Object?>{
        '__kind': 3,
        'value': value,
      },
    },
  );
}

Decoder<TokenMetadataField> getTokenMetadataFieldDecoder() {
  return transformDecoder<Map<String, Object?>, TokenMetadataField>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder(<(String, Decoder<Object?>)>[]),
          (Map<String, Object?> map, Uint8List bytes, int offset) =>
              <String, Object?>{},
        ),
      ),
      (
        1,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder(<(String, Decoder<Object?>)>[]),
          (Map<String, Object?> map, Uint8List bytes, int offset) =>
              <String, Object?>{},
        ),
      ),
      (
        2,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder(<(String, Decoder<Object?>)>[]),
          (Map<String, Object?> map, Uint8List bytes, int offset) =>
              <String, Object?>{},
        ),
      ),
      (
        3,
        transformDecoder<String, Map<String, Object?>>(
          addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
          (String value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return const TokenMetadataFieldName();
        case 1:
          return const TokenMetadataFieldSymbol();
        case 2:
          return const TokenMetadataFieldUri();
        case 3:
          return TokenMetadataFieldKey(map['value']! as String);
      }
      throw StateError(
        'Unsupported TokenMetadataField discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<TokenMetadataField, TokenMetadataField> getTokenMetadataFieldCodec() {
  return combineCodec(
    getTokenMetadataFieldEncoder(),
    getTokenMetadataFieldDecoder(),
  );
}
