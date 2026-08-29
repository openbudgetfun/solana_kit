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
import '../types/plugin_type.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class ApprovePluginAuthorityV1InstructionData {
  const ApprovePluginAuthorityV1InstructionData({
    required this.pluginType,
    required this.newAuthority,
  }) : discriminator = 8;

  final int discriminator;
  final PluginType pluginType;
  final Authority newAuthority;
}

Encoder<ApprovePluginAuthorityV1InstructionData>
getApprovePluginAuthorityV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('pluginType', getPluginTypeEncoder()),
    ('newAuthority', getAuthorityEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ApprovePluginAuthorityV1InstructionData value) => <String, Object?>{
      'discriminator': 8,
      'pluginType': value.pluginType,
      'newAuthority': value.newAuthority,
    },
  );
}

Decoder<ApprovePluginAuthorityV1InstructionData>
getApprovePluginAuthorityV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('pluginType', getPluginTypeDecoder()),
    ('newAuthority', getAuthorityDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'approvePluginAuthorityV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ApprovePluginAuthorityV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(8),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ApprovePluginAuthorityV1InstructionData(
        pluginType: map['pluginType']! as PluginType,
        newAuthority: map['newAuthority']! as Authority,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ApprovePluginAuthorityV1InstructionData>(
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
      VariableSizeDecoder<ApprovePluginAuthorityV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  ApprovePluginAuthorityV1InstructionData,
  ApprovePluginAuthorityV1InstructionData
>
getApprovePluginAuthorityV1InstructionDataCodec() {
  return combineCodec(
    getApprovePluginAuthorityV1InstructionDataEncoder(),
    getApprovePluginAuthorityV1InstructionDataDecoder(),
  );
}

/// Creates a [ApprovePluginAuthorityV1] instruction.
Instruction getApprovePluginAuthorityV1Instruction({
  required Address programAddress,
  required Address asset,
  Address? collection,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  Address? logWrapper,
  required PluginType pluginType,
  required Authority newAuthority,
}) {
  final instructionData = ApprovePluginAuthorityV1InstructionData(
    pluginType: pluginType,
    newAuthority: newAuthority,
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
    data: getApprovePluginAuthorityV1InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ApprovePluginAuthorityV1] instruction from raw instruction data.
ApprovePluginAuthorityV1InstructionData
parseApprovePluginAuthorityV1Instruction(Instruction instruction) {
  return getApprovePluginAuthorityV1InstructionDataDecoder().decode(
    instruction.data!,
  );
}
