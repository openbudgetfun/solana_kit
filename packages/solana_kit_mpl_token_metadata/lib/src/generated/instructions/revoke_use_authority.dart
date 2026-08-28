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
class RevokeUseAuthorityInstructionData {
  const RevokeUseAuthorityInstructionData() : discriminator = 21;

  final int discriminator;
}

Encoder<RevokeUseAuthorityInstructionData>
getRevokeUseAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RevokeUseAuthorityInstructionData value) => <String, Object?>{
      'discriminator': 21,
    },
  );
}

Decoder<RevokeUseAuthorityInstructionData>
getRevokeUseAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'revokeUseAuthority instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (RevokeUseAuthorityInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(21),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      RevokeUseAuthorityInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<RevokeUseAuthorityInstructionData>(
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
      VariableSizeDecoder<RevokeUseAuthorityInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<RevokeUseAuthorityInstructionData, RevokeUseAuthorityInstructionData>
getRevokeUseAuthorityInstructionDataCodec() {
  return combineCodec(
    getRevokeUseAuthorityInstructionDataEncoder(),
    getRevokeUseAuthorityInstructionDataDecoder(),
  );
}

/// Creates a [RevokeUseAuthority] instruction.
Instruction getRevokeUseAuthorityInstruction({
  required Address programAddress,
  required Address useAuthorityRecord,
  required Address owner,
  required Address user,
  required Address ownerTokenAccount,
  required Address mint,
  required Address metadata,
  required Address tokenProgram,
  required Address systemProgram,
  Address? rent,
}) {
  final instructionData = RevokeUseAuthorityInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: useAuthorityRecord, role: AccountRole.writable),
      AccountMeta(address: owner, role: AccountRole.writableSigner),
      AccountMeta(address: user, role: AccountRole.readonly),
      AccountMeta(address: ownerTokenAccount, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: metadata, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      if (rent != null) AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getRevokeUseAuthorityInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [RevokeUseAuthority] instruction from raw instruction data.
RevokeUseAuthorityInstructionData parseRevokeUseAuthorityInstruction(
  Instruction instruction,
) {
  return getRevokeUseAuthorityInstructionDataDecoder().decode(
    instruction.data!,
  );
}
