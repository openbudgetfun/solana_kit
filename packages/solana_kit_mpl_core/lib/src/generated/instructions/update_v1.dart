// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/update_authority.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UpdateV1InstructionData {
  const UpdateV1InstructionData({
    required this.newName,
    required this.newUri,
    required this.newUpdateAuthority,
  }) : discriminator = 15;

  final int discriminator;
  final String? newName;
  final String? newUri;
  final UpdateAuthority? newUpdateAuthority;
}

Encoder<UpdateV1InstructionData> getUpdateV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    (
      'newName',
      getNullableEncoder<String>(
        transformEncoder(
          addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
          (String value) => value,
        ),
      ),
    ),
    (
      'newUri',
      getNullableEncoder<String>(
        transformEncoder(
          addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
          (String value) => value,
        ),
      ),
    ),
    (
      'newUpdateAuthority',
      getNullableEncoder<UpdateAuthority>(
        transformEncoder(
          getUpdateAuthorityEncoder(),
          (UpdateAuthority value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateV1InstructionData value) => <String, Object?>{
      'discriminator': 15,
      'newName': value.newName,
      'newUri': value.newUri,
      'newUpdateAuthority': value.newUpdateAuthority,
    },
  );
}

Decoder<UpdateV1InstructionData> getUpdateV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    (
      'newName',
      getNullableDecoder<String>(
        addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
      ),
    ),
    (
      'newUri',
      getNullableDecoder<String>(
        addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
      ),
    ),
    (
      'newUpdateAuthority',
      getNullableDecoder<UpdateAuthority>(getUpdateAuthorityDecoder()),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'updateV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateV1InstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(15),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateV1InstructionData(
        newName: map['newName'] as String?,
        newUri: map['newUri'] as String?,
        newUpdateAuthority: map['newUpdateAuthority'] as UpdateAuthority?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateV1InstructionData>(
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
      VariableSizeDecoder<UpdateV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<UpdateV1InstructionData, UpdateV1InstructionData>
getUpdateV1InstructionDataCodec() {
  return combineCodec(
    getUpdateV1InstructionDataEncoder(),
    getUpdateV1InstructionDataDecoder(),
  );
}

/// Creates a [UpdateV1] instruction.
Instruction getUpdateV1Instruction({
  required Address programAddress,
  required Address asset,
  Address? collection,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  Address? logWrapper,
  required String? newName,
  required String? newUri,
  required UpdateAuthority? newUpdateAuthority,
}) {
  final instructionData = UpdateV1InstructionData(
    newName: newName,
    newUri: newUri,
    newUpdateAuthority: newUpdateAuthority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: asset, role: AccountRole.writable),
      if (collection != null)
        AccountMeta(address: collection, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.readonlySigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      if (logWrapper != null)
        AccountMeta(address: logWrapper, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getUpdateV1InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateV1] instruction from raw instruction data.
UpdateV1InstructionData parseUpdateV1Instruction(Instruction instruction) {
  return getUpdateV1InstructionDataDecoder().decode(instruction.data!);
}
