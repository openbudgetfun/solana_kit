/// Request to create a stake transaction.
class CreateStakeTransactionRequest {
  const CreateStakeTransactionRequest({
    required this.from,
    required this.amount,
    this.validatorVote,
  });

  factory CreateStakeTransactionRequest.fromJson(Map<String, Object?> json) {
    return CreateStakeTransactionRequest(
      from: json['from']! as String,
      amount: json['amount']! as int,
      validatorVote: json['validatorVote'] as String?,
    );
  }

  final String from;
  final int amount;
  final String? validatorVote;

  Map<String, Object?> toJson() => {
    'from': from,
    'amount': amount,
    if (validatorVote != null) 'validatorVote': validatorVote,
  };
}

/// Request to create an unstake transaction.
class CreateUnstakeTransactionRequest {
  const CreateUnstakeTransactionRequest({
    required this.from,
    required this.stakeAccount,
  });

  factory CreateUnstakeTransactionRequest.fromJson(Map<String, Object?> json) {
    return CreateUnstakeTransactionRequest(
      from: json['from']! as String,
      stakeAccount: json['stakeAccount']! as String,
    );
  }

  final String from;
  final String stakeAccount;

  Map<String, Object?> toJson() => {'from': from, 'stakeAccount': stakeAccount};
}

/// Request to create a withdraw transaction.
class CreateWithdrawTransactionRequest {
  const CreateWithdrawTransactionRequest({
    required this.from,
    required this.stakeAccount,
    this.amount,
  });

  factory CreateWithdrawTransactionRequest.fromJson(Map<String, Object?> json) {
    return CreateWithdrawTransactionRequest(
      from: json['from']! as String,
      stakeAccount: json['stakeAccount']! as String,
      amount: json['amount'] as int?,
    );
  }

  final String from;
  final String stakeAccount;
  final int? amount;

  Map<String, Object?> toJson() => {
    'from': from,
    'stakeAccount': stakeAccount,
    if (amount != null) 'amount': amount,
  };
}

/// Information about a stake account.
class StakeAccountInfo {
  const StakeAccountInfo({
    required this.address,
    required this.lamports,
    required this.state,
    this.voter,
    this.activationEpoch,
    this.deactivationEpoch,
  });

  factory StakeAccountInfo.fromJson(Map<String, Object?> json) {
    return StakeAccountInfo(
      address: json['address']! as String,
      lamports: json['lamports']! as int,
      state: json['state']! as String,
      voter: json['voter'] as String?,
      activationEpoch: json['activationEpoch'] as int?,
      deactivationEpoch: json['deactivationEpoch'] as int?,
    );
  }

  final String address;
  final int lamports;
  final String state;
  final String? voter;
  final int? activationEpoch;
  final int? deactivationEpoch;

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
  const GetHeliusStakeAccountsRequest({required this.owner});

  factory GetHeliusStakeAccountsRequest.fromJson(Map<String, Object?> json) {
    return GetHeliusStakeAccountsRequest(owner: json['owner']! as String);
  }

  final String owner;

  Map<String, Object?> toJson() => {'owner': owner};
}

/// Request to get the withdrawable amount from a stake account.
class GetWithdrawableAmountRequest {
  const GetWithdrawableAmountRequest({required this.stakeAccount});

  factory GetWithdrawableAmountRequest.fromJson(Map<String, Object?> json) {
    return GetWithdrawableAmountRequest(
      stakeAccount: json['stakeAccount']! as String,
    );
  }

  final String stakeAccount;

  Map<String, Object?> toJson() => {'stakeAccount': stakeAccount};
}

/// The withdrawable amount from a stake account.
class WithdrawableAmount {
  const WithdrawableAmount({required this.amount});

  factory WithdrawableAmount.fromJson(Map<String, Object?> json) {
    return WithdrawableAmount(amount: json['amount']! as int);
  }

  final int amount;

  Map<String, Object?> toJson() => {'amount': amount};
}

/// Result of a stake transaction creation.
class StakeTransactionResult {
  const StakeTransactionResult({required this.transaction});

  factory StakeTransactionResult.fromJson(Map<String, Object?> json) {
    return StakeTransactionResult(transaction: json['transaction']! as String);
  }

  final String transaction;

  Map<String, Object?> toJson() => {'transaction': transaction};
}
