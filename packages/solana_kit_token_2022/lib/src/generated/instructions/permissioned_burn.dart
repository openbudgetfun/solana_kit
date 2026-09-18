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

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

/// The discriminator field name: 'permissionedBurnDiscriminator'.
/// Offset: 1.

@immutable
class PermissionedBurnInstructionData {
  const PermissionedBurnInstructionData({
    required this.amount,
  }) : discriminator = 46,
       permissionedBurnDiscriminator = 1;

  final int discriminator;
  final int permissionedBurnDiscriminator;
  final BigInt amount;
}

Encoder<PermissionedBurnInstructionData>
getPermissionedBurnInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('permissionedBurnDiscriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (PermissionedBurnInstructionData value) => <String, Object?>{
      'discriminator': 46,
      'permissionedBurnDiscriminator': 1,
      'amount': value.amount,
    },
  );
}

Decoder<PermissionedBurnInstructionData>
getPermissionedBurnInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('permissionedBurnDiscriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'permissionedBurn instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (PermissionedBurnInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(46),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(1),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      PermissionedBurnInstructionData(
        amount: map['amount']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<PermissionedBurnInstructionData>(
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
      VariableSizeDecoder<PermissionedBurnInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<PermissionedBurnInstructionData, PermissionedBurnInstructionData>
getPermissionedBurnInstructionDataCodec() {
  return combineCodec(
    getPermissionedBurnInstructionDataEncoder(),
    getPermissionedBurnInstructionDataDecoder(),
  );
}

/// Creates a [PermissionedBurn] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getPermissionedBurnInstruction({
  required Address programAddress,
  required Address account,
  required Address mint,
  required Address permissionedBurnAuthority,
  required Address authority,
  required BigInt amount,
  bool authorityIsSigner = true,
}) {
  final instructionData = PermissionedBurnInstructionData(
    amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: account, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(
        address: permissionedBurnAuthority,
        role: AccountRole.readonlySigner,
      ),
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getPermissionedBurnInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [PermissionedBurn] instruction from raw instruction data.
PermissionedBurnInstructionData parsePermissionedBurnInstruction(
  Instruction instruction,
) {
  return getPermissionedBurnInstructionDataDecoder().decode(instruction.data!);
}
