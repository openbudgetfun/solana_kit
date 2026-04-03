// ignore_for_file: public_member_api_docs
import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:solana_kit_helius/src/types/enhanced_types.dart';

/// Request to get identity information for a wallet address.
class GetIdentityRequest {
  const GetIdentityRequest({required this.address});

  factory GetIdentityRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetIdentityRequest(address: r.requireString('address'));
  }

  final String address;

  Map<String, Object?> toJson() => {'address': address};
}

/// Request to get identity information for multiple wallet addresses.
class GetBatchIdentityRequest {
  const GetBatchIdentityRequest({required this.addresses});

  factory GetBatchIdentityRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetBatchIdentityRequest(
      addresses: r.requireList<String>('addresses'),
    );
  }

  final List<String> addresses;

  Map<String, Object?> toJson() => {'addresses': addresses};
}

/// Request to get balances for a wallet address.
class GetBalancesRequest {
  const GetBalancesRequest({required this.address});

  factory GetBalancesRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetBalancesRequest(address: r.requireString('address'));
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
    final r = JsonReader(json);
    return GetHistoryRequest(
      address: r.requireString('address'),
      before: r.optString('before'),
      until: r.optString('until'),
      limit: r.optInt('limit'),
      type: r.optString('type'),
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
    final r = JsonReader(json);
    return GetTransfersRequest(
      address: r.requireString('address'),
      before: r.optString('before'),
      until: r.optString('until'),
      limit: r.optInt('limit'),
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
    final r = JsonReader(json);
    return GetFundedByRequest(address: r.requireString('address'));
  }

  final String address;

  Map<String, Object?> toJson() => {'address': address};
}

/// Identity information for a wallet address.
class Identity {
  const Identity({required this.socials, this.name, this.pfpUrl, this.domain});

  factory Identity.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return Identity(
      name: r.optString('name'),
      pfpUrl: r.optString('pfpUrl'),
      domain: r.optString('domain'),
      socials: r.requireMap('socials'),
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
    final r = JsonReader(json);
    return WalletBalances(
      nativeBalance: r.requireInt('nativeBalance'),
      tokens: r.requireDecodedList(
        'tokens',
        WalletTokenBalance.fromJson,
      ),
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
    final r = JsonReader(json);
    return WalletTokenBalance(
      mint: r.requireString('mint'),
      amount: r.requireInt('amount'),
      decimals: r.requireInt('decimals'),
      tokenAccount: r.optString('tokenAccount'),
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
    final r = JsonReader(json);
    return WalletHistory(
      transactions: r.requireDecodedList(
        'transactions',
        EnhancedTransaction.fromJson,
      ),
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
    final r = JsonReader(json);
    return FundedByResult(
      transactions: r.requireDecodedList(
        'transactions',
        FundedByTransaction.fromJson,
      ),
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
    final r = JsonReader(json);
    return FundedByTransaction(
      signature: r.requireString('signature'),
      source: r.requireString('source'),
      amount: r.requireInt('amount'),
      timestamp: r.optInt('timestamp'),
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
