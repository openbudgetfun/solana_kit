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

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class InitializeTokenMetadataInstructionData {
  InitializeTokenMetadataInstructionData({
    required this.name,
    required this.symbol,
    required this.uri,
  }) : discriminator = Uint8List.fromList([
         0xd2,
         0xe1,
         0x1e,
         0xa2,
         0x58,
         0xb8,
         0x4d,
         0x8d,
       ]);

  final Uint8List discriminator;
  final String name;
  final String symbol;
  final String uri;
}

Encoder<InitializeTokenMetadataInstructionData>
getInitializeTokenMetadataInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('name', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('symbol', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('uri', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeTokenMetadataInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xd2,
        0xe1,
        0x1e,
        0xa2,
        0x58,
        0xb8,
        0x4d,
        0x8d,
      ]),
      'name': value.name,
      'symbol': value.symbol,
      'uri': value.uri,
    },
  );
}

Decoder<InitializeTokenMetadataInstructionData>
getInitializeTokenMetadataInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('name', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('symbol', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('uri', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializeTokenMetadata instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeTokenMetadataInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xd2, 0xe1, 0x1e, 0xa2, 0x58, 0xb8, 0x4d, 0x8d]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeTokenMetadataInstructionData(
        name: map['name']! as String,
        symbol: map['symbol']! as String,
        uri: map['uri']! as String,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeTokenMetadataInstructionData>(
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
      VariableSizeDecoder<InitializeTokenMetadataInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  InitializeTokenMetadataInstructionData,
  InitializeTokenMetadataInstructionData
>
getInitializeTokenMetadataInstructionDataCodec() {
  return combineCodec(
    getInitializeTokenMetadataInstructionDataEncoder(),
    getInitializeTokenMetadataInstructionDataDecoder(),
  );
}

/// Creates a [InitializeTokenMetadata] instruction.
Instruction getInitializeTokenMetadataInstruction({
  required Address programAddress,
  required Address metadata,
  required Address updateAuthority,
  required Address mint,
  required Address mintAuthority,
  required String name,
  required String symbol,
  required String uri,
}) {
  final instructionData = InitializeTokenMetadataInstructionData(
    name: name,
    symbol: symbol,
    uri: uri,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: updateAuthority, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: mintAuthority, role: AccountRole.readonlySigner),
    ],
    data: getInitializeTokenMetadataInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitializeTokenMetadata] instruction from raw instruction data.
InitializeTokenMetadataInstructionData parseInitializeTokenMetadataInstruction(
  Instruction instruction,
) {
  return getInitializeTokenMetadataInstructionDataDecoder().decode(
    instruction.data!,
  );
}
