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
}
