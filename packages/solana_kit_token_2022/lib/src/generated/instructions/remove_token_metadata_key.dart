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
class RemoveTokenMetadataKeyInstructionData {
  RemoveTokenMetadataKeyInstructionData({
    required this.idempotent,
    required this.key,
  }) : discriminator = Uint8List.fromList([
         0xea,
         0x12,
         0x20,
         0x38,
         0x59,
         0x8d,
         0x25,
         0xb5,
       ]);

  final Uint8List discriminator;
  final bool idempotent;
  final String key;
}

Encoder<RemoveTokenMetadataKeyInstructionData>
getRemoveTokenMetadataKeyInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('idempotent', getBooleanEncoder()),
    ('key', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (RemoveTokenMetadataKeyInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xea,
        0x12,
        0x20,
        0x38,
        0x59,
        0x8d,
        0x25,
        0xb5,
      ]),
      'idempotent': value.idempotent,
      'key': value.key,
    },
  );
}

Decoder<RemoveTokenMetadataKeyInstructionData>
getRemoveTokenMetadataKeyInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('idempotent', getBooleanDecoder()),
    ('key', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'removeTokenMetadataKey instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (RemoveTokenMetadataKeyInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xea, 0x12, 0x20, 0x38, 0x59, 0x8d, 0x25, 0xb5]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      RemoveTokenMetadataKeyInstructionData(
        idempotent: map['idempotent']! as bool,
        key: map['key']! as String,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<RemoveTokenMetadataKeyInstructionData>(
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
      VariableSizeDecoder<RemoveTokenMetadataKeyInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  RemoveTokenMetadataKeyInstructionData,
  RemoveTokenMetadataKeyInstructionData
>
getRemoveTokenMetadataKeyInstructionDataCodec() {
  return combineCodec(
    getRemoveTokenMetadataKeyInstructionDataEncoder(),
    getRemoveTokenMetadataKeyInstructionDataDecoder(),
  );
}

/// Creates a [RemoveTokenMetadataKey] instruction.
Instruction getRemoveTokenMetadataKeyInstruction({
  required Address programAddress,
  required Address metadata,
  required Address updateAuthority,
  bool? idempotent,
  required String key,
}) {
  final instructionData = RemoveTokenMetadataKeyInstructionData(
    idempotent: idempotent ?? false,
    key: key,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
    ],
    data: getRemoveTokenMetadataKeyInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [RemoveTokenMetadataKey] instruction from raw instruction data.
RemoveTokenMetadataKeyInstructionData parseRemoveTokenMetadataKeyInstruction(
  Instruction instruction,
) {
  return getRemoveTokenMetadataKeyInstructionDataDecoder().decode(
    instruction.data!,
  );
}
