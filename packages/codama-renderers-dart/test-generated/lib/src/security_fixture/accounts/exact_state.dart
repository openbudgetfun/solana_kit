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
class ExactState {
  const ExactState({
    required this.value,
  });

  final int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExactState &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExactState(value: $value)';
}


Encoder<ExactState> getExactStateEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('value', getU16Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ExactState value) => <String, Object?>{
      'value': value.value,
    },
  );
}

Decoder<ExactState> getExactStateDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('value', getU16Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'exactState account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ExactState, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      ExactState(
      value: map['value']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ExactState>(
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
      VariableSizeDecoder<ExactState>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ExactState, ExactState> getExactStateCodec() {
  return combineCodec(getExactStateEncoder(), getExactStateDecoder());
}

Account<ExactState> decodeExactState(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getExactStateDecoder());
}
