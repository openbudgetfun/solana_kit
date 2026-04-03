import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_parsed_types/src/rpc_parsed_type.dart';

/// Parsed account data for a Config program account.
///
/// This is a discriminated union that can be either a
/// [JsonParsedStakeConfig] ('stakeConfig') or a
/// [JsonParsedValidatorInfo] ('validatorInfo').
sealed class JsonParsedConfigProgramAccount {
  const JsonParsedConfigProgramAccount();
}

/// A parsed Config program 'stakeConfig' variant.
class JsonParsedStakeConfig
    extends RpcParsedType<String, JsonParsedStakeConfigInfo>
    implements JsonParsedConfigProgramAccount {
  /// Creates a new [JsonParsedStakeConfig].
  const JsonParsedStakeConfig({required super.info})
    : super(type: 'stakeConfig');
}

/// The info payload for a parsed stake config account.
class JsonParsedStakeConfigInfo {
  /// Creates a new [JsonParsedStakeConfigInfo].
  const JsonParsedStakeConfigInfo({
    required this.slashPenalty,
    required this.warmupCooldownRate,
  });

  /// The slash penalty percentage.
  final int slashPenalty;

  /// The warmup/cooldown rate.
  final double warmupCooldownRate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedStakeConfigInfo &&
          runtimeType == other.runtimeType &&
          slashPenalty == other.slashPenalty &&
          warmupCooldownRate == other.warmupCooldownRate;

  @override
  int get hashCode => Object.hash(runtimeType, slashPenalty, warmupCooldownRate);

  @override
  String toString() =>
      'JsonParsedStakeConfigInfo(slashPenalty: $slashPenalty, '
      'warmupCooldownRate: $warmupCooldownRate)';
}

/// A parsed Config program 'validatorInfo' variant.
class JsonParsedValidatorInfo
    extends RpcParsedType<String, JsonParsedValidatorInfoData>
    implements JsonParsedConfigProgramAccount {
  /// Creates a new [JsonParsedValidatorInfo].
  const JsonParsedValidatorInfo({required super.info})
    : super(type: 'validatorInfo');
}

/// The info payload for a parsed validator info account.
class JsonParsedValidatorInfoData {
  /// Creates a new [JsonParsedValidatorInfoData].
  const JsonParsedValidatorInfoData({
    required this.configData,
    required this.keys,
  });

  /// The config data associated with the validator.
  ///
  /// This is an opaque value whose structure depends on the validator's
  /// configuration.
  final Object? configData;

  /// The list of keys associated with this validator info.
  final List<JsonParsedValidatorInfoKey> keys;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedValidatorInfoData &&
          runtimeType == other.runtimeType &&
          configData == other.configData &&
          _listEquals(keys, other.keys);

  @override
  int get hashCode =>
      Object.hash(runtimeType, configData, Object.hashAll(keys));

  @override
  String toString() =>
      'JsonParsedValidatorInfoData(configData: $configData, keys: $keys)';
}

/// A key entry in a parsed validator info account.
class JsonParsedValidatorInfoKey {
  /// Creates a new [JsonParsedValidatorInfoKey].
  const JsonParsedValidatorInfoKey({
    required this.pubkey,
    required this.signer,
  });

  /// The public key address.
  final Address pubkey;

  /// Whether this key is a signer.
  final bool signer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedValidatorInfoKey &&
          runtimeType == other.runtimeType &&
          pubkey == other.pubkey &&
          signer == other.signer;

  @override
  int get hashCode => Object.hash(runtimeType, pubkey, signer);

  @override
  String toString() =>
      'JsonParsedValidatorInfoKey(pubkey: $pubkey, signer: $signer)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
