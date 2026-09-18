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
class UpdateMetadataPointerInstructionData {
  const UpdateMetadataPointerInstructionData({
    required this.metadataAddress,
  }) : discriminator = 39,
       metadataPointerDiscriminator = 1;

  final int discriminator;
  final int metadataPointerDiscriminator;
  final Address? metadataAddress;
}

Encoder<UpdateMetadataPointerInstructionData>
getUpdateMetadataPointerInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('metadataPointerDiscriminator', getU8Encoder()),
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
    (UpdateMetadataPointerInstructionData value) => <String, Object?>{
      'discriminator': 39,
      'metadataPointerDiscriminator': 1,
      'metadataAddress': value.metadataAddress,
    },
  );
}

Decoder<UpdateMetadataPointerInstructionData>
getUpdateMetadataPointerInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('metadataPointerDiscriminator', getU8Decoder()),
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
        'codecDescription': 'updateMetadataPointer instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateMetadataPointerInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(39),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(1),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateMetadataPointerInstructionData(
        metadataAddress: map['metadataAddress'] as Address?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateMetadataPointerInstructionData>(
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
      VariableSizeDecoder<UpdateMetadataPointerInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  UpdateMetadataPointerInstructionData,
  UpdateMetadataPointerInstructionData
>
getUpdateMetadataPointerInstructionDataCodec() {
  return combineCodec(
    getUpdateMetadataPointerInstructionDataEncoder(),
    getUpdateMetadataPointerInstructionDataDecoder(),
  );
}

/// Creates a [UpdateMetadataPointer] instruction.
/// Set [metadataPointerAuthorityIsSigner] to false when [metadataPointerAuthority] does not sign (for example, a multisig authority).
Instruction getUpdateMetadataPointerInstruction({
  required Address programAddress,
  required Address mint,
  required Address metadataPointerAuthority,
  required Address? metadataAddress,
  bool metadataPointerAuthorityIsSigner = true,
}) {
  final instructionData = UpdateMetadataPointerInstructionData(
    metadataAddress: metadataAddress,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(
        address: metadataPointerAuthority,
        role: metadataPointerAuthorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getUpdateMetadataPointerInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [UpdateMetadataPointer] instruction from raw instruction data.
UpdateMetadataPointerInstructionData parseUpdateMetadataPointerInstruction(
  Instruction instruction,
) {
  return getUpdateMetadataPointerInstructionDataDecoder().decode(
    instruction.data!,
  );
}
