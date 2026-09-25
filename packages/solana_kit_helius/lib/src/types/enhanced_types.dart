import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:solana_kit_helius/src/types/enums.dart';

/// Request to get transactions by their signatures.
class GetTransactionsRequest {
  /// Creates a get-transactions request.
  const GetTransactionsRequest({required this.transactions});

  /// Creates a [GetTransactionsRequest] from a JSON map.
  factory GetTransactionsRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetTransactionsRequest(
      transactions: r.requireList<String>('transactions'),
    );
  }

  /// Transaction signatures to fetch.
  final List<String> transactions;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {'transactions': transactions};
}

/// Request to get transactions by address.
class GetTransactionsByAddressRequest {
  /// Creates a get-transactions-by-address request.
  const GetTransactionsByAddressRequest({
    required this.address,
    this.before,
    this.until,
    this.commitment,
    this.type,
  });

  /// Creates a [GetTransactionsByAddressRequest] from a JSON map.
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

  /// Account address whose transactions are returned.
  final String address;

  /// Signature to paginate before.
  final String? before;

  /// Signature to paginate until.
  final String? until;

  /// Commitment level for the query.
  final CommitmentLevel? commitment;

  /// Optional transaction type filter.
  final String? type;

  /// Serializes this request to a JSON map.
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
  /// Creates an enhanced transaction.
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

  /// Creates an [EnhancedTransaction] from a JSON map.
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
      accountData: r.requireDecodedList('accountData', AccountData.fromJson),
      instructions: r.requireDecodedList(
        'instructions',
        InnerInstruction.fromJson,
      ),
      events: r.requireMap('events'),
    );
  }

  /// Human-readable description of the transaction.
  final String? description;

  /// Transaction type classification.
  final String type;

  /// Source that initiated the transaction.
  final String source;

  /// Transaction fee in lamports.
  final int fee;

  /// Fee payer index within [accountData].
  final int feePayer;

  /// Transaction signature.
  final String signature;

  /// Slot in which the transaction was confirmed.
  final int slot;

  /// Block timestamp of the transaction, in seconds.
  final int? timestamp;

  /// Native SOL transfers within the transaction.
  final List<NativeTransfer> nativeTransfers;

  /// Token transfers within the transaction.
  final List<TokenTransfer> tokenTransfers;

  /// Per-account balance changes within the transaction.
  final List<AccountData> accountData;

  /// Inner instructions of the transaction.
  final List<InnerInstruction> instructions;

  /// Parsed event metadata for the transaction.
  final Map<String, Object?> events;

  /// Serializes this transaction to a JSON map.
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
  /// Creates a native transfer.
  const NativeTransfer({
    required this.fromUserAccount,
    required this.toUserAccount,
    required this.amount,
  });

  /// Creates a [NativeTransfer] from a JSON map.
  factory NativeTransfer.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return NativeTransfer(
      fromUserAccount: r.requireString('fromUserAccount'),
      toUserAccount: r.requireString('toUserAccount'),
      amount: r.requireInt('amount'),
    );
  }

  /// Sender wallet address.
  final String fromUserAccount;

  /// Recipient wallet address.
  final String toUserAccount;

  /// Amount transferred in lamports.
  final int amount;

  /// Serializes this transfer to a JSON map.
  Map<String, Object?> toJson() => {
    'fromUserAccount': fromUserAccount,
    'toUserAccount': toUserAccount,
    'amount': amount,
  };
}

/// A token transfer within a transaction.
class TokenTransfer {
  /// Creates a token transfer.
  const TokenTransfer({
    required this.fromUserAccount,
    required this.toUserAccount,
    required this.fromTokenAccount,
    required this.toTokenAccount,
    required this.tokenAmount,
    required this.tokenStandard,
    this.mint,
  });

  /// Creates a [TokenTransfer] from a JSON map.
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

  /// Sender wallet address.
  final String fromUserAccount;

  /// Recipient wallet address.
  final String toUserAccount;

  /// Source token account address.
  final String fromTokenAccount;

  /// Destination token account address.
  final String toTokenAccount;

  /// Amount of tokens transferred, in base units.
  final int tokenAmount;

  /// Mint of the transferred token, when available.
  final String? mint;

  /// Token standard of the transferred asset.
  final String tokenStandard;

  /// Serializes this transfer to a JSON map.
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
  /// Creates account data.
  const AccountData({
    required this.account,
    required this.nativeBalanceChange,
    required this.tokenBalanceChanges,
  });

  /// Creates an [AccountData] from a JSON map.
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

  /// Account address whose data changed.
  final String account;

  /// Native SOL balance change for the account.
  final Map<String, Object?> nativeBalanceChange;

  /// Token balance changes for the account.
  final List<TokenBalanceChange> tokenBalanceChanges;

  /// Serializes this account data to a JSON map.
  Map<String, Object?> toJson() => {
    'account': account,
    'nativeBalanceChange': nativeBalanceChange,
    'tokenBalanceChanges': tokenBalanceChanges.map((e) => e.toJson()).toList(),
  };
}

/// A token balance change within a transaction.
class TokenBalanceChange {
  /// Creates a token balance change.
  const TokenBalanceChange({
    required this.mint,
    required this.rawTokenAmount,
    required this.decimals,
    required this.userAccount,
    required this.tokenAccount,
  });

  /// Creates a [TokenBalanceChange] from a JSON map.
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

  /// Mint of the token whose balance changed.
  final String mint;

  /// Raw token amount delta, in base units.
  final int rawTokenAmount;

  /// Decimals of the token mint.
  final int decimals;

  /// Owner wallet address of the token account.
  final String userAccount;

  /// Token account address whose balance changed.
  final String tokenAccount;

  /// Serializes this balance change to a JSON map.
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
  /// Creates an inner instruction.
  const InnerInstruction({
    required this.accounts,
    required this.data,
    required this.programId,
    this.innerInstructions,
  });

  /// Creates an [InnerInstruction] from a JSON map.
  factory InnerInstruction.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return InnerInstruction(
      accounts: r.requireList<Object?>('accounts'),
      data: r.requireString('data'),
      programId: r.requireString('programId'),
      innerInstructions: r.raw('innerInstructions'),
    );
  }

  /// Account indices referenced by the instruction.
  final List<Object?> accounts;

  /// Base58-encoded instruction data.
  final String data;

  /// Program identifier that executes the instruction.
  final String programId;

  /// Nested inner instructions, when present.
  final Object? innerInstructions;

  /// Serializes this instruction to a JSON map.
  Map<String, Object?> toJson() => {
    'accounts': accounts,
    'data': data,
    'programId': programId,
    if (innerInstructions != null) 'innerInstructions': innerInstructions,
  };
}
