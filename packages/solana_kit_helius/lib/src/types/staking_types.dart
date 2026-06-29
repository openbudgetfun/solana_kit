import 'package:solana_kit_helius/src/internal/json_reader.dart';

/// Request to create a stake transaction.
class CreateStakeTransactionRequest {
  /// Creates a stake transaction request.
  const CreateStakeTransactionRequest({
    required this.from,
    required this.amount,
    this.validatorVote,
  });

  /// Creates a [CreateStakeTransactionRequest] from a JSON map.
  factory CreateStakeTransactionRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CreateStakeTransactionRequest(
      from: r.requireString('from'),
      amount: r.requireInt('amount'),
      validatorVote: r.optString('validatorVote'),
    );
  }

  /// Funding wallet address for the stake.
  final String from;

  /// Amount in lamports to stake.
  final int amount;

  /// Vote account of the validator to delegate to.
  final String? validatorVote;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
    'from': from,
    'amount': amount,
    if (validatorVote != null) 'validatorVote': validatorVote,
  };
}

/// Request to create an unstake transaction.
class CreateUnstakeTransactionRequest {
  /// Creates an unstake transaction request.
  const CreateUnstakeTransactionRequest({
    required this.from,
    required this.stakeAccount,
  });

  /// Creates a [CreateUnstakeTransactionRequest] from a JSON map.
  factory CreateUnstakeTransactionRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CreateUnstakeTransactionRequest(
      from: r.requireString('from'),
      stakeAccount: r.requireString('stakeAccount'),
    );
  }

  /// Funding wallet address for the unstake.
  final String from;

  /// Stake account address to unstake.
  final String stakeAccount;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {'from': from, 'stakeAccount': stakeAccount};
}

/// Request to create a withdraw transaction.
class CreateWithdrawTransactionRequest {
  /// Creates a withdraw transaction request.
  const CreateWithdrawTransactionRequest({
    required this.from,
    required this.stakeAccount,
    this.amount,
  });

  /// Creates a [CreateWithdrawTransactionRequest] from a JSON map.
  factory CreateWithdrawTransactionRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CreateWithdrawTransactionRequest(
      from: r.requireString('from'),
      stakeAccount: r.requireString('stakeAccount'),
      amount: r.optInt('amount'),
    );
  }

  /// Funding wallet address for the withdrawal.
  final String from;

  /// Stake account address to withdraw from.
  final String stakeAccount;

  /// Amount in lamports to withdraw, or all if omitted.
  final int? amount;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
    'from': from,
    'stakeAccount': stakeAccount,
    if (amount != null) 'amount': amount,
  };
}

/// Information about a stake account.
class StakeAccountInfo {
  /// Creates stake account information.
  const StakeAccountInfo({
    required this.address,
    required this.lamports,
    required this.state,
    this.voter,
    this.activationEpoch,
    this.deactivationEpoch,
  });

  /// Creates a [StakeAccountInfo] from a JSON map.
  factory StakeAccountInfo.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return StakeAccountInfo(
      address: r.requireString('address'),
      lamports: r.requireInt('lamports'),
      state: r.requireString('state'),
      voter: r.optString('voter'),
      activationEpoch: r.optInt('activationEpoch'),
      deactivationEpoch: r.optInt('deactivationEpoch'),
    );
  }

  /// Address of the stake account.
  final String address;

  /// Balance of the stake account in lamports.
  final int lamports;

  /// Current state of the stake account.
  final String state;

  /// Vote account of the delegated validator.
  final String? voter;

  /// Epoch in which the stake was activated.
  final int? activationEpoch;

  /// Epoch in which the stake was deactivated.
  final int? deactivationEpoch;

  /// Serializes this stake account info to a JSON map.
  Map<String, Object?> toJson() => {
    'address': address,
    'lamports': lamports,
    'state': state,
    if (voter != null) 'voter': voter,
    if (activationEpoch != null) 'activationEpoch': activationEpoch,
    if (deactivationEpoch != null) 'deactivationEpoch': deactivationEpoch,
  };
}

/// Request to get stake accounts for an owner.
class GetHeliusStakeAccountsRequest {
  /// Creates a get-stake-accounts request.
  const GetHeliusStakeAccountsRequest({required this.owner});

  /// Creates a [GetHeliusStakeAccountsRequest] from a JSON map.
  factory GetHeliusStakeAccountsRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetHeliusStakeAccountsRequest(owner: r.requireString('owner'));
  }

  /// Owner address whose stake accounts are returned.
  final String owner;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {'owner': owner};
}

/// Request to get the withdrawable amount from a stake account.
class GetWithdrawableAmountRequest {
  /// Creates a get-withdrawable-amount request.
  const GetWithdrawableAmountRequest({required this.stakeAccount});

  /// Creates a [GetWithdrawableAmountRequest] from a JSON map.
  factory GetWithdrawableAmountRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetWithdrawableAmountRequest(
      stakeAccount: r.requireString('stakeAccount'),
    );
  }

  /// Stake account address to query.
  final String stakeAccount;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {'stakeAccount': stakeAccount};
}

/// The withdrawable amount from a stake account.
class WithdrawableAmount {
  /// Creates a withdrawable amount.
  const WithdrawableAmount({required this.amount});

  /// Creates a [WithdrawableAmount] from a JSON map.
  factory WithdrawableAmount.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return WithdrawableAmount(amount: r.requireInt('amount'));
  }

  /// Withdrawable amount in lamports.
  final int amount;

  /// Serializes this amount to a JSON map.
  Map<String, Object?> toJson() => {'amount': amount};
}

/// Result of a stake transaction creation.
class StakeTransactionResult {
  /// Creates a stake transaction result.
  const StakeTransactionResult({required this.transaction});

  /// Creates a [StakeTransactionResult] from a JSON map.
  factory StakeTransactionResult.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return StakeTransactionResult(transaction: r.requireString('transaction'));
  }

  /// Serialized stake transaction.
  final String transaction;

  /// Serializes this result to a JSON map.
  Map<String, Object?> toJson() => {'transaction': transaction};
}
