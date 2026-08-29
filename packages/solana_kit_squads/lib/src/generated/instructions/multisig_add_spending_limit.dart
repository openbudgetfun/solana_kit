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

import '../types/period.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class MultisigAddSpendingLimitInstructionData {
  MultisigAddSpendingLimitInstructionData({
    required this.createKey,
    required this.vaultIndex,
    required this.mint,
    required this.amount,
    required this.period,
    required this.members,
    required this.destinations,
    required this.memo,
  }) : discriminator = Uint8List.fromList([
         0x0b,
         0xf2,
         0x9f,
         0x2a,
         0x56,
         0xc5,
         0x59,
         0x73,
       ]);

  final Uint8List discriminator;
  final Address createKey;
  final int vaultIndex;
  final Address mint;
  final BigInt amount;
  final Period period;
  final List<Address> members;
  final List<Address> destinations;
  final String? memo;
}

Encoder<MultisigAddSpendingLimitInstructionData>
getMultisigAddSpendingLimitInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('createKey', getAddressEncoder()),
    ('vaultIndex', getU8Encoder()),
    ('mint', getAddressEncoder()),
    ('amount', getU64Encoder()),
    ('period', getPeriodEncoder()),
    (
      'members',
      getArrayEncoder(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
    (
      'destinations',
      getArrayEncoder(
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
    (MultisigAddSpendingLimitInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x0b,
        0xf2,
        0x9f,
        0x2a,
        0x56,
        0xc5,
        0x59,
        0x73,
      ]),
      'createKey': value.createKey,
      'vaultIndex': value.vaultIndex,
      'mint': value.mint,
      'amount': value.amount,
      'period': value.period,
      'members': value.members,
      'destinations': value.destinations,
      'memo': value.memo,
    },
  );
}

Decoder<MultisigAddSpendingLimitInstructionData>
getMultisigAddSpendingLimitInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('createKey', getAddressDecoder()),
    ('vaultIndex', getU8Decoder()),
    ('mint', getAddressDecoder()),
    ('amount', getU64Decoder()),
    ('period', getPeriodDecoder()),
    ('members', getArrayDecoder(getAddressDecoder())),
    ('destinations', getArrayDecoder(getAddressDecoder())),
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
        'codecDescription': 'multisigAddSpendingLimit instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MultisigAddSpendingLimitInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x0b, 0xf2, 0x9f, 0x2a, 0x56, 0xc5, 0x59, 0x73]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      MultisigAddSpendingLimitInstructionData(
        createKey: map['createKey']! as Address,
        vaultIndex: map['vaultIndex']! as int,
        mint: map['mint']! as Address,
        amount: map['amount']! as BigInt,
        period: map['period']! as Period,
        members: map['members']! as List<Address>,
        destinations: map['destinations']! as List<Address>,
        memo: map['memo'] as String?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MultisigAddSpendingLimitInstructionData>(
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
      VariableSizeDecoder<MultisigAddSpendingLimitInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  MultisigAddSpendingLimitInstructionData,
  MultisigAddSpendingLimitInstructionData
>
getMultisigAddSpendingLimitInstructionDataCodec() {
  return combineCodec(
    getMultisigAddSpendingLimitInstructionDataEncoder(),
    getMultisigAddSpendingLimitInstructionDataDecoder(),
  );
}

/// Creates a [MultisigAddSpendingLimit] instruction.
Instruction getMultisigAddSpendingLimitInstruction({
  required Address programAddress,
  required Address multisig,
  required Address configAuthority,
  required Address spendingLimit,
  required Address rentPayer,
  required Address systemProgram,
  required Address createKey,
  required int vaultIndex,
  required Address mint,
  required BigInt amount,
  required Period period,
  required List<Address> members,
  required List<Address> destinations,
  required String? memo,
}) {
  final instructionData = MultisigAddSpendingLimitInstructionData(
    createKey: createKey,
    vaultIndex: vaultIndex,
    mint: mint,
    amount: amount,
    period: period,
    members: members,
    destinations: destinations,
    memo: memo,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: configAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: spendingLimit, role: AccountRole.writable),
      AccountMeta(address: rentPayer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getMultisigAddSpendingLimitInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [MultisigAddSpendingLimit] instruction from raw instruction data.
MultisigAddSpendingLimitInstructionData
parseMultisigAddSpendingLimitInstruction(Instruction instruction) {
  return getMultisigAddSpendingLimitInstructionDataDecoder().decode(
    instruction.data!,
  );
}
