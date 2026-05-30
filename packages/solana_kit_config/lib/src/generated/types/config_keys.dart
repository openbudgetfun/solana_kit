// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

/// A key stored in Config account data.
@immutable
class ConfigKey {
  /// Creates [ConfigKey].
  const ConfigKey({required this.address, required this.isSigner});

  /// The public key identifier.
  final Address address;

  /// Whether [address] must sign subsequent `store` calls.
  final bool isSigner;

  @override
  String toString() => 'ConfigKey(address: $address, isSigner: $isSigner)';

  @override
  bool operator ==(Object other) =>
      other is ConfigKey &&
      other.address == address &&
      other.isSigner == isSigner;

  @override
  int get hashCode => Object.hash(address, isSigner);
}

/// A collection of keys to be stored in Config account data.
typedef ConfigKeys = List<ConfigKey>;

/// Returns the encoder for [ConfigKey].
Encoder<ConfigKey> getConfigKeyEncoder() {
  final tupleEncoder = getTupleEncoder(<Encoder<Object?>>[
    getAddressEncoder(),
    getBooleanEncoder(),
  ]);

  return transformEncoder(
    tupleEncoder,
    (ConfigKey value) => <Object?>[value.address, value.isSigner],
  );
}

/// Returns the decoder for [ConfigKey].
Decoder<ConfigKey> getConfigKeyDecoder() {
  final tupleDecoder = getTupleDecoder(<Decoder<Object?>>[
    getAddressDecoder(),
    getBooleanDecoder(),
  ]);

  return transformDecoder(
    tupleDecoder,
    (List<Object?> tuple, bytes, offset) =>
        ConfigKey(address: tuple[0]! as Address, isSigner: tuple[1]! as bool),
  );
}

/// Returns the codec for [ConfigKey].
Codec<ConfigKey, ConfigKey> getConfigKeyCodec() =>
    combineCodec(getConfigKeyEncoder(), getConfigKeyDecoder());

/// Returns the encoder for [ConfigKeys].
Encoder<ConfigKeys> getConfigKeysEncoder() => getArrayEncoder(
  getConfigKeyEncoder(),
  size: PrefixedArraySize(getShortU16Encoder()),
);

/// Returns the decoder for [ConfigKeys].
Decoder<ConfigKeys> getConfigKeysDecoder() => getArrayDecoder(
  getConfigKeyDecoder(),
  size: PrefixedArraySize(getShortU16Decoder()),
);

/// Returns the codec for [ConfigKeys].
Codec<ConfigKeys, ConfigKeys> getConfigKeysCodec() =>
    combineCodec(getConfigKeysEncoder(), getConfigKeysDecoder());
