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

@immutable
class InitializeMintCloseAuthorityInstructionData {
  const InitializeMintCloseAuthorityInstructionData({
    required this.closeAuthority,
  }) : discriminator = 25;

  final int discriminator;
  final Address? closeAuthority;
}

Encoder<InitializeMintCloseAuthorityInstructionData>
getInitializeMintCloseAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    (
      'closeAuthority',
      getNullableEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeMintCloseAuthorityInstructionData value) => <String, Object?>{
      'discriminator': 25,
      'closeAuthority': value.closeAuthority,
    },
  );
}

Decoder<InitializeMintCloseAuthorityInstructionData>
getInitializeMintCloseAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('closeAuthority', getNullableDecoder<Address>(getAddressDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializeMintCloseAuthority instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeMintCloseAuthorityInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(25),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeMintCloseAuthorityInstructionData(
        closeAuthority: map['closeAuthority'] as Address?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeMintCloseAuthorityInstructionData>(
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
      VariableSizeDecoder<InitializeMintCloseAuthorityInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  InitializeMintCloseAuthorityInstructionData,
  InitializeMintCloseAuthorityInstructionData
>
getInitializeMintCloseAuthorityInstructionDataCodec() {
  return combineCodec(
    getInitializeMintCloseAuthorityInstructionDataEncoder(),
    getInitializeMintCloseAuthorityInstructionDataDecoder(),
  );
}

/// Creates a [InitializeMintCloseAuthority] instruction.
Instruction getInitializeMintCloseAuthorityInstruction({
  required Address programAddress,
  required Address mint,
  required Address? closeAuthority,
}) {
  final instructionData = InitializeMintCloseAuthorityInstructionData(
    closeAuthority: closeAuthority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeMintCloseAuthorityInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitializeMintCloseAuthority] instruction from raw instruction data.
InitializeMintCloseAuthorityInstructionData
parseInitializeMintCloseAuthorityInstruction(Instruction instruction) {
  return getInitializeMintCloseAuthorityInstructionDataDecoder().decode(
    instruction.data!,
  );
}
