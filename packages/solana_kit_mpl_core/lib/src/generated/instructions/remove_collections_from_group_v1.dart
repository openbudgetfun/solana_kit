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
class RemoveCollectionsFromGroupV1InstructionData {
  const RemoveCollectionsFromGroupV1InstructionData({
    required this.collections,
  }) : discriminator = 34;

  final int discriminator;
  final List<Address> collections;
}

Encoder<RemoveCollectionsFromGroupV1InstructionData>
getRemoveCollectionsFromGroupV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    (
      'collections',
      getArrayEncoder(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (RemoveCollectionsFromGroupV1InstructionData value) => <String, Object?>{
      'discriminator': 34,
      'collections': value.collections,
    },
  );
}

Decoder<RemoveCollectionsFromGroupV1InstructionData>
getRemoveCollectionsFromGroupV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('collections', getArrayDecoder(getAddressDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'removeCollectionsFromGroupV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (RemoveCollectionsFromGroupV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(34),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      RemoveCollectionsFromGroupV1InstructionData(
        collections: map['collections']! as List<Address>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<RemoveCollectionsFromGroupV1InstructionData>(
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
      VariableSizeDecoder<RemoveCollectionsFromGroupV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  RemoveCollectionsFromGroupV1InstructionData,
  RemoveCollectionsFromGroupV1InstructionData
>
getRemoveCollectionsFromGroupV1InstructionDataCodec() {
  return combineCodec(
    getRemoveCollectionsFromGroupV1InstructionDataEncoder(),
    getRemoveCollectionsFromGroupV1InstructionDataDecoder(),
  );
}

/// Creates a [RemoveCollectionsFromGroupV1] instruction.
Instruction getRemoveCollectionsFromGroupV1Instruction({
  required Address programAddress,
  required Address group,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  required List<Address> collections,
}) {
  final instructionData = RemoveCollectionsFromGroupV1InstructionData(
    collections: collections,
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
    data: getRemoveCollectionsFromGroupV1InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [RemoveCollectionsFromGroupV1] instruction from raw instruction data.
RemoveCollectionsFromGroupV1InstructionData
parseRemoveCollectionsFromGroupV1Instruction(Instruction instruction) {
  return getRemoveCollectionsFromGroupV1InstructionDataDecoder().decode(
    instruction.data!,
  );
}
