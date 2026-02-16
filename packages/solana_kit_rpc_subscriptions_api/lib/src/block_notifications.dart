import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// The filter for block subscription notifications.
///
/// This is a sealed class hierarchy representing the two possible filter
/// values:
/// - [BlockFilterAll] for `'all'` (all transactions)
/// - [BlockFilterMentionsAccountOrProgram] for filtering by a specific address
sealed class BlockNotificationsFilter {
  const BlockNotificationsFilter();

  /// Converts this filter to its JSON-RPC representation.
  Object toJson();
}

/// Filter that matches all transactions in a block.
class BlockFilterAll extends BlockNotificationsFilter {
  /// Creates a new [BlockFilterAll].
  const BlockFilterAll();

  @override
  Object toJson() => 'all';
}

/// Filter that matches transactions mentioning a specific account or program.
class BlockFilterMentionsAccountOrProgram extends BlockNotificationsFilter {
  /// Creates a new [BlockFilterMentionsAccountOrProgram].
  const BlockFilterMentionsAccountOrProgram(this.address);

  /// The address to filter on. Only blocks containing transactions that
  /// mention this address will produce notifications.
  final Address address;

  @override
  Object toJson() => {'mentionsAccountOrProgram': address.value};
}

/// Configuration for the `blockSubscribe` RPC subscription method.
///
/// This subscription is unstable and may change in the future.
///
/// Subscribe to receive notifications anytime a new block reaches the
/// specified level of commitment.
class BlockNotificationsConfig {
  /// Creates a new [BlockNotificationsConfig].
  const BlockNotificationsConfig({
    this.commitment,
    this.encoding,
    this.maxSupportedTransactionVersion,
    this.showRewards,
    this.transactionDetails,
  });

  /// Get notified when a new block has reached this level of commitment.
  ///
  /// Note: `processed` is not supported for this method.
  final Commitment? commitment;

  /// Determines how the transaction property should be encoded in the
  /// response.
  ///
  /// One of `'base58'`, `'base64'`, `'json'`, or `'jsonParsed'`.
  /// Defaults to `'json'`.
  final String? encoding;

  /// The newest transaction version the caller wants to receive.
  ///
  /// When not supplied, only legacy transactions are returned.
  /// Set to `0` for version 0 transactions.
  final int? maxSupportedTransactionVersion;

  /// Whether to include block rewards. Defaults to `true`.
  final bool? showRewards;

  /// Level of transaction detail to include.
  ///
  /// One of `'accounts'`, `'full'`, `'none'`, or `'signatures'`.
  /// Defaults to `'full'`.
  final String? transactionDetails;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    if (encoding != null) json['encoding'] = encoding;
    if (maxSupportedTransactionVersion != null) {
      json['maxSupportedTransactionVersion'] = maxSupportedTransactionVersion;
    }
    if (showRewards != null) json['showRewards'] = showRewards;
    if (transactionDetails != null) {
      json['transactionDetails'] = transactionDetails;
    }
    return json;
  }
}

/// Builds the JSON-RPC params list for `blockSubscribe`.
List<Object?> blockNotificationsParams(
  BlockNotificationsFilter filter, [
  BlockNotificationsConfig? config,
]) {
  return [filter.toJson(), if (config != null) config.toJson()];
}
