import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_parsed_types/src/rpc_parsed_type.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Parsed account data for a nonce account.
///
/// This type represents the JSON-parsed data returned by the Solana RPC for
/// nonce accounts.
typedef JsonParsedNonceAccount = RpcParsedInfo<JsonParsedNonceInfo>;

/// The info payload for a parsed nonce account.
class JsonParsedNonceInfo {
  /// Creates a new [JsonParsedNonceInfo].
  const JsonParsedNonceInfo({
    required this.authority,
    required this.blockhash,
    required this.feeCalculator,
  });

  /// The authority address that can advance the nonce.
  final Address authority;

  /// The stored blockhash.
  final Blockhash blockhash;

  /// The fee calculator associated with this nonce.
  final JsonParsedNonceFeeCalculator feeCalculator;
}

/// The fee calculator within a nonce account.
class JsonParsedNonceFeeCalculator {
  /// Creates a new [JsonParsedNonceFeeCalculator].
  const JsonParsedNonceFeeCalculator({required this.lamportsPerSignature});

  /// The fee in lamports charged per signature.
  final StringifiedBigInt lamportsPerSignature;
}
