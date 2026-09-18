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
class InitializeMintInstructionData {
  const InitializeMintInstructionData({
    required this.decimals,
    required this.mintAuthority,
    required this.freezeAuthority,
  }) : discriminator = 0;

  final int discriminator;
  final int decimals;
  final Address mintAuthority;
  final Address? freezeAuthority;
}

Encoder<InitializeMintInstructionData>
getInitializeMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('decimals', getU8Encoder()),
    ('mintAuthority', getAddressEncoder()),
    (
      'freezeAuthority',
      getNullableEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeMintInstructionData value) => <String, Object?>{
      'discriminator': 0,
      'decimals': value.decimals,
      'mintAuthority': value.mintAuthority,
      'freezeAuthority': value.freezeAuthority,
    },
  );
}

Decoder<InitializeMintInstructionData>
getInitializeMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('decimals', getU8Decoder()),
    ('mintAuthority', getAddressDecoder()),
    ('freezeAuthority', getNullableDecoder<Address>(getAddressDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializeMint instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeMintInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(0),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeMintInstructionData(
        decimals: map['decimals']! as int,
        mintAuthority: map['mintAuthority']! as Address,
        freezeAuthority: map['freezeAuthority'] as Address?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeMintInstructionData>(
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
      VariableSizeDecoder<InitializeMintInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<InitializeMintInstructionData, InitializeMintInstructionData>
getInitializeMintInstructionDataCodec() {
  return combineCodec(
    getInitializeMintInstructionDataEncoder(),
    getInitializeMintInstructionDataDecoder(),
  );
}

/// Creates a [InitializeMint] instruction.
Instruction getInitializeMintInstruction({
  required Address programAddress,
  required Address mint,
  required Address rent,
  required int decimals,
  required Address mintAuthority,
  Address? freezeAuthority,
}) {
  final instructionData = InitializeMintInstructionData(
    decimals: decimals,
    mintAuthority: mintAuthority,
    freezeAuthority: freezeAuthority ?? null,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getInitializeMintInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeMint] instruction from raw instruction data.
InitializeMintInstructionData parseInitializeMintInstruction(
  Instruction instruction,
) {
  return getInitializeMintInstructionDataDecoder().decode(instruction.data!);
}
