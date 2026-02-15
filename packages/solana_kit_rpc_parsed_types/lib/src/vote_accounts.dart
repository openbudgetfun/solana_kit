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
}

/// The last timestamp recorded by a vote account.
class JsonParsedLastTimestamp {
  /// Creates a new [JsonParsedLastTimestamp].
  const JsonParsedLastTimestamp({required this.slot, required this.timestamp});

  /// The slot at which the timestamp was recorded.
  final Slot slot;

  /// The Unix timestamp.
  final UnixTimestamp timestamp;
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
}

/// A vote entry in a vote account.
class JsonParsedVote {
  /// Creates a new [JsonParsedVote].
  const JsonParsedVote({required this.confirmationCount, required this.slot});

  /// The number of confirmations.
  final int confirmationCount;

  /// The slot that was voted on.
  final Slot slot;
}
