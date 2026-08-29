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
class RevokeCollectionPluginAuthorityV1InstructionData {
  const RevokeCollectionPluginAuthorityV1InstructionData({
    required this.pluginType,
  }) : discriminator = 11;

  final int discriminator;
  final PluginType pluginType;
}

Encoder<RevokeCollectionPluginAuthorityV1InstructionData>
getRevokeCollectionPluginAuthorityV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('pluginType', getPluginTypeEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RevokeCollectionPluginAuthorityV1InstructionData value) =>
        <String, Object?>{
          'discriminator': 11,
          'pluginType': value.pluginType,
        },
  );
}

Decoder<RevokeCollectionPluginAuthorityV1InstructionData>
getRevokeCollectionPluginAuthorityV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('pluginType', getPluginTypeDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'revokeCollectionPluginAuthorityV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (RevokeCollectionPluginAuthorityV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(11),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      RevokeCollectionPluginAuthorityV1InstructionData(
        pluginType: map['pluginType']! as PluginType,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<RevokeCollectionPluginAuthorityV1InstructionData>(
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
      VariableSizeDecoder<RevokeCollectionPluginAuthorityV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  RevokeCollectionPluginAuthorityV1InstructionData,
  RevokeCollectionPluginAuthorityV1InstructionData
>
getRevokeCollectionPluginAuthorityV1InstructionDataCodec() {
  return combineCodec(
    getRevokeCollectionPluginAuthorityV1InstructionDataEncoder(),
    getRevokeCollectionPluginAuthorityV1InstructionDataDecoder(),
  );
}

/// Creates a [RevokeCollectionPluginAuthorityV1] instruction.
Instruction getRevokeCollectionPluginAuthorityV1Instruction({
  required Address programAddress,
  required Address collection,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  Address? logWrapper,
  required PluginType pluginType,
}) {
  final instructionData = RevokeCollectionPluginAuthorityV1InstructionData(
    pluginType: pluginType,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: collection, role: AccountRole.writable),
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
    data: getRevokeCollectionPluginAuthorityV1InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [RevokeCollectionPluginAuthorityV1] instruction from raw instruction data.
RevokeCollectionPluginAuthorityV1InstructionData
parseRevokeCollectionPluginAuthorityV1Instruction(Instruction instruction) {
  return getRevokeCollectionPluginAuthorityV1InstructionDataDecoder().decode(
    instruction.data!,
  );
}
