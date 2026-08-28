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

import '../types/member.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class MultisigCreateV2InstructionData {
  MultisigCreateV2InstructionData({
    required this.configAuthority,
    required this.threshold,
    required this.members,
    required this.timeLock,
    required this.rentCollector,
    required this.memo,
  }) : discriminator = Uint8List.fromList([
         0x32,
         0xdd,
         0xc7,
         0x5d,
         0x28,
         0xf5,
         0x8b,
         0xe9,
       ]);

  final Uint8List discriminator;
  final Address? configAuthority;
  final int threshold;
  final List<Member> members;
  final int timeLock;
  final Address? rentCollector;
  final String? memo;
}

Encoder<MultisigCreateV2InstructionData>
getMultisigCreateV2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('configAuthority', getNullableEncoder<Address>(getAddressEncoder())),
    ('threshold', getU16Encoder()),
    (
      'members',
      getArrayEncoder<Member>(
        transformEncoder(getMemberEncoder(), (Member value) => value),
      ),
    ),
    ('timeLock', getU32Encoder()),
    ('rentCollector', getNullableEncoder<Address>(getAddressEncoder())),
    (
      'memo',
      getNullableEncoder<String>(
        addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (MultisigCreateV2InstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x32,
        0xdd,
        0xc7,
        0x5d,
        0x28,
        0xf5,
        0x8b,
        0xe9,
      ]),
      'configAuthority': value.configAuthority,
      'threshold': value.threshold,
      'members': value.members,
      'timeLock': value.timeLock,
      'rentCollector': value.rentCollector,
      'memo': value.memo,
    },
  );
}

Decoder<MultisigCreateV2InstructionData>
getMultisigCreateV2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('configAuthority', getNullableDecoder<Address>(getAddressDecoder())),
    ('threshold', getU16Decoder()),
    ('members', getArrayDecoder(getMemberDecoder())),
    ('timeLock', getU32Decoder()),
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
        'codecDescription': 'multisigCreateV2 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MultisigCreateV2InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x32, 0xdd, 0xc7, 0x5d, 0x28, 0xf5, 0x8b, 0xe9]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      MultisigCreateV2InstructionData(
        configAuthority: map['configAuthority'] as Address?,
        threshold: map['threshold']! as int,
        members: map['members']! as List<Member>,
        timeLock: map['timeLock']! as int,
        rentCollector: map['rentCollector'] as Address?,
        memo: map['memo'] as String?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MultisigCreateV2InstructionData>(
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
      VariableSizeDecoder<MultisigCreateV2InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<MultisigCreateV2InstructionData, MultisigCreateV2InstructionData>
getMultisigCreateV2InstructionDataCodec() {
  return combineCodec(
    getMultisigCreateV2InstructionDataEncoder(),
    getMultisigCreateV2InstructionDataDecoder(),
  );
}

/// Creates a [MultisigCreateV2] instruction.
Instruction getMultisigCreateV2Instruction({
  required Address programAddress,
  required Address programConfig,
  required Address treasury,
  required Address multisig,
  required Address createKey,
  required Address creator,
  required Address systemProgram,
  required Address? configAuthority,
  required int threshold,
  required List<Member> members,
  required int timeLock,
  required Address? rentCollector,
  required String? memo,
}) {
  final instructionData = MultisigCreateV2InstructionData(
    configAuthority: configAuthority,
    threshold: threshold,
    members: members,
    timeLock: timeLock,
    rentCollector: rentCollector,
    memo: memo,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: programConfig, role: AccountRole.readonly),
      AccountMeta(address: treasury, role: AccountRole.writable),
      AccountMeta(address: multisig, role: AccountRole.writable),
      AccountMeta(address: createKey, role: AccountRole.readonlySigner),
      AccountMeta(address: creator, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getMultisigCreateV2InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [MultisigCreateV2] instruction from raw instruction data.
MultisigCreateV2InstructionData parseMultisigCreateV2Instruction(
  Instruction instruction,
) {
  return getMultisigCreateV2InstructionDataDecoder().decode(instruction.data!);
}
