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
class DeprecatedSetReservationListInstructionData {
  const DeprecatedSetReservationListInstructionData() : discriminator = 5;

  final int discriminator;
}

Encoder<DeprecatedSetReservationListInstructionData>
getDeprecatedSetReservationListInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DeprecatedSetReservationListInstructionData value) => <String, Object?>{
      'discriminator': 5,
    },
  );
}

Decoder<DeprecatedSetReservationListInstructionData>
getDeprecatedSetReservationListInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'deprecatedSetReservationList instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (DeprecatedSetReservationListInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(5),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      DeprecatedSetReservationListInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<DeprecatedSetReservationListInstructionData>(
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
      VariableSizeDecoder<DeprecatedSetReservationListInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  DeprecatedSetReservationListInstructionData,
  DeprecatedSetReservationListInstructionData
>
getDeprecatedSetReservationListInstructionDataCodec() {
  return combineCodec(
    getDeprecatedSetReservationListInstructionDataEncoder(),
    getDeprecatedSetReservationListInstructionDataDecoder(),
  );
}

/// Creates a [DeprecatedSetReservationList] instruction.
Instruction getDeprecatedSetReservationListInstruction({
  required Address programAddress,
  required Address masterEdition,
  required Address reservationList,
  required Address resource,
}) {
  final instructionData = DeprecatedSetReservationListInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: masterEdition, role: AccountRole.writable),
      AccountMeta(address: reservationList, role: AccountRole.writable),
      AccountMeta(address: resource, role: AccountRole.readonlySigner),
    ],
    data: getDeprecatedSetReservationListInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [DeprecatedSetReservationList] instruction from raw instruction data.
DeprecatedSetReservationListInstructionData
parseDeprecatedSetReservationListInstruction(Instruction instruction) {
  return getDeprecatedSetReservationListInstructionDataDecoder().decode(
    instruction.data!,
  );
}
