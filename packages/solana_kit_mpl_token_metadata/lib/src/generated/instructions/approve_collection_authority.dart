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
class ApproveCollectionAuthorityInstructionData {
  const ApproveCollectionAuthorityInstructionData() : discriminator = 23;

  final int discriminator;
}

Encoder<ApproveCollectionAuthorityInstructionData>
getApproveCollectionAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ApproveCollectionAuthorityInstructionData value) => <String, Object?>{
      'discriminator': 23,
    },
  );
}

Decoder<ApproveCollectionAuthorityInstructionData>
getApproveCollectionAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'approveCollectionAuthority instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ApproveCollectionAuthorityInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(23),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ApproveCollectionAuthorityInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ApproveCollectionAuthorityInstructionData>(
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
      VariableSizeDecoder<ApproveCollectionAuthorityInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  ApproveCollectionAuthorityInstructionData,
  ApproveCollectionAuthorityInstructionData
>
getApproveCollectionAuthorityInstructionDataCodec() {
  return combineCodec(
    getApproveCollectionAuthorityInstructionDataEncoder(),
    getApproveCollectionAuthorityInstructionDataDecoder(),
  );
}

/// Creates a [ApproveCollectionAuthority] instruction.
Instruction getApproveCollectionAuthorityInstruction({
  required Address programAddress,
  required Address collectionAuthorityRecord,
  required Address newCollectionAuthority,
  required Address updateAuthority,
  required Address payer,
  required Address metadata,
  required Address mint,
  required Address systemProgram,
  Address? rent,
}) {
  final instructionData = ApproveCollectionAuthorityInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(
        address: collectionAuthorityRecord,
        role: AccountRole.writable,
      ),
      AccountMeta(address: newCollectionAuthority, role: AccountRole.readonly),
      AccountMeta(address: updateAuthority, role: AccountRole.writableSigner),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: metadata, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      if (rent != null) AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getApproveCollectionAuthorityInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ApproveCollectionAuthority] instruction from raw instruction data.
ApproveCollectionAuthorityInstructionData
parseApproveCollectionAuthorityInstruction(Instruction instruction) {
  return getApproveCollectionAuthorityInstructionDataDecoder().decode(
    instruction.data!,
  );
}
