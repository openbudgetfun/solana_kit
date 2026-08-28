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
          transactionMessage == other.transactionMessage &&
          memo == other.memo;

  @override
  int get hashCode =>
      Object.hash(vaultIndex, ephemeralSigners, transactionMessage, memo);

  @override
  String toString() =>
      'VaultTransactionCreateArgs(vaultIndex: $vaultIndex, ephemeralSigners: $ephemeralSigners, transactionMessage: $transactionMessage, memo: $memo)';
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
        addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
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
