// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import '../types/key.dart';

@immutable
class EditionMarkerV2 {
  const EditionMarkerV2({
    required this.key,
    required this.ledger,
  });

  final Key key;
  final Uint8List ledger;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditionMarkerV2 &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          ledger == other.ledger;

  @override
  int get hashCode => Object.hash(key, ledger);

  @override
  String toString() => 'EditionMarkerV2(key: $key, ledger: $ledger)';
}

Encoder<EditionMarkerV2> getEditionMarkerV2Encoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('ledger', addEncoderSizePrefix(getBytesEncoder(), getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (EditionMarkerV2 value) => <String, Object?>{
      'key': value.key,
      'ledger': value.ledger,
    },
  );
}

Decoder<EditionMarkerV2> getEditionMarkerV2Decoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('ledger', addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'editionMarkerV2 account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (EditionMarkerV2, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      EditionMarkerV2(
        key: map['key']! as Key,
        ledger: map['ledger']! as Uint8List,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<EditionMarkerV2>(
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
      VariableSizeDecoder<EditionMarkerV2>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<EditionMarkerV2, EditionMarkerV2> getEditionMarkerV2Codec() {
  return combineCodec(getEditionMarkerV2Encoder(), getEditionMarkerV2Decoder());
}

Account<EditionMarkerV2> decodeEditionMarkerV2(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getEditionMarkerV2Decoder());
}
