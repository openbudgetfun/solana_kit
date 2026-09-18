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

/// The discriminator field name: 'groupPointerDiscriminator'.
/// Offset: 1.

@immutable
class InitializeGroupPointerInstructionData {
  const InitializeGroupPointerInstructionData({
    required this.authority,
    required this.groupAddress,
  }) : discriminator = 40,
       groupPointerDiscriminator = 0;

  final int discriminator;
  final int groupPointerDiscriminator;
  final Address? authority;
  final Address? groupAddress;
}

Encoder<InitializeGroupPointerInstructionData>
getInitializeGroupPointerInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('groupPointerDiscriminator', getU8Encoder()),
    (
      'authority',
      getNullableEncoder<Address>(
        getAddressEncoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
    (
      'groupAddress',
      getNullableEncoder<Address>(
        getAddressEncoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeGroupPointerInstructionData value) => <String, Object?>{
      'discriminator': 40,
      'groupPointerDiscriminator': 0,
      'authority': value.authority,
      'groupAddress': value.groupAddress,
    },
  );
}

Decoder<InitializeGroupPointerInstructionData>
getInitializeGroupPointerInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('groupPointerDiscriminator', getU8Decoder()),
    (
      'authority',
      getNullableDecoder<Address>(
        getAddressDecoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
    (
      'groupAddress',
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
        'codecDescription': 'initializeGroupPointer instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeGroupPointerInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(40),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(0),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeGroupPointerInstructionData(
        authority: map['authority'] as Address?,
        groupAddress: map['groupAddress'] as Address?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeGroupPointerInstructionData>(
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
      VariableSizeDecoder<InitializeGroupPointerInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  InitializeGroupPointerInstructionData,
  InitializeGroupPointerInstructionData
>
getInitializeGroupPointerInstructionDataCodec() {
  return combineCodec(
    getInitializeGroupPointerInstructionDataEncoder(),
    getInitializeGroupPointerInstructionDataDecoder(),
  );
}

/// Creates a [InitializeGroupPointer] instruction.
Instruction getInitializeGroupPointerInstruction({
  required Address programAddress,
  required Address mint,
  required Address? authority,
  required Address? groupAddress,
}) {
  final instructionData = InitializeGroupPointerInstructionData(
    authority: authority,
    groupAddress: groupAddress,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeGroupPointerInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitializeGroupPointer] instruction from raw instruction data.
InitializeGroupPointerInstructionData parseInitializeGroupPointerInstruction(
  Instruction instruction,
) {
  return getInitializeGroupPointerInstructionDataDecoder().decode(
    instruction.data!,
  );
}
