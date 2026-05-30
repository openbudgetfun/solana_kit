// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_config/src/generated/types/config_keys.dart';

/// Data stored in a Config program account.
@immutable
class ConfigAccount {
  /// Creates [ConfigAccount].
  const ConfigAccount({required this.keys, required this.data});

  /// List of pubkeys stored in the config account.
  final ConfigKeys keys;

  /// Arbitrary data stored in the config account.
  final Uint8List data;

  @override
  String toString() => 'ConfigAccount(keys: $keys, data: $data)';

  @override
  bool operator ==(Object other) =>
      other is ConfigAccount &&
      _configKeysEqual(other.keys, keys) &&
      _bytesEqual(other.data, data);

  @override
  int get hashCode => Object.hash(Object.hashAll(keys), Object.hashAll(data));
}

/// Returns the encoder for [ConfigAccount].
Encoder<ConfigAccount> getConfigAccountEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('keys', getConfigKeysEncoder()),
    ('data', getBytesEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ConfigAccount value) => <String, Object?>{
      'keys': value.keys,
      'data': value.data,
    },
  );
}

/// Returns the decoder for [ConfigAccount].
Decoder<ConfigAccount> getConfigAccountDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('keys', getConfigKeysDecoder()),
    ('data', getBytesDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, bytes, offset) => ConfigAccount(
      keys: map['keys']! as ConfigKeys,
      data: map['data']! as Uint8List,
    ),
  );
}

/// Returns the codec for [ConfigAccount].
Codec<ConfigAccount, ConfigAccount> getConfigAccountCodec() =>
    combineCodec(getConfigAccountEncoder(), getConfigAccountDecoder());

/// Decodes [encodedAccount] into a typed Config account.
Account<ConfigAccount> decodeConfigAccount(EncodedAccount encodedAccount) =>
    Account<ConfigAccount>(
      address: encodedAccount.address,
      data: getConfigAccountDecoder().decode(encodedAccount.data),
      executable: encodedAccount.executable,
      lamports: encodedAccount.lamports,
      programAddress: encodedAccount.programAddress,
      space: encodedAccount.space,
    );

bool _configKeysEqual(ConfigKeys left, ConfigKeys right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

bool _bytesEqual(Uint8List left, Uint8List right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
