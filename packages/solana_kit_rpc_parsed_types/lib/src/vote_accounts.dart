import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_parsed_types/src/rpc_parsed_type.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Parsed account data for a vote account.
///
/// This type represents the JSON-parsed data returned by the Solana RPC for
/// vote accounts.
typedef JsonParsedVoteAccount = RpcParsedInfo<JsonParsedVoteInfo>;

/// The info payload for a parsed vote account.
class JsonParsedVoteInfo {
  /// Creates a new [JsonParsedVoteInfo].
  const JsonParsedVoteInfo({
    required this.authorizedVoters,
    required this.authorizedWithdrawer,
    required this.commission,
    required this.epochCredits,
    required this.lastTimestamp,
    required this.nodePubkey,
    required this.priorVoters,
    required this.votes,
    this.rootSlot,
  });

  /// The list of authorized voters and their epochs.
  final List<JsonParsedAuthorizedVoter> authorizedVoters;

  /// The address authorized to withdraw from this vote account.
  final Address authorizedWithdrawer;

  /// The commission percentage (0-100).
  final int commission;

  /// The list of epoch credits.
  final List<JsonParsedEpochCredit> epochCredits;

  /// The last timestamp recorded by this vote account.
  final JsonParsedLastTimestamp lastTimestamp;

  /// The node public key.
  final Address nodePubkey;

  /// The list of prior voters.
  final List<JsonParsedPriorVoter> priorVoters;

  /// The root slot, or `null` if none.
  final Slot? rootSlot;

  /// The list of votes.
  final List<JsonParsedVote> votes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedVoteInfo &&
          runtimeType == other.runtimeType &&
          _listEquals(authorizedVoters, other.authorizedVoters) &&
          authorizedWithdrawer == other.authorizedWithdrawer &&
          commission == other.commission &&
          _listEquals(epochCredits, other.epochCredits) &&
          lastTimestamp == other.lastTimestamp &&
          nodePubkey == other.nodePubkey &&
          _listEquals(priorVoters, other.priorVoters) &&
          rootSlot == other.rootSlot &&
          _listEquals(votes, other.votes);

  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(authorizedVoters),
    authorizedWithdrawer,
    commission,
    Object.hashAll(epochCredits),
    lastTimestamp,
    nodePubkey,
    Object.hashAll(priorVoters),
    rootSlot,
    Object.hashAll(votes),
  );

  @override
  String toString() =>
      'JsonParsedVoteInfo(authorizedVoters: $authorizedVoters, '
      'authorizedWithdrawer: $authorizedWithdrawer, commission: $commission, '
      'epochCredits: $epochCredits, lastTimestamp: $lastTimestamp, '
      'nodePubkey: $nodePubkey, priorVoters: $priorVoters, '
      'rootSlot: $rootSlot, votes: $votes)';
}

/// An authorized voter entry in a vote account.
class JsonParsedAuthorizedVoter {
  /// Creates a new [JsonParsedAuthorizedVoter].
  const JsonParsedAuthorizedVoter({
    required this.authorizedVoter,
    required this.epoch,
  });

  /// The authorized voter address.
  final Address authorizedVoter;

  /// The epoch for which this voter is authorized.
  final Epoch epoch;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedAuthorizedVoter &&
          runtimeType == other.runtimeType &&
          authorizedVoter == other.authorizedVoter &&
          epoch == other.epoch;

  @override
  int get hashCode => Object.hash(runtimeType, authorizedVoter, epoch);

  @override
  String toString() =>
      'JsonParsedAuthorizedVoter(authorizedVoter: $authorizedVoter, '
      'epoch: $epoch)';
}

/// An epoch credit entry in a vote account.
class JsonParsedEpochCredit {
  /// Creates a new [JsonParsedEpochCredit].
  const JsonParsedEpochCredit({
    required this.credits,
    required this.epoch,
    required this.previousCredits,
  });

  /// The credits earned in this epoch.
  final StringifiedBigInt credits;

  /// The epoch number.
  final Epoch epoch;

  /// The credits from the previous epoch.
  final StringifiedBigInt previousCredits;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedEpochCredit &&
          runtimeType == other.runtimeType &&
          credits == other.credits &&
          epoch == other.epoch &&
          previousCredits == other.previousCredits;

  @override
  int get hashCode =>
      Object.hash(runtimeType, credits, epoch, previousCredits);

  @override
  String toString() =>
      'JsonParsedEpochCredit(credits: $credits, epoch: $epoch, '
      'previousCredits: $previousCredits)';
}

/// The last timestamp recorded by a vote account.
class JsonParsedLastTimestamp {
  /// Creates a new [JsonParsedLastTimestamp].
  const JsonParsedLastTimestamp({required this.slot, required this.timestamp});

  /// The slot at which the timestamp was recorded.
  final Slot slot;

  /// The Unix timestamp.
  final UnixTimestamp timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedLastTimestamp &&
          runtimeType == other.runtimeType &&
          slot == other.slot &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(runtimeType, slot, timestamp);

  @override
  String toString() =>
      'JsonParsedLastTimestamp(slot: $slot, timestamp: $timestamp)';
}

/// A prior voter entry in a vote account.
class JsonParsedPriorVoter {
  /// Creates a new [JsonParsedPriorVoter].
  const JsonParsedPriorVoter({
    required this.authorizedPubkey,
    required this.epochOfLastAuthorizedSwitch,
    required this.targetEpoch,
  });

  /// The public key of the prior authorized voter.
  final Address authorizedPubkey;

  /// The epoch of the last authorized switch.
  final Epoch epochOfLastAuthorizedSwitch;

  /// The target epoch.
  final Epoch targetEpoch;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedPriorVoter &&
          runtimeType == other.runtimeType &&
          authorizedPubkey == other.authorizedPubkey &&
          epochOfLastAuthorizedSwitch == other.epochOfLastAuthorizedSwitch &&
          targetEpoch == other.targetEpoch;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    authorizedPubkey,
    epochOfLastAuthorizedSwitch,
    targetEpoch,
  );

  @override
  String toString() =>
      'JsonParsedPriorVoter(authorizedPubkey: $authorizedPubkey, '
      'epochOfLastAuthorizedSwitch: $epochOfLastAuthorizedSwitch, '
      'targetEpoch: $targetEpoch)';
}

/// A vote entry in a vote account.
class JsonParsedVote {
  /// Creates a new [JsonParsedVote].
  const JsonParsedVote({required this.confirmationCount, required this.slot});

  /// The number of confirmations.
  final int confirmationCount;

  /// The slot that was voted on.
  final Slot slot;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedVote &&
          runtimeType == other.runtimeType &&
          confirmationCount == other.confirmationCount &&
          slot == other.slot;

  @override
  int get hashCode => Object.hash(runtimeType, confirmationCount, slot);

  @override
  String toString() =>
      'JsonParsedVote(confirmationCount: $confirmationCount, slot: $slot)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
