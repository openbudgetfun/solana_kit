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
class MultisigSetRentCollectorInstructionData {
  MultisigSetRentCollectorInstructionData({
    required this.rentCollector,
    required this.memo,
  }) : discriminator = Uint8List.fromList([
         0x30,
         0xcc,
         0x41,
         0x39,
         0xd2,
         0x46,
         0x9c,
         0x4a,
       ]);

  final Uint8List discriminator;
  final Address? rentCollector;
  final String? memo;
}

Encoder<MultisigSetRentCollectorInstructionData>
getMultisigSetRentCollectorInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    (
      'rentCollector',
      getNullableEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
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
    (MultisigSetRentCollectorInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x30,
        0xcc,
        0x41,
        0x39,
        0xd2,
        0x46,
        0x9c,
        0x4a,
      ]),
      'rentCollector': value.rentCollector,
      'memo': value.memo,
    },
  );
}

Decoder<MultisigSetRentCollectorInstructionData>
getMultisigSetRentCollectorInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('rentCollector', getNullableDecoder<Address>(getAddressDecoder())),
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
        'codecDescription': 'multisigSetRentCollector instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MultisigSetRentCollectorInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x30, 0xcc, 0x41, 0x39, 0xd2, 0x46, 0x9c, 0x4a]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      MultisigSetRentCollectorInstructionData(
        rentCollector: map['rentCollector'] as Address?,
        memo: map['memo'] as String?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MultisigSetRentCollectorInstructionData>(
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
      VariableSizeDecoder<MultisigSetRentCollectorInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  MultisigSetRentCollectorInstructionData,
  MultisigSetRentCollectorInstructionData
>
getMultisigSetRentCollectorInstructionDataCodec() {
  return combineCodec(
    getMultisigSetRentCollectorInstructionDataEncoder(),
    getMultisigSetRentCollectorInstructionDataDecoder(),
  );
}

/// Creates a [MultisigSetRentCollector] instruction.
Instruction getMultisigSetRentCollectorInstruction({
  required Address programAddress,
  required Address multisig,
  required Address configAuthority,
  Address? rentPayer,
  Address? systemProgram,
  required Address? rentCollector,
  required String? memo,
}) {
  final instructionData = MultisigSetRentCollectorInstructionData(
    rentCollector: rentCollector,
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
    data: getMultisigSetRentCollectorInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [MultisigSetRentCollector] instruction from raw instruction data.
MultisigSetRentCollectorInstructionData
parseMultisigSetRentCollectorInstruction(Instruction instruction) {
  return getMultisigSetRentCollectorInstructionDataDecoder().decode(
    instruction.data!,
  );
}
