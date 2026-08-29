// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

@immutable
class ProgramConfig {
  ProgramConfig({
    required this.authority,
    required this.multisigCreationFee,
    required this.treasury,
    required this.reserved,
  }) : discriminator = Uint8List.fromList([
         0xc4,
         0xd2,
         0x5a,
         0xe7,
         0x90,
         0x95,
         0x8c,
         0x3f,
       ]);

  final Uint8List discriminator;
  final Address authority;
  final BigInt multisigCreationFee;
  final Address treasury;
  final Uint8List reserved;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramConfig &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          authority == other.authority &&
          multisigCreationFee == other.multisigCreationFee &&
          treasury == other.treasury &&
          reserved == other.reserved;

  @override
  int get hashCode => Object.hash(
    discriminator,
    authority,
    multisigCreationFee,
    treasury,
    reserved,
  );

  @override
  String toString() =>
      'ProgramConfig(discriminator: $discriminator, authority: $authority, multisigCreationFee: $multisigCreationFee, treasury: $treasury, reserved: $reserved)';
}

/// The size of the [ProgramConfig] account data in bytes.
const int programConfigSize = 144;

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

Encoder<ProgramConfig> getProgramConfigEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('authority', getAddressEncoder()),
    ('multisigCreationFee', getU64Encoder()),
    ('treasury', getAddressEncoder()),
    ('reserved', fixEncoderSize(getBytesEncoder(), 64, allowTruncation: false)),
  ]);

  return transformEncoder(
    structEncoder,
    (ProgramConfig value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xc4,
        0xd2,
        0x5a,
        0xe7,
        0x90,
        0x95,
        0x8c,
        0x3f,
      ]),
      'authority': value.authority,
      'multisigCreationFee': value.multisigCreationFee,
      'treasury': value.treasury,
      'reserved': value.reserved,
    },
  );
}

Decoder<ProgramConfig> getProgramConfigDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('authority', getAddressDecoder()),
    ('multisigCreationFee', getU64Decoder()),
    ('treasury', getAddressDecoder()),
    ('reserved', fixDecoderSize(getBytesDecoder(), 64)),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'programConfig account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ProgramConfig, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xc4, 0xd2, 0x5a, 0xe7, 0x90, 0x95, 0x8c, 0x3f]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      ProgramConfig(
        authority: map['authority']! as Address,
        multisigCreationFee: map['multisigCreationFee']! as BigInt,
        treasury: map['treasury']! as Address,
        reserved: map['reserved']! as Uint8List,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<ProgramConfig>(
      fixedSize: structDecoder.fixedSize,
      read: (bytes, offset) {
        final bytesLength = bytes.length - offset;
        if (bytesLength < structDecoder.fixedSize) {
          throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
        }
        return readTopLevel(bytes, offset);
      },
    ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<ProgramConfig>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ProgramConfig, ProgramConfig> getProgramConfigCodec() {
  return combineCodec(getProgramConfigEncoder(), getProgramConfigDecoder());
}

Account<ProgramConfig> decodeProgramConfig(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getProgramConfigDecoder());
}
