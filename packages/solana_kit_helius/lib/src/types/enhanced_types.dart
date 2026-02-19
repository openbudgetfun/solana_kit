import 'package:solana_kit_helius/src/types/enums.dart';

/// Request to get transactions by their signatures.
class GetTransactionsRequest {
  const GetTransactionsRequest({required this.transactions});

  factory GetTransactionsRequest.fromJson(Map<String, Object?> json) {
    return GetTransactionsRequest(
      transactions: (json['transactions']! as List<Object?>).cast<String>(),
    );
  }

  final List<String> transactions;

  Map<String, Object?> toJson() => {'transactions': transactions};
}

/// Request to get transactions by address.
class GetTransactionsByAddressRequest {
  const GetTransactionsByAddressRequest({
    required this.address,
    this.before,
    this.until,
    this.commitment,
    this.type,
  });

  factory GetTransactionsByAddressRequest.fromJson(Map<String, Object?> json) {
    return GetTransactionsByAddressRequest(
      address: json['address']! as String,
      before: json['before'] as String?,
      until: json['until'] as String?,
      commitment: json['commitment'] != null
          ? CommitmentLevel.fromJson(json['commitment']! as String)
          : null,
      type: json['type'] as String?,
    );
  }

  final String address;
  final String? before;
  final String? until;
  final CommitmentLevel? commitment;
  final String? type;

  Map<String, Object?> toJson() => {
    'address': address,
    if (before != null) 'before': before,
    if (until != null) 'until': until,
    if (commitment != null) 'commitment': commitment!.toJson(),
    if (type != null) 'type': type,
  };
}

/// An enhanced transaction with parsed metadata.
class EnhancedTransaction {
  const EnhancedTransaction({
    required this.type,
    required this.source,
    required this.fee,
    required this.feePayer,
    required this.signature,
    required this.slot,
    required this.nativeTransfers,
    required this.tokenTransfers,
    required this.accountData,
    required this.instructions,
    required this.events,
    this.description,
    this.timestamp,
  });

  factory EnhancedTransaction.fromJson(Map<String, Object?> json) {
    return EnhancedTransaction(
      description: json['description'] as String?,
      type: json['type']! as String,
      source: json['source']! as String,
      fee: json['fee']! as int,
      feePayer: json['feePayer']! as int,
      signature: json['signature']! as String,
      slot: json['slot']! as int,
      timestamp: json['timestamp'] as int?,
      nativeTransfers: (json['nativeTransfers']! as List<Object?>)
          .map((e) => NativeTransfer.fromJson(e! as Map<String, Object?>))
          .toList(),
      tokenTransfers: (json['tokenTransfers']! as List<Object?>)
          .map((e) => TokenTransfer.fromJson(e! as Map<String, Object?>))
          .toList(),
      accountData: (json['accountData']! as List<Object?>)
          .map((e) => AccountData.fromJson(e! as Map<String, Object?>))
          .toList(),
      instructions: (json['instructions']! as List<Object?>)
          .map((e) => InnerInstruction.fromJson(e! as Map<String, Object?>))
          .toList(),
      events: json['events']! as Map<String, Object?>,
    );
  }

  final String? description;
  final String type;
  final String source;
  final int fee;
  final int feePayer;
  final String signature;
  final int slot;
  final int? timestamp;
  final List<NativeTransfer> nativeTransfers;
  final List<TokenTransfer> tokenTransfers;
  final List<AccountData> accountData;
  final List<InnerInstruction> instructions;
  final Map<String, Object?> events;

  Map<String, Object?> toJson() => {
    if (description != null) 'description': description,
    'type': type,
    'source': source,
    'fee': fee,
    'feePayer': feePayer,
    'signature': signature,
    'slot': slot,
    if (timestamp != null) 'timestamp': timestamp,
    'nativeTransfers': nativeTransfers.map((e) => e.toJson()).toList(),
    'tokenTransfers': tokenTransfers.map((e) => e.toJson()).toList(),
    'accountData': accountData.map((e) => e.toJson()).toList(),
    'instructions': instructions.map((e) => e.toJson()).toList(),
    'events': events,
  };
}

/// A native SOL transfer within a transaction.
class NativeTransfer {
  const NativeTransfer({
    required this.fromUserAccount,
    required this.toUserAccount,
    required this.amount,
  });

  factory NativeTransfer.fromJson(Map<String, Object?> json) {
    return NativeTransfer(
      fromUserAccount: json['fromUserAccount']! as String,
      toUserAccount: json['toUserAccount']! as String,
      amount: json['amount']! as int,
    );
  }

  final String fromUserAccount;
  final String toUserAccount;
  final int amount;

  Map<String, Object?> toJson() => {
    'fromUserAccount': fromUserAccount,
    'toUserAccount': toUserAccount,
    'amount': amount,
  };
}

/// A token transfer within a transaction.
class TokenTransfer {
  const TokenTransfer({
    required this.fromUserAccount,
    required this.toUserAccount,
    required this.fromTokenAccount,
    required this.toTokenAccount,
    required this.tokenAmount,
    required this.tokenStandard,
    this.mint,
  });

  factory TokenTransfer.fromJson(Map<String, Object?> json) {
    return TokenTransfer(
      fromUserAccount: json['fromUserAccount']! as String,
      toUserAccount: json['toUserAccount']! as String,
      fromTokenAccount: json['fromTokenAccount']! as String,
      toTokenAccount: json['toTokenAccount']! as String,
      tokenAmount: json['tokenAmount']! as int,
      mint: json['mint'] as String?,
      tokenStandard: json['tokenStandard']! as String,
    );
  }

  final String fromUserAccount;
  final String toUserAccount;
  final String fromTokenAccount;
  final String toTokenAccount;
  final int tokenAmount;
  final String? mint;
  final String tokenStandard;

  Map<String, Object?> toJson() => {
    'fromUserAccount': fromUserAccount,
    'toUserAccount': toUserAccount,
    'fromTokenAccount': fromTokenAccount,
    'toTokenAccount': toTokenAccount,
    'tokenAmount': tokenAmount,
    if (mint != null) 'mint': mint,
    'tokenStandard': tokenStandard,
  };
}

/// Account data changes within a transaction.
class AccountData {
  const AccountData({
    required this.account,
    required this.nativeBalanceChange,
    required this.tokenBalanceChanges,
  });

  factory AccountData.fromJson(Map<String, Object?> json) {
    return AccountData(
      account: json['account']! as String,
      nativeBalanceChange: json['nativeBalanceChange']! as Map<String, Object?>,
      tokenBalanceChanges: (json['tokenBalanceChanges']! as List<Object?>)
          .map((e) => TokenBalanceChange.fromJson(e! as Map<String, Object?>))
          .toList(),
    );
  }

  final String account;
  final Map<String, Object?> nativeBalanceChange;
  final List<TokenBalanceChange> tokenBalanceChanges;

  Map<String, Object?> toJson() => {
    'account': account,
    'nativeBalanceChange': nativeBalanceChange,
    'tokenBalanceChanges': tokenBalanceChanges.map((e) => e.toJson()).toList(),
  };
}

/// A token balance change within a transaction.
class TokenBalanceChange {
  const TokenBalanceChange({
    required this.mint,
    required this.rawTokenAmount,
    required this.decimals,
    required this.userAccount,
    required this.tokenAccount,
  });

  factory TokenBalanceChange.fromJson(Map<String, Object?> json) {
    return TokenBalanceChange(
      mint: json['mint']! as String,
      rawTokenAmount: json['rawTokenAmount']! as int,
      decimals: json['decimals']! as int,
      userAccount: json['userAccount']! as String,
      tokenAccount: json['tokenAccount']! as String,
    );
  }

  final String mint;
  final int rawTokenAmount;
  final int decimals;
  final String userAccount;
  final String tokenAccount;

  Map<String, Object?> toJson() => {
    'mint': mint,
    'rawTokenAmount': rawTokenAmount,
    'decimals': decimals,
    'userAccount': userAccount,
    'tokenAccount': tokenAccount,
  };
}

/// An inner instruction within a transaction.
class InnerInstruction {
  const InnerInstruction({
    required this.accounts,
    required this.data,
    required this.programId,
    this.innerInstructions,
  });

  factory InnerInstruction.fromJson(Map<String, Object?> json) {
    return InnerInstruction(
      accounts: json['accounts']! as List<Object?>,
      data: json['data']! as String,
      programId: json['programId']! as String,
      innerInstructions: json['innerInstructions'],
    );
  }

  final List<Object?> accounts;
  final String data;
  final String programId;
  final Object? innerInstructions;

  Map<String, Object?> toJson() => {
    'accounts': accounts,
    'data': data,
    'programId': programId,
    if (innerInstructions != null) 'innerInstructions': innerInstructions,
  };
}
