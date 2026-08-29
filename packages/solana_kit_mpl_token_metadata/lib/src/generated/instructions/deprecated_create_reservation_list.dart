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
class DeprecatedCreateReservationListInstructionData {
  const DeprecatedCreateReservationListInstructionData() : discriminator = 6;

  final int discriminator;
}

Encoder<DeprecatedCreateReservationListInstructionData>
getDeprecatedCreateReservationListInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DeprecatedCreateReservationListInstructionData value) => <String, Object?>{
      'discriminator': 6,
    },
  );
}

Decoder<DeprecatedCreateReservationListInstructionData>
getDeprecatedCreateReservationListInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'deprecatedCreateReservationList instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (DeprecatedCreateReservationListInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(6),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      DeprecatedCreateReservationListInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<DeprecatedCreateReservationListInstructionData>(
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
      VariableSizeDecoder<DeprecatedCreateReservationListInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  DeprecatedCreateReservationListInstructionData,
  DeprecatedCreateReservationListInstructionData
>
getDeprecatedCreateReservationListInstructionDataCodec() {
  return combineCodec(
    getDeprecatedCreateReservationListInstructionDataEncoder(),
    getDeprecatedCreateReservationListInstructionDataDecoder(),
  );
}

/// Creates a [DeprecatedCreateReservationList] instruction.
Instruction getDeprecatedCreateReservationListInstruction({
  required Address programAddress,
  required Address reservationList,
  required Address payer,
  required Address updateAuthority,
  required Address masterEdition,
  required Address resource,
  required Address metadata,
  required Address systemProgram,
  required Address rent,
}) {
  final instructionData = DeprecatedCreateReservationListInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: reservationList, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.readonlySigner),
      AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: masterEdition, role: AccountRole.readonly),
      AccountMeta(address: resource, role: AccountRole.readonly),
      AccountMeta(address: metadata, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getDeprecatedCreateReservationListInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [DeprecatedCreateReservationList] instruction from raw instruction data.
DeprecatedCreateReservationListInstructionData
parseDeprecatedCreateReservationListInstruction(Instruction instruction) {
  return getDeprecatedCreateReservationListInstructionDataDecoder().decode(
    instruction.data!,
  );
}
