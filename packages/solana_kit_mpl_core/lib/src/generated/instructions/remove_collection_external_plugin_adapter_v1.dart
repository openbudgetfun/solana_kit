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
class RemoveCollectionExternalPluginAdapterV1InstructionData {
  const RemoveCollectionExternalPluginAdapterV1InstructionData({
    required this.key,
  }) : discriminator = 25;

  final int discriminator;
  final ExternalPluginAdapterKey key;
}

Encoder<RemoveCollectionExternalPluginAdapterV1InstructionData>
getRemoveCollectionExternalPluginAdapterV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('key', getExternalPluginAdapterKeyEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RemoveCollectionExternalPluginAdapterV1InstructionData value) =>
        <String, Object?>{
          'discriminator': 25,
          'key': value.key,
        },
  );
}

Decoder<RemoveCollectionExternalPluginAdapterV1InstructionData>
getRemoveCollectionExternalPluginAdapterV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('key', getExternalPluginAdapterKeyDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'removeCollectionExternalPluginAdapterV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (RemoveCollectionExternalPluginAdapterV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(25),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      RemoveCollectionExternalPluginAdapterV1InstructionData(
        key: map['key']! as ExternalPluginAdapterKey,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<RemoveCollectionExternalPluginAdapterV1InstructionData>(
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
      VariableSizeDecoder<
        RemoveCollectionExternalPluginAdapterV1InstructionData
      >(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  RemoveCollectionExternalPluginAdapterV1InstructionData,
  RemoveCollectionExternalPluginAdapterV1InstructionData
>
getRemoveCollectionExternalPluginAdapterV1InstructionDataCodec() {
  return combineCodec(
    getRemoveCollectionExternalPluginAdapterV1InstructionDataEncoder(),
    getRemoveCollectionExternalPluginAdapterV1InstructionDataDecoder(),
  );
}

/// Creates a [RemoveCollectionExternalPluginAdapterV1] instruction.
Instruction getRemoveCollectionExternalPluginAdapterV1Instruction({
  required Address programAddress,
  required Address collection,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  Address? logWrapper,
  required ExternalPluginAdapterKey key,
}) {
  final instructionData =
      RemoveCollectionExternalPluginAdapterV1InstructionData(
        key: key,
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
    data: getRemoveCollectionExternalPluginAdapterV1InstructionDataEncoder()
        .encode(instructionData),
  );
}

/// Parses a [RemoveCollectionExternalPluginAdapterV1] instruction from raw instruction data.
RemoveCollectionExternalPluginAdapterV1InstructionData
parseRemoveCollectionExternalPluginAdapterV1Instruction(
  Instruction instruction,
) {
  return getRemoveCollectionExternalPluginAdapterV1InstructionDataDecoder()
      .decode(instruction.data!);
}
