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
class WriteCollectionExternalPluginAdapterDataV1InstructionData {
  const WriteCollectionExternalPluginAdapterDataV1InstructionData({
    required this.key,
    required this.data,
  }) : discriminator = 29;

  final int discriminator;
  final ExternalPluginAdapterKey key;
  final Uint8List? data;
}

Encoder<WriteCollectionExternalPluginAdapterDataV1InstructionData>
getWriteCollectionExternalPluginAdapterDataV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('key', getExternalPluginAdapterKeyEncoder()),
    (
      'data',
      getNullableEncoder<Uint8List>(
        transformEncoder(
          addEncoderSizePrefix(getBytesEncoder(), getU32Encoder()),
          (Uint8List value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (WriteCollectionExternalPluginAdapterDataV1InstructionData value) =>
        <String, Object?>{
          'discriminator': 29,
          'key': value.key,
          'data': value.data,
        },
  );
}

Decoder<WriteCollectionExternalPluginAdapterDataV1InstructionData>
getWriteCollectionExternalPluginAdapterDataV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('key', getExternalPluginAdapterKeyDecoder()),
    (
      'data',
      getNullableDecoder<Uint8List>(
        addDecoderSizePrefix(getBytesDecoder(), getU32Decoder()),
      ),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'writeCollectionExternalPluginAdapterDataV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (WriteCollectionExternalPluginAdapterDataV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(29),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      WriteCollectionExternalPluginAdapterDataV1InstructionData(
        key: map['key']! as ExternalPluginAdapterKey,
        data: map['data'] as Uint8List?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<
        WriteCollectionExternalPluginAdapterDataV1InstructionData
      >(
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
        WriteCollectionExternalPluginAdapterDataV1InstructionData
      >(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  WriteCollectionExternalPluginAdapterDataV1InstructionData,
  WriteCollectionExternalPluginAdapterDataV1InstructionData
>
getWriteCollectionExternalPluginAdapterDataV1InstructionDataCodec() {
  return combineCodec(
    getWriteCollectionExternalPluginAdapterDataV1InstructionDataEncoder(),
    getWriteCollectionExternalPluginAdapterDataV1InstructionDataDecoder(),
  );
}

/// Creates a [WriteCollectionExternalPluginAdapterDataV1] instruction.
Instruction getWriteCollectionExternalPluginAdapterDataV1Instruction({
  required Address programAddress,
  required Address collection,
  required Address payer,
  Address? authority,
  Address? buffer,
  required Address systemProgram,
  Address? logWrapper,
  required ExternalPluginAdapterKey key,
  required Uint8List? data,
}) {
  final instructionData =
      WriteCollectionExternalPluginAdapterDataV1InstructionData(
        key: key,
        data: data,
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
      if (buffer != null)
        AccountMeta(address: buffer, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      if (logWrapper != null)
        AccountMeta(address: logWrapper, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getWriteCollectionExternalPluginAdapterDataV1InstructionDataEncoder()
        .encode(instructionData),
  );
}

/// Parses a [WriteCollectionExternalPluginAdapterDataV1] instruction from raw instruction data.
WriteCollectionExternalPluginAdapterDataV1InstructionData
parseWriteCollectionExternalPluginAdapterDataV1Instruction(
  Instruction instruction,
) {
  return getWriteCollectionExternalPluginAdapterDataV1InstructionDataDecoder()
      .decode(instruction.data!);
}
