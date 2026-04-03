// ignore_for_file: public_member_api_docs
import 'package:solana_kit_helius/src/internal/json_reader.dart';

/// Request to create a stake transaction.
class CreateStakeTransactionRequest {
  const CreateStakeTransactionRequest({
    required this.from,
    required this.amount,
    this.validatorVote,
  });

  factory CreateStakeTransactionRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CreateStakeTransactionRequest(
      from: r.requireString('from'),
      amount: r.requireInt('amount'),
      validatorVote: r.optString('validatorVote'),
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
    final r = JsonReader(json);
    return CreateUnstakeTransactionRequest(
      from: r.requireString('from'),
      stakeAccount: r.requireString('stakeAccount'),
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
    final r = JsonReader(json);
    return CreateWithdrawTransactionRequest(
      from: r.requireString('from'),
      stakeAccount: r.requireString('stakeAccount'),
      amount: r.optInt('amount'),
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
    final r = JsonReader(json);
    return GetHeliusStakeAccountsRequest(owner: r.requireString('owner'));
  }

  final String owner;

  Map<String, Object?> toJson() => {'owner': owner};
}

/// Request to get the withdrawable amount from a stake account.
class GetWithdrawableAmountRequest {
  const GetWithdrawableAmountRequest({required this.stakeAccount});

  factory GetWithdrawableAmountRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetWithdrawableAmountRequest(
      stakeAccount: r.requireString('stakeAccount'),
    );
  }

  final String stakeAccount;

  Map<String, Object?> toJson() => {'stakeAccount': stakeAccount};
}

/// The withdrawable amount from a stake account.
class WithdrawableAmount {
  const WithdrawableAmount({required this.amount});

  factory WithdrawableAmount.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return WithdrawableAmount(amount: r.requireInt('amount'));
  }

  final int amount;

  Map<String, Object?> toJson() => {'amount': amount};
}

/// Result of a stake transaction creation.
class StakeTransactionResult {
  const StakeTransactionResult({required this.transaction});

  factory StakeTransactionResult.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return StakeTransactionResult(transaction: r.requireString('transaction'));
  }

  final String transaction;

  Map<String, Object?> toJson() => {'transaction': transaction};
}
