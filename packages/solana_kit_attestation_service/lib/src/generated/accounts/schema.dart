// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

@immutable
class Schema {
  const Schema({
    required this.discriminator,
    required this.credential,
    required this.name,
    required this.description,
    required this.layout,
    required this.fieldNames,
    required this.isPaused,
    required this.version,
  });

  final int discriminator;
  final Address credential;
  final Uint8List name;
  final Uint8List description;
  final Uint8List layout;
  final Uint8List fieldNames;
  final bool isPaused;
  final int version;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Schema &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          credential == other.credential &&
          name == other.name &&
          description == other.description &&
          layout == other.layout &&
          fieldNames == other.fieldNames &&
          isPaused == other.isPaused &&
          version == other.version;

  @override
  int get hashCode => Object.hash(
    discriminator,
    credential,
    name,
    description,
    layout,
    fieldNames,
    isPaused,
    version,
  );

  @override
  String toString() =>
      'Schema(discriminator: $discriminator, credential: $credential, name: $name, description: $description, layout: $layout, fieldNames: $fieldNames, isPaused: $isPaused, version: $version)';
}

Encoder<Schema> getSchemaEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('credential', getAddressEncoder()),
    ('name', addEncoderSizePrefix(getBytesEncoder(), getU32Encoder())),
    ('description', addEncoderSizePrefix(getBytesEncoder(), getU32Encoder())),
    ('layout', addEncoderSizePrefix(getBytesEncoder(), getU32Encoder())),
    ('fieldNames', addEncoderSizePrefix(getBytesEncoder(), getU32Encoder())),
    ('isPaused', getBooleanEncoder()),
    ('version', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Schema value) => <String, Object?>{
      'discriminator': value.discriminator,
      'credential': value.credential,
      'name': value.name,
      'description': value.description,
      'layout': value.layout,
      'fieldNames': value.fieldNames,
      'isPaused': value.isPaused,
      'version': value.version,
    },
  );
}

Decoder<Schema> getSchemaDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('credential', getAddressDecoder()),
    ('name', addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
    ('description', addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
    ('layout', addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
    ('fieldNames', addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
    ('isPaused', getBooleanDecoder()),
    ('version', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
      'codecDescription': 'schema account decoder',
      'expected': expected,
      'bytesLength': bytesLength,
    });
  }

  (Schema, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      Schema(
        discriminator: map['discriminator']! as int,
        credential: map['credential']! as Address,
        name: map['name']! as Uint8List,
        description: map['description']! as Uint8List,
        layout: map['layout']! as Uint8List,
        fieldNames: map['fieldNames']! as Uint8List,
        isPaused: map['isPaused']! as bool,
        version: map['version']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<Schema>(
      fixedSize: structDecoder.fixedSize,
      read: (bytes, offset) {
        final bytesLength = bytes.length - offset;
        if (bytesLength < structDecoder.fixedSize) {
          throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
        }
        return readTopLevel(bytes, offset);
      },
    ),
    VariableSizeDecoder<Map<String, Object?>>() => VariableSizeDecoder<Schema>(
      read: readTopLevel,
      maxSize: structDecoder.maxSize,
    ),
  };
}

Codec<Schema, Schema> getSchemaCodec() {
  return combineCodec(getSchemaEncoder(), getSchemaDecoder());
}

Account<Schema> decodeSchema(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getSchemaDecoder());
}
