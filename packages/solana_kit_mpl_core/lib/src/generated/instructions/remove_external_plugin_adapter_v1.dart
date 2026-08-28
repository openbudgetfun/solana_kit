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

import '../types/external_plugin_adapter_key.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class RemoveExternalPluginAdapterV1InstructionData {
  const RemoveExternalPluginAdapterV1InstructionData({
    required this.key,
  }) : discriminator = 24;

  final int discriminator;
  final ExternalPluginAdapterKey key;
}

Encoder<RemoveExternalPluginAdapterV1InstructionData>
getRemoveExternalPluginAdapterV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('key', getExternalPluginAdapterKeyEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RemoveExternalPluginAdapterV1InstructionData value) => <String, Object?>{
      'discriminator': 24,
      'key': value.key,
    },
  );
}

Decoder<RemoveExternalPluginAdapterV1InstructionData>
getRemoveExternalPluginAdapterV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('key', getExternalPluginAdapterKeyDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'removeExternalPluginAdapterV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (RemoveExternalPluginAdapterV1InstructionData, int) readTopLevel(
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
      RemoveExternalPluginAdapterV1InstructionData(
        key: map['key']! as ExternalPluginAdapterKey,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<RemoveExternalPluginAdapterV1InstructionData>(
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
      VariableSizeDecoder<RemoveExternalPluginAdapterV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  RemoveExternalPluginAdapterV1InstructionData,
  RemoveExternalPluginAdapterV1InstructionData
>
getRemoveExternalPluginAdapterV1InstructionDataCodec() {
  return combineCodec(
    getRemoveExternalPluginAdapterV1InstructionDataEncoder(),
    getRemoveExternalPluginAdapterV1InstructionDataDecoder(),
  );
}

/// Creates a [RemoveExternalPluginAdapterV1] instruction.
Instruction getRemoveExternalPluginAdapterV1Instruction({
  required Address programAddress,
  required Address asset,
  Address? collection,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  Address? logWrapper,
  required ExternalPluginAdapterKey key,
}) {
  final instructionData = RemoveExternalPluginAdapterV1InstructionData(
    key: key,
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
    data: getRemoveExternalPluginAdapterV1InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [RemoveExternalPluginAdapterV1] instruction from raw instruction data.
RemoveExternalPluginAdapterV1InstructionData
parseRemoveExternalPluginAdapterV1Instruction(Instruction instruction) {
  return getRemoveExternalPluginAdapterV1InstructionDataDecoder().decode(
    instruction.data!,
  );
}
