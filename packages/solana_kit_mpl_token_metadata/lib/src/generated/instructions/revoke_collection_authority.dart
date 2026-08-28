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
class RevokeCollectionAuthorityInstructionData {
  const RevokeCollectionAuthorityInstructionData() : discriminator = 24;

  final int discriminator;
}

Encoder<RevokeCollectionAuthorityInstructionData>
getRevokeCollectionAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RevokeCollectionAuthorityInstructionData value) => <String, Object?>{
      'discriminator': 24,
    },
  );
}

Decoder<RevokeCollectionAuthorityInstructionData>
getRevokeCollectionAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'revokeCollectionAuthority instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (RevokeCollectionAuthorityInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(24),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      RevokeCollectionAuthorityInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<RevokeCollectionAuthorityInstructionData>(
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
      VariableSizeDecoder<RevokeCollectionAuthorityInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  RevokeCollectionAuthorityInstructionData,
  RevokeCollectionAuthorityInstructionData
>
getRevokeCollectionAuthorityInstructionDataCodec() {
  return combineCodec(
    getRevokeCollectionAuthorityInstructionDataEncoder(),
    getRevokeCollectionAuthorityInstructionDataDecoder(),
  );
}

/// Creates a [RevokeCollectionAuthority] instruction.
Instruction getRevokeCollectionAuthorityInstruction({
  required Address programAddress,
  required Address collectionAuthorityRecord,
  required Address delegateAuthority,
  required Address revokeAuthority,
  required Address metadata,
  required Address mint,
}) {
  final instructionData = RevokeCollectionAuthorityInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(
        address: collectionAuthorityRecord,
        role: AccountRole.writable,
      ),
      AccountMeta(address: delegateAuthority, role: AccountRole.writable),
      AccountMeta(address: revokeAuthority, role: AccountRole.writableSigner),
      AccountMeta(address: metadata, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.readonly),
    ],
    data: getRevokeCollectionAuthorityInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [RevokeCollectionAuthority] instruction from raw instruction data.
RevokeCollectionAuthorityInstructionData
parseRevokeCollectionAuthorityInstruction(Instruction instruction) {
  return getRevokeCollectionAuthorityInstructionDataDecoder().decode(
    instruction.data!,
  );
}
