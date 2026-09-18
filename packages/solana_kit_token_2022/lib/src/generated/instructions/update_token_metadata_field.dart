// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/token_metadata_field.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UpdateTokenMetadataFieldInstructionData {
  UpdateTokenMetadataFieldInstructionData({
    required this.field,
    required this.value,
  }) : discriminator = Uint8List.fromList([
         0xdd,
         0xe9,
         0x31,
         0x2d,
         0xb5,
         0xca,
         0xdc,
         0xc8,
       ]);

  final Uint8List discriminator;
  final TokenMetadataField field;
  final String value;
}

Encoder<UpdateTokenMetadataFieldInstructionData>
getUpdateTokenMetadataFieldInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('field', getTokenMetadataFieldEncoder()),
    ('value', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateTokenMetadataFieldInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xdd,
        0xe9,
        0x31,
        0x2d,
        0xb5,
        0xca,
        0xdc,
        0xc8,
      ]),
      'field': value.field,
      'value': value.value,
    },
  );
}

Decoder<UpdateTokenMetadataFieldInstructionData>
getUpdateTokenMetadataFieldInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('field', getTokenMetadataFieldDecoder()),
    ('value', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'updateTokenMetadataField instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateTokenMetadataFieldInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xdd, 0xe9, 0x31, 0x2d, 0xb5, 0xca, 0xdc, 0xc8]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateTokenMetadataFieldInstructionData(
        field: map['field']! as TokenMetadataField,
        value: map['value']! as String,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateTokenMetadataFieldInstructionData>(
        fixedSize: structDecoder.fixedSize,
        read: (bytes, offset) {
          final bytesLength = bytes.length - offset;
          if (bytesLength != structDecoder.fixedSize) {
            throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
          }
          return readTopLevel(bytes, offset);
        },
      ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<UpdateTokenMetadataFieldInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  UpdateTokenMetadataFieldInstructionData,
  UpdateTokenMetadataFieldInstructionData
>
getUpdateTokenMetadataFieldInstructionDataCodec() {
  return combineCodec(
    getUpdateTokenMetadataFieldInstructionDataEncoder(),
    getUpdateTokenMetadataFieldInstructionDataDecoder(),
  );
}

/// Creates a [UpdateTokenMetadataField] instruction.
Instruction getUpdateTokenMetadataFieldInstruction({
  required Address programAddress,
  required Address metadata,
  required Address updateAuthority,
  required TokenMetadataField field,
  required String value,
}) {
  final instructionData = UpdateTokenMetadataFieldInstructionData(
    field: field,
    value: value,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
    ],
    data: getUpdateTokenMetadataFieldInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [UpdateTokenMetadataField] instruction from raw instruction data.
UpdateTokenMetadataFieldInstructionData
parseUpdateTokenMetadataFieldInstruction(Instruction instruction) {
  return getUpdateTokenMetadataFieldInstructionDataDecoder().decode(
    instruction.data!,
  );
}
