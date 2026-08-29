// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import '../types/key.dart';

@immutable
class EditionMarker {
  const EditionMarker({
    required this.key,
    required this.ledger,
  });

  final Key key;
  final Uint8List ledger;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditionMarker &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          ledger == other.ledger;

  @override
  int get hashCode => Object.hash(key, ledger);

  @override
  String toString() => 'EditionMarker(key: $key, ledger: $ledger)';
}

/// The size of the [EditionMarker] account data in bytes.
const int editionMarkerSize = 32;

Encoder<EditionMarker> getEditionMarkerEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('ledger', fixEncoderSize(getBytesEncoder(), 31, allowTruncation: false)),
  ]);

  return transformEncoder(
    structEncoder,
    (EditionMarker value) => <String, Object?>{
      'key': value.key,
      'ledger': value.ledger,
    },
  );
}

Decoder<EditionMarker> getEditionMarkerDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('ledger', fixDecoderSize(getBytesDecoder(), 31)),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'editionMarker account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (EditionMarker, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      EditionMarker(
        key: map['key']! as Key,
        ledger: map['ledger']! as Uint8List,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<EditionMarker>(
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
      VariableSizeDecoder<EditionMarker>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<EditionMarker, EditionMarker> getEditionMarkerCodec() {
  return combineCodec(getEditionMarkerEncoder(), getEditionMarkerDecoder());
}

Account<EditionMarker> decodeEditionMarker(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getEditionMarkerDecoder());
}
