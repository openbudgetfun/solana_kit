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
class UpdateV2InstructionData {
  const UpdateV2InstructionData({
    required this.newName,
    required this.newUri,
    required this.newUpdateAuthority,
  }) : discriminator = 30;

  final int discriminator;
  final String? newName;
  final String? newUri;
  final UpdateAuthority? newUpdateAuthority;
}

Encoder<UpdateV2InstructionData> getUpdateV2InstructionDataEncoder() {
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
    (UpdateV2InstructionData value) => <String, Object?>{
      'discriminator': 30,
      'newName': value.newName,
      'newUri': value.newUri,
      'newUpdateAuthority': value.newUpdateAuthority,
    },
  );
}

Decoder<UpdateV2InstructionData> getUpdateV2InstructionDataDecoder() {
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
        'codecDescription': 'updateV2 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateV2InstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(30),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateV2InstructionData(
        newName: map['newName'] as String?,
        newUri: map['newUri'] as String?,
        newUpdateAuthority: map['newUpdateAuthority'] as UpdateAuthority?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateV2InstructionData>(
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
      VariableSizeDecoder<UpdateV2InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<UpdateV2InstructionData, UpdateV2InstructionData>
getUpdateV2InstructionDataCodec() {
  return combineCodec(
    getUpdateV2InstructionDataEncoder(),
    getUpdateV2InstructionDataDecoder(),
  );
}

/// Creates a [UpdateV2] instruction.
Instruction getUpdateV2Instruction({
  required Address programAddress,
  required Address asset,
  Address? collection,
  required Address payer,
  Address? authority,
  Address? newCollection,
  required Address systemProgram,
  Address? logWrapper,
  required String? newName,
  required String? newUri,
  required UpdateAuthority? newUpdateAuthority,
}) {
  final instructionData = UpdateV2InstructionData(
    newName: newName,
    newUri: newUri,
    newUpdateAuthority: newUpdateAuthority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: asset, role: AccountRole.writable),
      if (collection != null)
        AccountMeta(address: collection, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.readonlySigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (newCollection != null)
        AccountMeta(address: newCollection, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      if (logWrapper != null)
        AccountMeta(address: logWrapper, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getUpdateV2InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateV2] instruction from raw instruction data.
UpdateV2InstructionData parseUpdateV2Instruction(Instruction instruction) {
  return getUpdateV2InstructionDataDecoder().decode(instruction.data!);
}
