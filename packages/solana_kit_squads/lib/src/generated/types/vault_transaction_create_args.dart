// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

@immutable
class VaultTransactionCreateArgs {
  const VaultTransactionCreateArgs({
    required this.vaultIndex,
    required this.ephemeralSigners,
    required this.transactionMessage,
    required this.memo,
  });

  final int vaultIndex;
  final int ephemeralSigners;
  final Uint8List transactionMessage;
  final String? memo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaultTransactionCreateArgs &&
          runtimeType == other.runtimeType &&
          vaultIndex == other.vaultIndex &&
          ephemeralSigners == other.ephemeralSigners &&
          _listEquals(transactionMessage, other.transactionMessage) &&
          memo == other.memo;

  @override
  int get hashCode => Object.hash(
    vaultIndex,
    ephemeralSigners,
    _listHashCode(transactionMessage),
    memo,
  );

  @override
  String toString() =>
      'VaultTransactionCreateArgs(vaultIndex: $vaultIndex, ephemeralSigners: $ephemeralSigners, transactionMessage: $transactionMessage, memo: $memo)';
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final left = a[i];
    final right = b[i];
    if (left is List<Object?> && right is List<Object?>) {
      if (!_listEquals(left, right)) return false;
    } else if (left != right) {
      return false;
    }
  }
  return true;
}

Object? _deepHash(Object? value) {
  if (value is List<Object?>) {
    return Object.hashAll(value.map(_deepHash));
  }
  return value;
}

int _listHashCode<T>(List<T>? a) {
  if (a == null) return 0;
  return Object.hashAll(a.map(_deepHash));
}

Encoder<VaultTransactionCreateArgs> getVaultTransactionCreateArgsEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('vaultIndex', getU8Encoder()),
    ('ephemeralSigners', getU8Encoder()),
    (
      'transactionMessage',
      addEncoderSizePrefix(getBytesEncoder(), getU32Encoder()),
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
    (VaultTransactionCreateArgs value) => <String, Object?>{
      'vaultIndex': value.vaultIndex,
      'ephemeralSigners': value.ephemeralSigners,
      'transactionMessage': value.transactionMessage,
      'memo': value.memo,
    },
  );
}

Decoder<VaultTransactionCreateArgs> getVaultTransactionCreateArgsDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('vaultIndex', getU8Decoder()),
    ('ephemeralSigners', getU8Decoder()),
    (
      'transactionMessage',
      addDecoderSizePrefix(getBytesDecoder(), getU32Decoder()),
    ),
    (
      'memo',
      getNullableDecoder<String>(
        addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
      ),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        VaultTransactionCreateArgs(
          vaultIndex: map['vaultIndex']! as int,
          ephemeralSigners: map['ephemeralSigners']! as int,
          transactionMessage: map['transactionMessage']! as Uint8List,
          memo: map['memo'] as String?,
        ),
  );
}

Codec<VaultTransactionCreateArgs, VaultTransactionCreateArgs>
getVaultTransactionCreateArgsCodec() {
  return combineCodec(
    getVaultTransactionCreateArgsEncoder(),
    getVaultTransactionCreateArgsDecoder(),
  );
}
