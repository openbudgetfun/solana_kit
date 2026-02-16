import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// The filter for logs subscription notifications.
///
/// This is a sealed class hierarchy representing the three possible filter
/// values:
/// - [LogsFilterAll] for `'all'` (all non-vote transactions)
/// - [LogsFilterAllWithVotes] for `'allWithVotes'` (all transactions)
/// - [LogsFilterMentions] for filtering by a specific address
sealed class LogsFilter {
  const LogsFilter();

  /// Converts this filter to its JSON-RPC representation.
  Object toJson();
}

/// Filter that matches all non-vote transactions.
class LogsFilterAll extends LogsFilter {
  /// Creates a new [LogsFilterAll].
  const LogsFilterAll();

  @override
  Object toJson() => 'all';
}

/// Filter that matches all transactions including vote transactions.
class LogsFilterAllWithVotes extends LogsFilter {
  /// Creates a new [LogsFilterAllWithVotes].
  const LogsFilterAllWithVotes();

  @override
  Object toJson() => 'allWithVotes';
}

/// Filter that matches transactions mentioning a specific address.
class LogsFilterMentions extends LogsFilter {
  /// Creates a new [LogsFilterMentions].
  const LogsFilterMentions(this.address);

  /// The address to filter on. Only transactions mentioning this address
  /// will produce notifications.
  final Address address;

  @override
  Object toJson() => {
    'mentions': [address.value],
  };
}

/// Configuration for the `logsSubscribe` RPC subscription method.
///
/// Subscribe to receive notifications containing the logs of transactions.
class LogsNotificationsConfig {
  /// Creates a new [LogsNotificationsConfig].
  const LogsNotificationsConfig({this.commitment});

  /// Get notified on logs from new transactions that have reached this
  /// level of commitment.
  final Commitment? commitment;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    return json;
  }
}

/// Builds the JSON-RPC params list for `logsSubscribe`.
List<Object?> logsNotificationsParams(
  LogsFilter filter, [
  LogsNotificationsConfig? config,
]) {
  return [filter.toJson(), if (config != null) config.toJson()];
}
