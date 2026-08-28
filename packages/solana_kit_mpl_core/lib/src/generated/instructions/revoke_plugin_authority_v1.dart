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

import '../types/plugin_type.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class RevokePluginAuthorityV1InstructionData {
  const RevokePluginAuthorityV1InstructionData({
    required this.pluginType,
  }) : discriminator = 10;

  final int discriminator;
  final PluginType pluginType;
}

Encoder<RevokePluginAuthorityV1InstructionData>
getRevokePluginAuthorityV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('pluginType', getPluginTypeEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RevokePluginAuthorityV1InstructionData value) => <String, Object?>{
      'discriminator': 10,
      'pluginType': value.pluginType,
    },
  );
}

Decoder<RevokePluginAuthorityV1InstructionData>
getRevokePluginAuthorityV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('pluginType', getPluginTypeDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'revokePluginAuthorityV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (RevokePluginAuthorityV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(10),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      RevokePluginAuthorityV1InstructionData(
        pluginType: map['pluginType']! as PluginType,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<RevokePluginAuthorityV1InstructionData>(
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
      VariableSizeDecoder<RevokePluginAuthorityV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  RevokePluginAuthorityV1InstructionData,
  RevokePluginAuthorityV1InstructionData
>
getRevokePluginAuthorityV1InstructionDataCodec() {
  return combineCodec(
    getRevokePluginAuthorityV1InstructionDataEncoder(),
    getRevokePluginAuthorityV1InstructionDataDecoder(),
  );
}

/// Creates a [RevokePluginAuthorityV1] instruction.
Instruction getRevokePluginAuthorityV1Instruction({
  required Address programAddress,
  required Address asset,
  Address? collection,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  Address? logWrapper,
  required PluginType pluginType,
}) {
  final instructionData = RevokePluginAuthorityV1InstructionData(
    pluginType: pluginType,
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
    data: getRevokePluginAuthorityV1InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [RevokePluginAuthorityV1] instruction from raw instruction data.
RevokePluginAuthorityV1InstructionData parseRevokePluginAuthorityV1Instruction(
  Instruction instruction,
) {
  return getRevokePluginAuthorityV1InstructionDataDecoder().decode(
    instruction.data!,
  );
}
