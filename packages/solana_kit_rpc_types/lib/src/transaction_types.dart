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
  /// Creates a legacy transaction version marker.
  const TransactionVersionLegacy();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TransactionVersionLegacy;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'legacy';
}

/// Version 0 transaction.
class TransactionVersionV0 extends TransactionVersion {
  /// Creates a version 0 transaction version marker.
  const TransactionVersionV0();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TransactionVersionV0;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => '0';
}

// ---------------------------------------------------------------------------
// Address Table Lookup
// ---------------------------------------------------------------------------

/// An address lookup table reference within a versioned transaction.
class AddressTableLookup {
  /// Creates an address table lookup reference.
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressTableLookup &&
          runtimeType == other.runtimeType &&
          accountKey == other.accountKey &&
          _listEquals(readonlyIndexes, other.readonlyIndexes) &&
          _listEquals(writableIndexes, other.writableIndexes);

  @override
  int get hashCode => Object.hash(
    runtimeType,
    accountKey,
    Object.hashAll(readonlyIndexes),
    Object.hashAll(writableIndexes),
  );

  @override
  String toString() =>
      'AddressTableLookup(accountKey: $accountKey, '
      'readonlyIndexes: $readonlyIndexes, writableIndexes: $writableIndexes)';
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
  /// Creates a fee or rent reward.
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardFeeOrRent &&
          runtimeType == other.runtimeType &&
          rewardLamports == other.rewardLamports &&
          postBalance == other.postBalance &&
          pubkey == other.pubkey &&
          rewardType == other.rewardType;

  @override
  int get hashCode =>
      Object.hash(runtimeType, rewardLamports, postBalance, pubkey, rewardType);

  @override
  String toString() =>
      'RewardFeeOrRent(rewardLamports: $rewardLamports, '
      'postBalance: $postBalance, pubkey: $pubkey, rewardType: $rewardType)';
}

/// A voting or staking reward (includes commission).
class RewardVotingOrStaking extends Reward {
  /// Creates a voting or staking reward.
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardVotingOrStaking &&
          runtimeType == other.runtimeType &&
          rewardLamports == other.rewardLamports &&
          postBalance == other.postBalance &&
          pubkey == other.pubkey &&
          rewardType == other.rewardType &&
          commission == other.commission;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    rewardLamports,
    postBalance,
    pubkey,
    rewardType,
    commission,
  );

  @override
  String toString() =>
      'RewardVotingOrStaking(rewardLamports: $rewardLamports, '
      'postBalance: $postBalance, pubkey: $pubkey, rewardType: $rewardType, '
      'commission: $commission)';
}

// ---------------------------------------------------------------------------
// Transaction Meta
// ---------------------------------------------------------------------------

/// Base transaction metadata shared by all transaction detail levels.
class TransactionForAccountsMetaBase {
  /// Creates the shared transaction metadata.
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionForAccountsMetaBase &&
          runtimeType == other.runtimeType &&
          err == other.err &&
          fee == other.fee &&
          _listEquals(postBalances, other.postBalances) &&
          _nullableListEquals(postTokenBalances, other.postTokenBalances) &&
          _listEquals(preBalances, other.preBalances) &&
          _nullableListEquals(preTokenBalances, other.preTokenBalances);

  @override
  int get hashCode => Object.hash(
    runtimeType,
    err,
    fee,
    Object.hashAll(postBalances),
    postTokenBalances == null ? null : Object.hashAll(postTokenBalances!),
    Object.hashAll(preBalances),
    preTokenBalances == null ? null : Object.hashAll(preTokenBalances!),
  );

  @override
  String toString() =>
      'TransactionForAccountsMetaBase(err: $err, fee: $fee, '
      'postBalances: $postBalances, postTokenBalances: $postTokenBalances, '
      'preBalances: $preBalances, preTokenBalances: $preTokenBalances)';
}

// ---------------------------------------------------------------------------
// Return Data
// ---------------------------------------------------------------------------

/// Return data from a transaction.
class ReturnData {
  /// Creates the return data from a transaction.
  const ReturnData({required this.data, required this.programId});

  /// The return data as a base64-encoded response.
  final Base64EncodedDataResponse data;

  /// The address of the program that generated the return data.
  final Address programId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReturnData &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          programId == other.programId;

  @override
  int get hashCode => Object.hash(runtimeType, data, programId);

  @override
  String toString() => 'ReturnData(data: $data, programId: $programId)';
}

// ---------------------------------------------------------------------------
// Parsed Account
// ---------------------------------------------------------------------------

/// A parsed account key in a transaction.
class TransactionParsedAccount {
  /// Creates a parsed account entry in a transaction.
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionParsedAccount &&
          runtimeType == other.runtimeType &&
          pubkey == other.pubkey &&
          signer == other.signer &&
          writable == other.writable &&
          source == other.source;

  @override
  int get hashCode =>
      Object.hash(runtimeType, pubkey, signer, writable, source);

  @override
  String toString() =>
      'TransactionParsedAccount(pubkey: $pubkey, signer: $signer, '
      'writable: $writable, source: $source)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _nullableListEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  return _listEquals(a, b);
}
