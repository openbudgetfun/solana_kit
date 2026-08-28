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
class WriteExternalPluginAdapterDataV1InstructionData {
  const WriteExternalPluginAdapterDataV1InstructionData({
    required this.key,
    required this.data,
  }) : discriminator = 28;

  final int discriminator;
  final ExternalPluginAdapterKey key;
  final Uint8List? data;
}

Encoder<WriteExternalPluginAdapterDataV1InstructionData>
getWriteExternalPluginAdapterDataV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('key', getExternalPluginAdapterKeyEncoder()),
    (
      'data',
      getNullableEncoder<Uint8List>(
        addEncoderSizePrefix(getBytesEncoder(), getU32Encoder()),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (WriteExternalPluginAdapterDataV1InstructionData value) =>
        <String, Object?>{
          'discriminator': 28,
          'key': value.key,
          'data': value.data,
        },
  );
}

Decoder<WriteExternalPluginAdapterDataV1InstructionData>
getWriteExternalPluginAdapterDataV1InstructionDataDecoder() {
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
            'writeExternalPluginAdapterDataV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (WriteExternalPluginAdapterDataV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(28),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      WriteExternalPluginAdapterDataV1InstructionData(
        key: map['key']! as ExternalPluginAdapterKey,
        data: map['data'] as Uint8List?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<WriteExternalPluginAdapterDataV1InstructionData>(
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
      VariableSizeDecoder<WriteExternalPluginAdapterDataV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  WriteExternalPluginAdapterDataV1InstructionData,
  WriteExternalPluginAdapterDataV1InstructionData
>
getWriteExternalPluginAdapterDataV1InstructionDataCodec() {
  return combineCodec(
    getWriteExternalPluginAdapterDataV1InstructionDataEncoder(),
    getWriteExternalPluginAdapterDataV1InstructionDataDecoder(),
  );
}

/// Creates a [WriteExternalPluginAdapterDataV1] instruction.
Instruction getWriteExternalPluginAdapterDataV1Instruction({
  required Address programAddress,
  required Address asset,
  Address? collection,
  required Address payer,
  Address? authority,
  Address? buffer,
  required Address systemProgram,
  Address? logWrapper,
  required ExternalPluginAdapterKey key,
  required Uint8List? data,
}) {
  final instructionData = WriteExternalPluginAdapterDataV1InstructionData(
    key: key,
    data: data,
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
    data: getWriteExternalPluginAdapterDataV1InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [WriteExternalPluginAdapterDataV1] instruction from raw instruction data.
WriteExternalPluginAdapterDataV1InstructionData
parseWriteExternalPluginAdapterDataV1Instruction(Instruction instruction) {
  return getWriteExternalPluginAdapterDataV1InstructionDataDecoder().decode(
    instruction.data!,
  );
}
