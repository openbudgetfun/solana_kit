import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:solana_kit_helius/src/types/enums.dart';

/// Request to get program accounts with V2 pagination.
class GetProgramAccountsV2Request {
  /// Creates a V2 program accounts request.
  const GetProgramAccountsV2Request({
    required this.programAddress,
    this.filters,
    this.encoding,
    this.dataSlice,
    this.after,
    this.limit,
  });

  /// Builds a request from a JSON map.
  factory GetProgramAccountsV2Request.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetProgramAccountsV2Request(
      programAddress: r.requireString('programAddress'),
      filters: r.optList<Map<String, Object?>>('filters'),
      encoding: r.optString('encoding'),
      dataSlice: r.optInt('dataSlice'),
      after: r.optString('after'),
      limit: r.optInt('limit'),
    );
  }

  /// The program address whose accounts are being queried.
  final String programAddress;

  /// Optional filters applied to the returned accounts.
  final List<Map<String, Object?>>? filters;

  /// Optional encoding for the returned account data.
  final String? encoding;

  /// Optional data slice used to limit the returned account data range.
  final int? dataSlice;

  /// Optional cursor to paginate results after this account address.
  final String? after;

  /// Optional maximum number of accounts to return.
  final int? limit;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
    'programAddress': programAddress,
    if (filters != null) 'filters': filters,
    if (encoding != null) 'encoding': encoding,
    if (dataSlice != null) 'dataSlice': dataSlice,
    if (after != null) 'after': after,
    if (limit != null) 'limit': limit,
  };
}

/// Response containing program accounts with V2 pagination.
class GetProgramAccountsV2Response {
  /// Creates a V2 program accounts response.
  const GetProgramAccountsV2Response({required this.accounts, this.cursor});

  /// Builds a response from a JSON map.
  factory GetProgramAccountsV2Response.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetProgramAccountsV2Response(
      accounts: r.requireDecodedList('accounts', ProgramAccountV2.fromJson),
      cursor: r.optString('cursor'),
    );
  }

  /// The program accounts returned by the request.
  final List<ProgramAccountV2> accounts;

  /// Optional cursor used to fetch the next page of results.
  final String? cursor;

  /// Serializes this response to a JSON map.
  Map<String, Object?> toJson() => {
    'accounts': accounts.map((e) => e.toJson()).toList(),
    if (cursor != null) 'cursor': cursor,
  };
}

/// A program account returned by the V2 API.
class ProgramAccountV2 {
  /// Creates a V2 program account entry.
  const ProgramAccountV2({required this.pubkey, required this.account});

  /// Builds a program account entry from a JSON map.
  factory ProgramAccountV2.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return ProgramAccountV2(
      pubkey: r.requireString('pubkey'),
      account: r.requireMap('account'),
    );
  }

  /// The public key of the account.
  final String pubkey;

  /// The raw account data.
  final Map<String, Object?> account;

  /// Serializes this entry to a JSON map.
  Map<String, Object?> toJson() => {'pubkey': pubkey, 'account': account};
}

/// Request to get token accounts by owner with V2 pagination.
class GetTokenAccountsByOwnerV2Request {
  /// Creates a V2 token accounts by owner request.
  const GetTokenAccountsByOwnerV2Request({
    required this.ownerAddress,
    this.mint,
    this.programId,
    this.encoding,
    this.after,
    this.limit,
  });

  /// Builds a request from a JSON map.
  factory GetTokenAccountsByOwnerV2Request.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetTokenAccountsByOwnerV2Request(
      ownerAddress: r.requireString('ownerAddress'),
      mint: r.optString('mint'),
      programId: r.optString('programId'),
      encoding: r.optString('encoding'),
      after: r.optString('after'),
      limit: r.optInt('limit'),
    );
  }

  /// The owner address whose token accounts are being queried.
  final String ownerAddress;

  /// Optional mint address to filter token accounts.
  final String? mint;

  /// Optional program id to filter token accounts.
  final String? programId;

  /// Optional encoding for the returned account data.
  final String? encoding;

  /// Optional cursor to paginate results after this account address.
  final String? after;

  /// Optional maximum number of accounts to return.
  final int? limit;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
    'ownerAddress': ownerAddress,
    if (mint != null) 'mint': mint,
    if (programId != null) 'programId': programId,
    if (encoding != null) 'encoding': encoding,
    if (after != null) 'after': after,
    if (limit != null) 'limit': limit,
  };
}

/// Response containing token accounts with V2 pagination.
class GetTokenAccountsByOwnerV2Response {
  /// Creates a V2 token accounts by owner response.
  const GetTokenAccountsByOwnerV2Response({
    required this.accounts,
    this.cursor,
  });

  /// Builds a response from a JSON map.
  factory GetTokenAccountsByOwnerV2Response.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetTokenAccountsByOwnerV2Response(
      accounts: r.requireDecodedList('accounts', TokenAccountV2.fromJson),
      cursor: r.optString('cursor'),
    );
  }

  /// The token accounts returned by the request.
  final List<TokenAccountV2> accounts;

  /// Optional cursor used to fetch the next page of results.
  final String? cursor;

  /// Serializes this response to a JSON map.
  Map<String, Object?> toJson() => {
    'accounts': accounts.map((e) => e.toJson()).toList(),
    if (cursor != null) 'cursor': cursor,
  };
}

/// A token account returned by the V2 API.
class TokenAccountV2 {
  /// Creates a V2 token account entry.
  const TokenAccountV2({required this.pubkey, required this.account});

  /// Builds a token account entry from a JSON map.
  factory TokenAccountV2.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return TokenAccountV2(
      pubkey: r.requireString('pubkey'),
      account: r.requireMap('account'),
    );
  }

  /// The public key of the token account.
  final String pubkey;

  /// The raw account data.
  final Map<String, Object?> account;

  /// Serializes this entry to a JSON map.
  Map<String, Object?> toJson() => {'pubkey': pubkey, 'account': account};
}

/// Request to get transactions for an address with V2 pagination.
class GetTransactionsForAddressRequest {
  /// Creates a request to fetch transactions for an address.
  const GetTransactionsForAddressRequest({
    required this.address,
    this.before,
    this.until,
    this.limit,
    this.commitment,
  });

  /// Builds a request from a JSON map.
  factory GetTransactionsForAddressRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetTransactionsForAddressRequest(
      address: r.requireString('address'),
      before: r.optString('before'),
      until: r.optString('until'),
      limit: r.optInt('limit'),
      commitment: r.optEnum('commitment', CommitmentLevel.fromJson),
    );
  }

  /// The address whose transactions are being queried.
  final String address;

  /// Optional signature to paginate results before this transaction.
  final String? before;

  /// Optional signature to paginate results up to this transaction.
  final String? until;

  /// Optional maximum number of transactions to return.
  final int? limit;

  /// Optional commitment level for the query.
  final CommitmentLevel? commitment;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
    'address': address,
    if (before != null) 'before': before,
    if (until != null) 'until': until,
    if (limit != null) 'limit': limit,
    if (commitment != null) 'commitment': commitment!.toJson(),
  };
}

/// Response containing transactions for an address.
class GetTransactionsForAddressResponse {
  /// Creates a response containing transactions for an address.
  const GetTransactionsForAddressResponse({required this.transactions});

  /// Builds a response from a JSON map.
  factory GetTransactionsForAddressResponse.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetTransactionsForAddressResponse(
      transactions: r.requireDecodedList(
        'transactions',
        TransactionForAddress.fromJson,
      ),
    );
  }

  /// The transactions returned for the queried address.
  final List<TransactionForAddress> transactions;

  /// Serializes this response to a JSON map.
  Map<String, Object?> toJson() => {
    'transactions': transactions.map((e) => e.toJson()).toList(),
  };
}

/// A transaction associated with an address.
class TransactionForAddress {
  /// Creates a transaction summary for an address.
  const TransactionForAddress({
    required this.signature,
    required this.slot,
    this.blockTime,
    this.err,
    this.memo,
  });

  /// Builds a transaction summary from a JSON map.
  factory TransactionForAddress.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return TransactionForAddress(
      signature: r.requireString('signature'),
      slot: r.requireInt('slot'),
      blockTime: r.optInt('blockTime'),
      err: r.raw('err'),
      memo: r.optString('memo'),
    );
  }

  /// The transaction signature.
  final String signature;

  /// The slot in which the transaction was included.
  final int slot;

  /// The block time of the transaction, if available.
  final int? blockTime;

  /// The transaction error, if any.
  final Object? err;

  /// The transaction memo, if present.
  final String? memo;

  /// Serializes this transaction to a JSON map.
  Map<String, Object?> toJson() => {
    'signature': signature,
    'slot': slot,
    if (blockTime != null) 'blockTime': blockTime,
    if (err != null) 'err': err,
    if (memo != null) 'memo': memo,
  };
}

/// Request to get parsed token and native SOL transfers for an address.
class GetTransfersByAddressRequest {
  /// Creates a request to fetch parsed transfers for an address.
  const GetTransfersByAddressRequest({required this.address, this.config});

  /// The address whose transfers are being queried.
  final String address;

  /// Optional configuration for the transfer query.
  final GetTransfersByAddressConfig? config;

  /// Serializes this request to a JSON array payload.
  Object toJson() => [address, if (config != null) config!.toJson()];
}

/// Configuration for transfer queries.
class GetTransfersByAddressConfig {
  /// Creates a transfer query configuration.
  const GetTransfersByAddressConfig({
    this.withAddress,
    this.direction,
    this.mint,
    this.solMode,
    this.filters,
    this.limit,
    this.paginationToken,
    this.commitment,
    this.sortOrder,
  });

  /// Optional address to scope the transfer query.
  final String? withAddress;

  /// Optional transfer direction filter.
  final String? direction;

  /// Optional mint address filter.
  final String? mint;

  /// Optional SOL transfer mode.
  final String? solMode;

  /// Optional additional filters for the query.
  final Map<String, Object?>? filters;

  /// Optional maximum number of transfers to return.
  final int? limit;

  /// Optional pagination token for fetching the next page.
  final String? paginationToken;

  /// Optional commitment level for the query.
  final CommitmentLevel? commitment;

  /// Optional sort order for the returned transfers.
  final String? sortOrder;

  /// Serializes this configuration to a JSON map.
  Map<String, Object?> toJson() => {
    if (withAddress != null) 'with': withAddress,
    if (direction != null) 'direction': direction,
    if (mint != null) 'mint': mint,
    if (solMode != null) 'solMode': solMode,
    if (filters != null) 'filters': filters,
    if (limit != null) 'limit': limit,
    if (paginationToken != null) 'paginationToken': paginationToken,
    if (commitment != null) 'commitment': commitment!.toJson(),
    if (sortOrder != null) 'sortOrder': sortOrder,
  };
}

/// Response containing parsed transfer data.
class GetTransfersByAddressResponse {
  /// Creates a response containing parsed transfers.
  const GetTransfersByAddressResponse({
    required this.data,
    required this.paginationToken,
  });

  /// Builds a response from a JSON map.
  factory GetTransfersByAddressResponse.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetTransfersByAddressResponse(
      data: r.requireDecodedList('data', AddressTransfer.fromJson),
      paginationToken: r.optString('paginationToken'),
    );
  }

  /// The parsed transfers returned by the query.
  final List<AddressTransfer> data;

  /// Optional pagination token for fetching the next page.
  final String? paginationToken;

  /// Serializes this response to a JSON map.
  Map<String, Object?> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'paginationToken': paginationToken,
  };
}

/// Parsed token or native SOL transfer record.
class AddressTransfer {
  /// Creates a parsed transfer record.
  const AddressTransfer({
    required this.signature,
    required this.slot,
    required this.blockTime,
    required this.type,
    required this.fromUserAccount,
    required this.toUserAccount,
    required this.mint,
    required this.amount,
    required this.decimals,
    required this.uiAmount,
    required this.confirmationStatus,
    required this.transactionIdx,
    required this.instructionIdx,
    required this.innerInstructionIdx,
    this.fromTokenAccount,
    this.toTokenAccount,
    this.feeAmount,
    this.feeAccount,
    this.feeUiAmount,
  });

  /// Builds a transfer record from a JSON map.
  factory AddressTransfer.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return AddressTransfer(
      signature: r.requireString('signature'),
      slot: r.requireInt('slot'),
      blockTime: r.requireInt('blockTime'),
      type: r.requireString('type'),
      fromUserAccount: r.optString('fromUserAccount'),
      toUserAccount: r.optString('toUserAccount'),
      fromTokenAccount: r.optString('fromTokenAccount'),
      toTokenAccount: r.optString('toTokenAccount'),
      mint: r.requireString('mint'),
      amount: r.requireString('amount'),
      feeAmount: r.optString('feeAmount'),
      feeAccount: r.optString('feeAccount'),
      decimals: r.requireInt('decimals'),
      uiAmount: r.requireString('uiAmount'),
      feeUiAmount: r.optString('feeUiAmount'),
      confirmationStatus: r.requireString('confirmationStatus'),
      transactionIdx: r.requireInt('transactionIdx'),
      instructionIdx: r.requireInt('instructionIdx'),
      innerInstructionIdx: r.requireInt('innerInstructionIdx'),
    );
  }

  /// The signature of the transaction containing the transfer.
  final String signature;

  /// The slot in which the transfer transaction was included.
  final int slot;

  /// The block time of the transfer transaction.
  final int blockTime;

  /// The type of the parsed transfer.
  final String type;

  /// The user account the transfer was sent from, if available.
  final String? fromUserAccount;

  /// The user account the transfer was sent to, if available.
  final String? toUserAccount;

  /// The token account the transfer was sent from, if available.
  final String? fromTokenAccount;

  /// The token account the transfer was sent to, if available.
  final String? toTokenAccount;

  /// The mint address of the transferred token.
  final String mint;

  /// The raw transferred amount as a string.
  final String amount;

  /// The raw fee amount as a string, if applicable.
  final String? feeAmount;

  /// The account that paid the fee, if applicable.
  final String? feeAccount;

  /// The fee amount expressed in UI units, if applicable.
  final String? feeUiAmount;

  /// The number of decimals used by the token mint.
  final int decimals;

  /// The transferred amount expressed in UI units.
  final String uiAmount;

  /// The confirmation status of the transfer transaction.
  final String confirmationStatus;

  /// The index of the transaction within its block.
  final int transactionIdx;

  /// The index of the instruction within the transaction.
  final int instructionIdx;

  /// The index of the inner instruction, if applicable.
  final int innerInstructionIdx;

  /// Serializes this transfer record to a JSON map.
  Map<String, Object?> toJson() => {
    'signature': signature,
    'slot': slot,
    'blockTime': blockTime,
    'type': type,
    'fromUserAccount': fromUserAccount,
    'toUserAccount': toUserAccount,
    if (fromTokenAccount != null) 'fromTokenAccount': fromTokenAccount,
    if (toTokenAccount != null) 'toTokenAccount': toTokenAccount,
    'mint': mint,
    'amount': amount,
    if (feeAmount != null) 'feeAmount': feeAmount,
    if (feeAccount != null) 'feeAccount': feeAccount,
    'decimals': decimals,
    'uiAmount': uiAmount,
    if (feeUiAmount != null) 'feeUiAmount': feeUiAmount,
    'confirmationStatus': confirmationStatus,
    'transactionIdx': transactionIdx,
    'instructionIdx': instructionIdx,
    'innerInstructionIdx': innerInstructionIdx,
  };
}
