import 'package:solana_kit_helius/src/types/enhanced_types.dart';

/// Request to get identity information for a wallet address.
class GetIdentityRequest {
  const GetIdentityRequest({required this.address});

  factory GetIdentityRequest.fromJson(Map<String, Object?> json) {
    return GetIdentityRequest(address: json['address']! as String);
  }

  final String address;

  Map<String, Object?> toJson() => {'address': address};
}

/// Request to get identity information for multiple wallet addresses.
class GetBatchIdentityRequest {
  const GetBatchIdentityRequest({required this.addresses});

  factory GetBatchIdentityRequest.fromJson(Map<String, Object?> json) {
    return GetBatchIdentityRequest(
      addresses: (json['addresses']! as List<Object?>).cast<String>(),
    );
  }

  final List<String> addresses;

  Map<String, Object?> toJson() => {'addresses': addresses};
}

/// Request to get balances for a wallet address.
class GetBalancesRequest {
  const GetBalancesRequest({required this.address});

  factory GetBalancesRequest.fromJson(Map<String, Object?> json) {
    return GetBalancesRequest(address: json['address']! as String);
  }

  final String address;

  Map<String, Object?> toJson() => {'address': address};
}

/// Request to get transaction history for a wallet address.
class GetHistoryRequest {
  const GetHistoryRequest({
    required this.address,
    this.before,
    this.until,
    this.limit,
    this.type,
  });

  factory GetHistoryRequest.fromJson(Map<String, Object?> json) {
    return GetHistoryRequest(
      address: json['address']! as String,
      before: json['before'] as String?,
      until: json['until'] as String?,
      limit: json['limit'] as int?,
      type: json['type'] as String?,
    );
  }

  final String address;
  final String? before;
  final String? until;
  final int? limit;
  final String? type;

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
  const GetTransfersRequest({
    required this.address,
    this.before,
    this.until,
    this.limit,
  });

  factory GetTransfersRequest.fromJson(Map<String, Object?> json) {
    return GetTransfersRequest(
      address: json['address']! as String,
      before: json['before'] as String?,
      until: json['until'] as String?,
      limit: json['limit'] as int?,
    );
  }

  final String address;
  final String? before;
  final String? until;
  final int? limit;

  Map<String, Object?> toJson() => {
    'address': address,
    if (before != null) 'before': before,
    if (until != null) 'until': until,
    if (limit != null) 'limit': limit,
  };
}

/// Request to get the funded-by information for a wallet address.
class GetFundedByRequest {
  const GetFundedByRequest({required this.address});

  factory GetFundedByRequest.fromJson(Map<String, Object?> json) {
    return GetFundedByRequest(address: json['address']! as String);
  }

  final String address;

  Map<String, Object?> toJson() => {'address': address};
}

/// Identity information for a wallet address.
class Identity {
  const Identity({required this.socials, this.name, this.pfpUrl, this.domain});

  factory Identity.fromJson(Map<String, Object?> json) {
    return Identity(
      name: json['name'] as String?,
      pfpUrl: json['pfpUrl'] as String?,
      domain: json['domain'] as String?,
      socials: json['socials']! as Map<String, Object?>,
    );
  }

  final String? name;
  final String? pfpUrl;
  final String? domain;
  final Map<String, Object?> socials;

  Map<String, Object?> toJson() => {
    if (name != null) 'name': name,
    if (pfpUrl != null) 'pfpUrl': pfpUrl,
    if (domain != null) 'domain': domain,
    'socials': socials,
  };
}

/// Wallet balances including native SOL and token balances.
class WalletBalances {
  const WalletBalances({required this.nativeBalance, required this.tokens});

  factory WalletBalances.fromJson(Map<String, Object?> json) {
    return WalletBalances(
      nativeBalance: json['nativeBalance']! as int,
      tokens: (json['tokens']! as List<Object?>)
          .map((e) => WalletTokenBalance.fromJson(e! as Map<String, Object?>))
          .toList(),
    );
  }

  final int nativeBalance;
  final List<WalletTokenBalance> tokens;

  Map<String, Object?> toJson() => {
    'nativeBalance': nativeBalance,
    'tokens': tokens.map((e) => e.toJson()).toList(),
  };
}

/// A token balance within a wallet.
class WalletTokenBalance {
  const WalletTokenBalance({
    required this.mint,
    required this.amount,
    required this.decimals,
    this.tokenAccount,
  });

  factory WalletTokenBalance.fromJson(Map<String, Object?> json) {
    return WalletTokenBalance(
      mint: json['mint']! as String,
      amount: json['amount']! as int,
      decimals: json['decimals']! as int,
      tokenAccount: json['tokenAccount'] as String?,
    );
  }

  final String mint;
  final int amount;
  final int decimals;
  final String? tokenAccount;

  Map<String, Object?> toJson() => {
    'mint': mint,
    'amount': amount,
    'decimals': decimals,
    if (tokenAccount != null) 'tokenAccount': tokenAccount,
  };
}

/// Transaction history for a wallet.
class WalletHistory {
  const WalletHistory({required this.transactions});

  factory WalletHistory.fromJson(Map<String, Object?> json) {
    return WalletHistory(
      transactions: (json['transactions']! as List<Object?>)
          .map((e) => EnhancedTransaction.fromJson(e! as Map<String, Object?>))
          .toList(),
    );
  }

  final List<EnhancedTransaction> transactions;

  Map<String, Object?> toJson() => {
    'transactions': transactions.map((e) => e.toJson()).toList(),
  };
}

/// A wallet transfer record.
class WalletTransfer {
  const WalletTransfer({
    required this.signature,
    required this.from,
    required this.to,
    required this.amount,
    this.timestamp,
    this.mint,
  });

  factory WalletTransfer.fromJson(Map<String, Object?> json) {
    return WalletTransfer(
      signature: json['signature']! as String,
      timestamp: json['timestamp'] as int?,
      from: json['from']! as String,
      to: json['to']! as String,
      amount: json['amount']! as int,
      mint: json['mint'] as String?,
    );
  }

  final String signature;
  final int? timestamp;
  final String from;
  final String to;
  final int amount;
  final String? mint;

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
  const FundedByResult({required this.transactions});

  factory FundedByResult.fromJson(Map<String, Object?> json) {
    return FundedByResult(
      transactions: (json['transactions']! as List<Object?>)
          .map((e) => FundedByTransaction.fromJson(e! as Map<String, Object?>))
          .toList(),
    );
  }

  final List<FundedByTransaction> transactions;

  Map<String, Object?> toJson() => {
    'transactions': transactions.map((e) => e.toJson()).toList(),
  };
}

/// A funded-by transaction record.
class FundedByTransaction {
  const FundedByTransaction({
    required this.signature,
    required this.source,
    required this.amount,
    this.timestamp,
  });

  factory FundedByTransaction.fromJson(Map<String, Object?> json) {
    return FundedByTransaction(
      signature: json['signature']! as String,
      source: json['source']! as String,
      amount: json['amount']! as int,
      timestamp: json['timestamp'] as int?,
    );
  }

  final String signature;
  final String source;
  final int amount;
  final int? timestamp;

  Map<String, Object?> toJson() => {
    'signature': signature,
    'source': source,
    'amount': amount,
    if (timestamp != null) 'timestamp': timestamp,
  };
}
