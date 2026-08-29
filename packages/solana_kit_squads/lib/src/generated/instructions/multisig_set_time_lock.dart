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
class MultisigSetTimeLockInstructionData {
  MultisigSetTimeLockInstructionData({
    required this.timeLock,
    required this.memo,
  }) : discriminator = Uint8List.fromList([
         0x94,
         0x9a,
         0x79,
         0x4d,
         0xd4,
         0xfe,
         0x9b,
         0x48,
       ]);

  final Uint8List discriminator;
  final int timeLock;
  final String? memo;
}

Encoder<MultisigSetTimeLockInstructionData>
getMultisigSetTimeLockInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('timeLock', getU32Encoder()),
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
    (MultisigSetTimeLockInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x94,
        0x9a,
        0x79,
        0x4d,
        0xd4,
        0xfe,
        0x9b,
        0x48,
      ]),
      'timeLock': value.timeLock,
      'memo': value.memo,
    },
  );
}

Decoder<MultisigSetTimeLockInstructionData>
getMultisigSetTimeLockInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('timeLock', getU32Decoder()),
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
        'codecDescription': 'multisigSetTimeLock instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MultisigSetTimeLockInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x94, 0x9a, 0x79, 0x4d, 0xd4, 0xfe, 0x9b, 0x48]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      MultisigSetTimeLockInstructionData(
        timeLock: map['timeLock']! as int,
        memo: map['memo'] as String?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MultisigSetTimeLockInstructionData>(
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
      VariableSizeDecoder<MultisigSetTimeLockInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<MultisigSetTimeLockInstructionData, MultisigSetTimeLockInstructionData>
getMultisigSetTimeLockInstructionDataCodec() {
  return combineCodec(
    getMultisigSetTimeLockInstructionDataEncoder(),
    getMultisigSetTimeLockInstructionDataDecoder(),
  );
}

/// Creates a [MultisigSetTimeLock] instruction.
Instruction getMultisigSetTimeLockInstruction({
  required Address programAddress,
  required Address multisig,
  required Address configAuthority,
  Address? rentPayer,
  Address? systemProgram,
  required int timeLock,
  required String? memo,
}) {
  final instructionData = MultisigSetTimeLockInstructionData(
    timeLock: timeLock,
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
    data: getMultisigSetTimeLockInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [MultisigSetTimeLock] instruction from raw instruction data.
MultisigSetTimeLockInstructionData parseMultisigSetTimeLockInstruction(
  Instruction instruction,
) {
  return getMultisigSetTimeLockInstructionDataDecoder().decode(
    instruction.data!,
  );
}
