// ignore_for_file: public_member_api_docs
import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:solana_kit_helius/src/types/enums.dart';

/// Request to get transactions by their signatures.
class GetTransactionsRequest {
  const GetTransactionsRequest({required this.transactions});

  factory GetTransactionsRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetTransactionsRequest(
      transactions: r.requireList<String>('transactions'),
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
    final r = JsonReader(json);
    return GetTransactionsByAddressRequest(
      address: r.requireString('address'),
      before: r.optString('before'),
      until: r.optString('until'),
      commitment: r.optEnum('commitment', CommitmentLevel.fromJson),
      type: r.optString('type'),
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
    final r = JsonReader(json);
    return EnhancedTransaction(
      description: r.optString('description'),
      type: r.requireString('type'),
      source: r.requireString('source'),
      fee: r.requireInt('fee'),
      feePayer: r.requireInt('feePayer'),
      signature: r.requireString('signature'),
      slot: r.requireInt('slot'),
      timestamp: r.optInt('timestamp'),
      nativeTransfers: r.requireDecodedList(
        'nativeTransfers',
        NativeTransfer.fromJson,
      ),
      tokenTransfers: r.requireDecodedList(
        'tokenTransfers',
        TokenTransfer.fromJson,
      ),
      accountData: r.requireDecodedList(
        'accountData',
        AccountData.fromJson,
      ),
      instructions: r.requireDecodedList(
        'instructions',
        InnerInstruction.fromJson,
      ),
      events: r.requireMap('events'),
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
    final r = JsonReader(json);
    return NativeTransfer(
      fromUserAccount: r.requireString('fromUserAccount'),
      toUserAccount: r.requireString('toUserAccount'),
      amount: r.requireInt('amount'),
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
    final r = JsonReader(json);
    return TokenTransfer(
      fromUserAccount: r.requireString('fromUserAccount'),
      toUserAccount: r.requireString('toUserAccount'),
      fromTokenAccount: r.requireString('fromTokenAccount'),
      toTokenAccount: r.requireString('toTokenAccount'),
      tokenAmount: r.requireInt('tokenAmount'),
      mint: r.optString('mint'),
      tokenStandard: r.requireString('tokenStandard'),
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
    final r = JsonReader(json);
    return AccountData(
      account: r.requireString('account'),
      nativeBalanceChange: r.requireMap('nativeBalanceChange'),
      tokenBalanceChanges: r.requireDecodedList(
        'tokenBalanceChanges',
        TokenBalanceChange.fromJson,
      ),
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
    final r = JsonReader(json);
    return TokenBalanceChange(
      mint: r.requireString('mint'),
      rawTokenAmount: r.requireInt('rawTokenAmount'),
      decimals: r.requireInt('decimals'),
      userAccount: r.requireString('userAccount'),
      tokenAccount: r.requireString('tokenAccount'),
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
    final r = JsonReader(json);
    return InnerInstruction(
      accounts: r.requireList<Object?>('accounts'),
      data: r.requireString('data'),
      programId: r.requireString('programId'),
      innerInstructions: r.raw('innerInstructions'),
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
