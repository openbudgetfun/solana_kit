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
class RemoveAssetsFromGroupV1InstructionData {
  const RemoveAssetsFromGroupV1InstructionData({
    required this.assets,
  }) : discriminator = 36;

  final int discriminator;
  final List<Address> assets;
}

Encoder<RemoveAssetsFromGroupV1InstructionData>
getRemoveAssetsFromGroupV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    (
      'assets',
      getArrayEncoder(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (RemoveAssetsFromGroupV1InstructionData value) => <String, Object?>{
      'discriminator': 36,
      'assets': value.assets,
    },
  );
}

Decoder<RemoveAssetsFromGroupV1InstructionData>
getRemoveAssetsFromGroupV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('assets', getArrayDecoder(getAddressDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'removeAssetsFromGroupV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (RemoveAssetsFromGroupV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(36),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      RemoveAssetsFromGroupV1InstructionData(
        assets: map['assets']! as List<Address>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<RemoveAssetsFromGroupV1InstructionData>(
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
      VariableSizeDecoder<RemoveAssetsFromGroupV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  RemoveAssetsFromGroupV1InstructionData,
  RemoveAssetsFromGroupV1InstructionData
>
getRemoveAssetsFromGroupV1InstructionDataCodec() {
  return combineCodec(
    getRemoveAssetsFromGroupV1InstructionDataEncoder(),
    getRemoveAssetsFromGroupV1InstructionDataDecoder(),
  );
}

/// Creates a [RemoveAssetsFromGroupV1] instruction.
Instruction getRemoveAssetsFromGroupV1Instruction({
  required Address programAddress,
  required Address group,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  required List<Address> assets,
}) {
  final instructionData = RemoveAssetsFromGroupV1InstructionData(
    assets: assets,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: group, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.readonlySigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getRemoveAssetsFromGroupV1InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [RemoveAssetsFromGroupV1] instruction from raw instruction data.
RemoveAssetsFromGroupV1InstructionData parseRemoveAssetsFromGroupV1Instruction(
  Instruction instruction,
) {
  return getRemoveAssetsFromGroupV1InstructionDataDecoder().decode(
    instruction.data!,
  );
}
