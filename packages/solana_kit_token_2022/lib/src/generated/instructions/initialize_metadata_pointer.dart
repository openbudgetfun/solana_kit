// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

/// The discriminator field name: 'metadataPointerDiscriminator'.
/// Offset: 1.

@immutable
class InitializeMetadataPointerInstructionData {
  const InitializeMetadataPointerInstructionData({
    required this.authority,
    required this.metadataAddress,
  }) : discriminator = 39,
       metadataPointerDiscriminator = 0;

  final int discriminator;
  final int metadataPointerDiscriminator;
  final Address? authority;
  final Address? metadataAddress;
}

Encoder<InitializeMetadataPointerInstructionData>
getInitializeMetadataPointerInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('metadataPointerDiscriminator', getU8Encoder()),
    (
      'authority',
      getNullableEncoder<Address>(
        getAddressEncoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
    (
      'metadataAddress',
      getNullableEncoder<Address>(
        getAddressEncoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeMetadataPointerInstructionData value) => <String, Object?>{
      'discriminator': 39,
      'metadataPointerDiscriminator': 0,
      'authority': value.authority,
      'metadataAddress': value.metadataAddress,
    },
  );
}

Decoder<InitializeMetadataPointerInstructionData>
getInitializeMetadataPointerInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('metadataPointerDiscriminator', getU8Decoder()),
    (
      'authority',
      getNullableDecoder<Address>(
        getAddressDecoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
    (
      'metadataAddress',
      getNullableDecoder<Address>(
        getAddressDecoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializeMetadataPointer instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeMetadataPointerInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(39),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(0),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeMetadataPointerInstructionData(
        authority: map['authority'] as Address?,
        metadataAddress: map['metadataAddress'] as Address?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeMetadataPointerInstructionData>(
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
      VariableSizeDecoder<InitializeMetadataPointerInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  InitializeMetadataPointerInstructionData,
  InitializeMetadataPointerInstructionData
>
getInitializeMetadataPointerInstructionDataCodec() {
  return combineCodec(
    getInitializeMetadataPointerInstructionDataEncoder(),
    getInitializeMetadataPointerInstructionDataDecoder(),
  );
}

/// Creates a [InitializeMetadataPointer] instruction.
Instruction getInitializeMetadataPointerInstruction({
  required Address programAddress,
  required Address mint,
  required Address? authority,
  required Address? metadataAddress,
}) {
  final instructionData = InitializeMetadataPointerInstructionData(
    authority: authority,
    metadataAddress: metadataAddress,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeMetadataPointerInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitializeMetadataPointer] instruction from raw instruction data.
InitializeMetadataPointerInstructionData
parseInitializeMetadataPointerInstruction(Instruction instruction) {
  return getInitializeMetadataPointerInstructionDataDecoder().decode(
    instruction.data!,
  );
}
