// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';


@immutable
class SecureState {
  const SecureState({
    required this.value,
  }) :
      discriminator = 7;

  final int discriminator;
  final int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecureState &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          value == other.value;

  @override
  int get hashCode => Object.hash(discriminator, value);

  @override
  String toString() => 'SecureState(discriminator: $discriminator, value: $value)';
}


/// The size of the [SecureState] account data in bytes.
const int secureStateSize = 3;

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

/// This account has a size discriminator of 3 bytes.


Encoder<SecureState> getSecureStateEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('value', getU16Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SecureState value) => <String, Object?>{
      'discriminator': 7,
      'value': value.value,
    },
  );
}

Decoder<SecureState> getSecureStateDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('value', getU16Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'secureState account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (SecureState, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(7),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(7),
    ).read(bytes, offset + 0);
    if (bytes.length - offset != 3) {
      throw SolanaError(
        SolanaErrorCode.codecsInvalidByteLength,
        {
          'codecDescription': 'secureState discriminator',
          'expected': 3,
          'bytesLength': bytes.length - offset,
        },
      );
    }
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      SecureState(
      value: map['value']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<SecureState>(
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
      VariableSizeDecoder<SecureState>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<SecureState, SecureState> getSecureStateCodec() {
  return combineCodec(getSecureStateEncoder(), getSecureStateDecoder());
}

Account<SecureState> decodeSecureState(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getSecureStateDecoder());
}
