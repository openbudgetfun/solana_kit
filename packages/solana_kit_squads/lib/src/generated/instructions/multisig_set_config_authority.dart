// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class MultisigSetConfigAuthorityInstructionData {
  MultisigSetConfigAuthorityInstructionData({
    required this.newConfigAuthority,
    required this.memo,
  }) : discriminator = Uint8List.fromList([
         0x8f,
         0x5d,
         0xc7,
         0x8f,
         0x5c,
         0xa9,
         0xc1,
         0xe8,
       ]);

  final Uint8List discriminator;
  final Address newConfigAuthority;
  final String? memo;
}

Encoder<MultisigSetConfigAuthorityInstructionData>
getMultisigSetConfigAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('newConfigAuthority', getAddressEncoder()),
    (
      'memo',
      getNullableEncoder<String>(
        transformEncoder(
          addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
          (String value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (MultisigSetConfigAuthorityInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x8f,
        0x5d,
        0xc7,
        0x8f,
        0x5c,
        0xa9,
        0xc1,
        0xe8,
      ]),
      'newConfigAuthority': value.newConfigAuthority,
      'memo': value.memo,
    },
  );
}

Decoder<MultisigSetConfigAuthorityInstructionData>
getMultisigSetConfigAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('newConfigAuthority', getAddressDecoder()),
    (
      'memo',
      getNullableDecoder<String>(
        addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
      ),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'multisigSetConfigAuthority instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MultisigSetConfigAuthorityInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x8f, 0x5d, 0xc7, 0x8f, 0x5c, 0xa9, 0xc1, 0xe8]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      MultisigSetConfigAuthorityInstructionData(
        newConfigAuthority: map['newConfigAuthority']! as Address,
        memo: map['memo'] as String?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MultisigSetConfigAuthorityInstructionData>(
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
      VariableSizeDecoder<MultisigSetConfigAuthorityInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  MultisigSetConfigAuthorityInstructionData,
  MultisigSetConfigAuthorityInstructionData
>
getMultisigSetConfigAuthorityInstructionDataCodec() {
  return combineCodec(
    getMultisigSetConfigAuthorityInstructionDataEncoder(),
    getMultisigSetConfigAuthorityInstructionDataDecoder(),
  );
}

/// Creates a [MultisigSetConfigAuthority] instruction.
Instruction getMultisigSetConfigAuthorityInstruction({
  required Address programAddress,
  required Address multisig,
  required Address configAuthority,
  Address? rentPayer,
  Address? systemProgram,
  required Address newConfigAuthority,
  required String? memo,
}) {
  final instructionData = MultisigSetConfigAuthorityInstructionData(
    newConfigAuthority: newConfigAuthority,
    memo: memo,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.writable),
      AccountMeta(address: configAuthority, role: AccountRole.readonlySigner),
      if (rentPayer != null)
        AccountMeta(address: rentPayer, role: AccountRole.writableSigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (systemProgram != null)
        AccountMeta(address: systemProgram, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getMultisigSetConfigAuthorityInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [MultisigSetConfigAuthority] instruction from raw instruction data.
MultisigSetConfigAuthorityInstructionData
parseMultisigSetConfigAuthorityInstruction(Instruction instruction) {
  return getMultisigSetConfigAuthorityInstructionDataDecoder().decode(
    instruction.data!,
  );
}
