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
class PermissionedBurnCheckedInstructionData {
  const PermissionedBurnCheckedInstructionData({
    required this.amount,
    required this.decimals,
  }) : discriminator = 46,
       permissionedBurnDiscriminator = 2;

  final int discriminator;
  final int permissionedBurnDiscriminator;
  final BigInt amount;
  final int decimals;
}

Encoder<PermissionedBurnCheckedInstructionData>
getPermissionedBurnCheckedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('permissionedBurnDiscriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
    ('decimals', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (PermissionedBurnCheckedInstructionData value) => <String, Object?>{
      'discriminator': 46,
      'permissionedBurnDiscriminator': 2,
      'amount': value.amount,
      'decimals': value.decimals,
    },
  );
}

Decoder<PermissionedBurnCheckedInstructionData>
getPermissionedBurnCheckedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('permissionedBurnDiscriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
    ('decimals', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'permissionedBurnChecked instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (PermissionedBurnCheckedInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(46),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(2),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      PermissionedBurnCheckedInstructionData(
        amount: map['amount']! as BigInt,
        decimals: map['decimals']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<PermissionedBurnCheckedInstructionData>(
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
      VariableSizeDecoder<PermissionedBurnCheckedInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  PermissionedBurnCheckedInstructionData,
  PermissionedBurnCheckedInstructionData
>
getPermissionedBurnCheckedInstructionDataCodec() {
  return combineCodec(
    getPermissionedBurnCheckedInstructionDataEncoder(),
    getPermissionedBurnCheckedInstructionDataDecoder(),
  );
}

/// Creates a [PermissionedBurnChecked] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getPermissionedBurnCheckedInstruction({
  required Address programAddress,
  required Address account,
  required Address mint,
  required Address permissionedBurnAuthority,
  required Address authority,
  required BigInt amount,
  required int decimals,
  bool authorityIsSigner = true,
}) {
  final instructionData = PermissionedBurnCheckedInstructionData(
    amount: amount,
    decimals: decimals,
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
    data: getPermissionedBurnCheckedInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [PermissionedBurnChecked] instruction from raw instruction data.
PermissionedBurnCheckedInstructionData parsePermissionedBurnCheckedInstruction(
  Instruction instruction,
) {
  return getPermissionedBurnCheckedInstructionDataDecoder().decode(
    instruction.data!,
  );
}
