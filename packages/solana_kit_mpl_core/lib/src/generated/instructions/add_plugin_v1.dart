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

import '../types/authority.dart';
import '../types/plugin.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class AddPluginV1InstructionData {
  const AddPluginV1InstructionData({
    required this.plugin,
    required this.initAuthority,
  }) : discriminator = 2;

  final int discriminator;
  final Plugin plugin;
  final Authority? initAuthority;
}

Encoder<AddPluginV1InstructionData> getAddPluginV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('plugin', getPluginEncoder()),
    ('initAuthority', getNullableEncoder<Authority>(getAuthorityEncoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (AddPluginV1InstructionData value) => <String, Object?>{
      'discriminator': 2,
      'plugin': value.plugin,
      'initAuthority': value.initAuthority,
    },
  );
}

Decoder<AddPluginV1InstructionData> getAddPluginV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('plugin', getPluginDecoder()),
    ('initAuthority', getNullableDecoder<Authority>(getAuthorityDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'addPluginV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (AddPluginV1InstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(2),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      AddPluginV1InstructionData(
        plugin: map['plugin']! as Plugin,
        initAuthority: map['initAuthority'] as Authority?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<AddPluginV1InstructionData>(
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
      VariableSizeDecoder<AddPluginV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<AddPluginV1InstructionData, AddPluginV1InstructionData>
getAddPluginV1InstructionDataCodec() {
  return combineCodec(
    getAddPluginV1InstructionDataEncoder(),
    getAddPluginV1InstructionDataDecoder(),
  );
}

/// Creates a [AddPluginV1] instruction.
Instruction getAddPluginV1Instruction({
  required Address programAddress,
  required Address asset,
  Address? collection,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  Address? logWrapper,
  required Plugin plugin,
  required Authority? initAuthority,
}) {
  final instructionData = AddPluginV1InstructionData(
    plugin: plugin,
    initAuthority: initAuthority,
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
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      if (logWrapper != null)
        AccountMeta(address: logWrapper, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getAddPluginV1InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [AddPluginV1] instruction from raw instruction data.
AddPluginV1InstructionData parseAddPluginV1Instruction(
  Instruction instruction,
) {
  return getAddPluginV1InstructionDataDecoder().decode(instruction.data!);
}
