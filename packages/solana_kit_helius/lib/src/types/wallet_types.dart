import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:solana_kit_helius/src/types/enhanced_types.dart';

/// Request to get identity information for a wallet address.
class GetIdentityRequest {
  /// Creates a get-identity request.
  const GetIdentityRequest({required this.address});

  /// Creates a [GetIdentityRequest] from a JSON map.
  factory GetIdentityRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetIdentityRequest(address: r.requireString('address'));
  }

  /// Wallet address to look up.
  final String address;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {'address': address};
}

/// Request to get identity information for multiple wallet addresses.
class GetBatchIdentityRequest {
  /// Creates a get-batch-identity request.
  const GetBatchIdentityRequest({required this.addresses});

  /// Creates a [GetBatchIdentityRequest] from a JSON map.
  factory GetBatchIdentityRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetBatchIdentityRequest(
      addresses: r.requireList<String>('addresses'),
    );
  }

  /// Wallet addresses to look up.
  final List<String> addresses;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {'addresses': addresses};
}

/// Request to get balances for a wallet address.
class GetBalancesRequest {
  /// Creates a get-balances request.
  const GetBalancesRequest({required this.address});

  /// Creates a [GetBalancesRequest] from a JSON map.
  factory GetBalancesRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetBalancesRequest(address: r.requireString('address'));
  }

  /// Wallet address whose balances are returned.
  final String address;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {'address': address};
}

/// Request to get transaction history for a wallet address.
class GetHistoryRequest {
  /// Creates a get-history request.
  const GetHistoryRequest({
    required this.address,
    this.before,
    this.until,
    this.limit,
    this.type,
  });

  /// Creates a [GetHistoryRequest] from a JSON map.
  factory GetHistoryRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetHistoryRequest(
      address: r.requireString('address'),
      before: r.optString('before'),
      until: r.optString('until'),
      limit: r.optInt('limit'),
      type: r.optString('type'),
    );
  }

  /// Wallet address whose history is returned.
  final String address;

  /// Signature to paginate before.
  final String? before;

  /// Signature to paginate until.
  final String? until;

  /// Maximum number of transactions to return.
  final int? limit;

  /// Optional transaction type filter.
  final String? type;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
    'address': address,
    if (before != null) 'before': before,
    if (until != null) 'until': until,
    if (limit != null) 'limit': limit,
    if (type != null) 'type': type,
  };
}

/// Request to get transfers for a wallet address.
class GetTransfersRequest {
  /// Creates a get-transfers request.
  const GetTransfersRequest({
    required this.address,
    this.before,
    this.until,
    this.limit,
  });

  /// Creates a [GetTransfersRequest] from a JSON map.
  factory GetTransfersRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetTransfersRequest(
      address: r.requireString('address'),
      before: r.optString('before'),
      until: r.optString('until'),
      limit: r.optInt('limit'),
    );
  }

  /// Wallet address whose transfers are returned.
  final String address;

  /// Signature to paginate before.
  final String? before;

  /// Signature to paginate until.
  final String? until;

  /// Maximum number of transfers to return.
  final int? limit;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
    'address': address,
    if (before != null) 'before': before,
    if (until != null) 'until': until,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get the funded-by information for a wallet address.
class GetFundedByRequest {
  /// Creates a get-funded-by request.
  const GetFundedByRequest({required this.address});

  /// Creates a [GetFundedByRequest] from a JSON map.
  factory GetFundedByRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetFundedByRequest(address: r.requireString('address'));
  }

  /// Wallet address whose funders are returned.
  final String address;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {'address': address};
}

/// Identity information for a wallet address.
class Identity {
  /// Creates an identity.
  const Identity({required this.socials, this.name, this.pfpUrl, this.domain});

  /// Creates an [Identity] from a JSON map.
  factory Identity.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return Identity(
      name: r.optString('name'),
      pfpUrl: r.optString('pfpUrl'),
      domain: r.optString('domain'),
      socials: r.requireMap('socials'),
    );
  }

  /// Display name associated with the wallet.
  final String? name;

  /// Profile picture URL for the wallet.
  final String? pfpUrl;

  /// Domain name linked to the wallet.
  final String? domain;

  /// Social profiles linked to the wallet.
  final Map<String, Object?> socials;

  /// Serializes this identity to a JSON map.
  Map<String, Object?> toJson() => {
    if (name != null) 'name': name,
    if (pfpUrl != null) 'pfpUrl': pfpUrl,
    if (domain != null) 'domain': domain,
    'socials': socials,
  };
}

/// Wallet balances including native SOL and token balances.
class WalletBalances {
  /// Creates wallet balances.
  const WalletBalances({required this.nativeBalance, required this.tokens});

  /// Creates a [WalletBalances] from a JSON map.
  factory WalletBalances.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return WalletBalances(
      nativeBalance: r.requireInt('nativeBalance'),
      tokens: r.requireDecodedList('tokens', WalletTokenBalance.fromJson),
    );
  }

  /// Native SOL balance in lamports.
  final int nativeBalance;

  /// Token balances held by the wallet.
  final List<WalletTokenBalance> tokens;

  /// Serializes these balances to a JSON map.
  Map<String, Object?> toJson() => {
    'nativeBalance': nativeBalance,
    'tokens': tokens.map((e) => e.toJson()).toList(),
  };
}

/// A token balance within a wallet.
class WalletTokenBalance {
  /// Creates a wallet token balance.
  const WalletTokenBalance({
    required this.mint,
    required this.amount,
    required this.decimals,
    this.tokenAccount,
  });

  /// Creates a [WalletTokenBalance] from a JSON map.
  factory WalletTokenBalance.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return WalletTokenBalance(
      mint: r.requireString('mint'),
      amount: r.requireInt('amount'),
      decimals: r.requireInt('decimals'),
      tokenAccount: r.optString('tokenAccount'),
    );
  }

  /// Mint of the token.
  final String mint;

  /// Token amount in base units.
  final int amount;

  /// Decimals of the token mint.
  final int decimals;

  /// Token account address holding the balance.
  final String? tokenAccount;

  /// Serializes this token balance to a JSON map.
  Map<String, Object?> toJson() => {
    'mint': mint,
    'amount': amount,
    'decimals': decimals,
    if (tokenAccount != null) 'tokenAccount': tokenAccount,
  };
}

/// Transaction history for a wallet.
class WalletHistory {
  /// Creates wallet history.
  const WalletHistory({required this.transactions});

  /// Creates a [WalletHistory] from a JSON map.
  factory WalletHistory.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return WalletHistory(
      transactions: r.requireDecodedList(
        'transactions',
        EnhancedTransaction.fromJson,
      ),
    );
  }

  /// Enhanced transactions for the wallet.
  final List<EnhancedTransaction> transactions;

  /// Serializes this history to a JSON map.
  Map<String, Object?> toJson() => {
    'transactions': transactions.map((e) => e.toJson()).toList(),
  };
}

/// A wallet transfer record.
class WalletTransfer {
  /// Creates a wallet transfer.
  const WalletTransfer({
    required this.signature,
    required this.from,
    required this.to,
    required this.amount,
    this.timestamp,
    this.mint,
  });

  /// Creates a [WalletTransfer] from a JSON map.
  factory WalletTransfer.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return WalletTransfer(
      signature: r.requireString('signature'),
      timestamp: r.optInt('timestamp'),
      from: r.requireString('from'),
      to: r.requireString('to'),
      amount: r.requireInt('amount'),
      mint: r.optString('mint'),
    );
  }

  /// Transaction signature of the transfer.
  final String signature;

  /// Block timestamp of the transfer, in seconds.
  final int? timestamp;

  /// Sender wallet address.
  final String from;

  /// Recipient wallet address.
  final String to;

  /// Amount transferred in base units.
  final int amount;

  /// Mint of the transferred token, when applicable.
  final String? mint;

  /// Serializes this transfer to a JSON map.
  Map<String, Object?> toJson() => {
    'signature': signature,
    if (timestamp != null) 'timestamp': timestamp,
    'from': from,
    'to': to,
    'amount': amount,
    if (mint != null) 'mint': mint,
  };
}

/// Result containing funded-by transactions.
class FundedByResult {
  /// Creates a funded-by result.
  const FundedByResult({required this.transactions});

  /// Creates a [FundedByResult] from a JSON map.
  factory FundedByResult.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return FundedByResult(
      transactions: r.requireDecodedList(
        'transactions',
        FundedByTransaction.fromJson,
      ),
    );
  }

  /// Transactions that funded the wallet.
  final List<FundedByTransaction> transactions;

  /// Serializes this result to a JSON map.
  Map<String, Object?> toJson() => {
    'transactions': transactions.map((e) => e.toJson()).toList(),
  };
}

/// A funded-by transaction record.
class FundedByTransaction {
  /// Creates a funded-by transaction.
  const FundedByTransaction({
    required this.signature,
    required this.source,
    required this.amount,
    this.timestamp,
  });

  /// Creates a [FundedByTransaction] from a JSON map.
  factory FundedByTransaction.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return FundedByTransaction(
      signature: r.requireString('signature'),
      source: r.requireString('source'),
      amount: r.requireInt('amount'),
      timestamp: r.optInt('timestamp'),
    );
  }

  /// Transaction signature of the funding transaction.
  final String signature;

  /// Source that funded the wallet.
  final String source;

  /// Amount funded in lamports.
  final int amount;

  /// Block timestamp of the funding, in seconds.
  final int? timestamp;

  /// Serializes this transaction to a JSON map.
  Map<String, Object?> toJson() => {
    'signature': signature,
    'source': source,
    'amount': amount,
    if (timestamp != null) 'timestamp': timestamp,
  };
}
