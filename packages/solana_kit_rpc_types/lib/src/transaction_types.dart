import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_rpc_types/src/encoded_bytes.dart';
import 'package:solana_kit_rpc_types/src/lamports.dart';
import 'package:solana_kit_rpc_types/src/token_balance.dart';
import 'package:solana_kit_rpc_types/src/transaction_error.dart';
import 'package:solana_kit_rpc_types/src/typed_numbers.dart';

// ---------------------------------------------------------------------------
// Transaction Version
// ---------------------------------------------------------------------------

/// The version of a transaction.
///
/// Either [TransactionVersionLegacy] or [TransactionVersionV0].
sealed class TransactionVersion {
  const TransactionVersion();
}

/// Legacy transaction version.
class TransactionVersionLegacy extends TransactionVersion {
  const TransactionVersionLegacy();

  @override
  String toString() => 'legacy';
}

/// Version 0 transaction.
class TransactionVersionV0 extends TransactionVersion {
  const TransactionVersionV0();

  @override
  String toString() => '0';
}

// ---------------------------------------------------------------------------
// Address Table Lookup
// ---------------------------------------------------------------------------

/// An address lookup table reference within a versioned transaction.
class AddressTableLookup {
  const AddressTableLookup({
    required this.accountKey,
    required this.readonlyIndexes,
    required this.writableIndexes,
  });

  /// Address of the address lookup table account.
  final Address accountKey;

  /// Indexes of accounts in a lookup table to load as read-only.
  final List<int> readonlyIndexes;

  /// Indexes of accounts in a lookup table to load as writable.
  final List<int> writableIndexes;
}

// ---------------------------------------------------------------------------
// Reward
// ---------------------------------------------------------------------------

/// Represents a reward credited or debited to an account.
sealed class Reward {
  const Reward();

  /// The number of reward lamports credited or debited to the account.
  SignedLamports get rewardLamports;

  /// The account balance in lamports after the reward was applied.
  Lamports get postBalance;

  /// The address of the account that received the reward.
  Address get pubkey;

  /// The type of reward.
  String get rewardType;
}

/// A fee or rent reward (no commission).
class RewardFeeOrRent extends Reward {
  const RewardFeeOrRent({
    required this.rewardLamports,
    required this.postBalance,
    required this.pubkey,
    required this.rewardType,
  });

  @override
  final SignedLamports rewardLamports;

  @override
  final Lamports postBalance;

  @override
  final Address pubkey;

  @override
  final String rewardType;
}

/// A voting or staking reward (includes commission).
class RewardVotingOrStaking extends Reward {
  const RewardVotingOrStaking({
    required this.rewardLamports,
    required this.postBalance,
    required this.pubkey,
    required this.rewardType,
    required this.commission,
  });

  @override
  final SignedLamports rewardLamports;

  @override
  final Lamports postBalance;

  @override
  final Address pubkey;

  @override
  final String rewardType;

  /// The vote account commission when the reward was credited.
  final int commission;
}

// ---------------------------------------------------------------------------
// Transaction Status (deprecated)
// ---------------------------------------------------------------------------

/// Deprecated transaction status type.
@Deprecated('Use TransactionError instead')
sealed class TransactionStatus {
  @Deprecated('Use TransactionError instead')
  const TransactionStatus();
}

/// Transaction succeeded.
@Deprecated('Use TransactionError instead')
class TransactionStatusOk extends TransactionStatus {
  @Deprecated('Use TransactionError instead')
  const TransactionStatusOk();
}

/// Transaction failed with an error.
@Deprecated('Use TransactionError instead')
class TransactionStatusErr extends TransactionStatus {
  @Deprecated('Use TransactionError instead')
  const TransactionStatusErr(this.error);

  /// The error that caused the transaction to fail.
  final TransactionError error;
}

// ---------------------------------------------------------------------------
// Transaction Meta
// ---------------------------------------------------------------------------

/// Base transaction metadata shared by all transaction detail levels.
class TransactionForAccountsMetaBase {
  const TransactionForAccountsMetaBase({
    required this.err,
    required this.fee,
    required this.postBalances,
    required this.preBalances,
    this.postTokenBalances,
    this.preTokenBalances,
  });

  /// Error if transaction failed, `null` if transaction succeeded.
  final TransactionError? err;

  /// The fee this transaction was charged, in lamports.
  final Lamports fee;

  /// Account balances after the transaction was processed.
  final List<Lamports> postBalances;

  /// List of token balances from after the transaction was processed.
  final List<TokenBalance>? postTokenBalances;

  /// Account balances from before the transaction was processed.
  final List<Lamports> preBalances;

  /// List of token balances from before the transaction was processed.
  final List<TokenBalance>? preTokenBalances;
}

// ---------------------------------------------------------------------------
// Return Data
// ---------------------------------------------------------------------------

/// Return data from a transaction.
class ReturnData {
  const ReturnData({required this.data, required this.programId});

  /// The return data as a base64-encoded response.
  final Base64EncodedDataResponse data;

  /// The address of the program that generated the return data.
  final Address programId;
}

// ---------------------------------------------------------------------------
// Parsed Account
// ---------------------------------------------------------------------------

/// A parsed account key in a transaction.
class TransactionParsedAccount {
  const TransactionParsedAccount({
    required this.pubkey,
    required this.signer,
    required this.writable,
    required this.source,
  });

  /// The address of the account.
  final Address pubkey;

  /// Whether this account is required to sign the transaction.
  final bool signer;

  /// Whether this account must be loaded with a write-lock.
  final bool writable;

  /// Indicates whether the account was statically declared in the transaction
  /// message or loaded from an address lookup table.
  final String source;
}
