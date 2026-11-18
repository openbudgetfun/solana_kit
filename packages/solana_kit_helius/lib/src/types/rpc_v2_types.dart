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
  ///
  /// The endpoint returns two page shapes: with `withContext` the accounts
  /// and cursor sit at the top level of the result; without it the page
  /// array is nested under `value` and the cursor travels as `paginationKey`
  /// next to it. Both are accepted (upstream v3.4.0 #380).
  factory GetTokenAccountsByOwnerV2Response.fromJson(
    Map<String, Object?> json,
  ) {
    final wrapped = json['value'] is List<Object?>;
    final accountsJson =
        ((wrapped ? json['value'] : json['accounts']) ?? <Object?>[])
            as List<Object?>;
    final cursor =
        (wrapped ? json['paginationKey'] : json['cursor']) as String?;
    return GetTokenAccountsByOwnerV2Response(
      accounts: [
        for (final account in accountsJson)
          TokenAccountV2.fromJson(account! as Map<String, Object?>),
      ],
      cursor: cursor,
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
    this.transactionDetails,
    this.commitment,
    this.minContextSlot,
    this.encoding,
    this.maxSupportedTransactionVersion,
    this.limit,
    this.paginationToken,
    this.sortOrder,
    this.filters,
  });

  /// Builds a request from a JSON map.
  factory GetTransactionsForAddressRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetTransactionsForAddressRequest(
      address: r.requireString('address'),
      transactionDetails: r.optString('transactionDetails'),
      commitment: r.optEnum('commitment', CommitmentLevel.fromJson),
      minContextSlot: r.optInt('minContextSlot'),
      encoding: r.optString('encoding'),
      maxSupportedTransactionVersion: r.optInt(
        'maxSupportedTransactionVersion',
      ),
      limit: r.optInt('limit'),
      paginationToken: r.optString('paginationToken'),
      sortOrder: r.optString('sortOrder'),
      filters: r.optDecoded(
        'filters',
        GetTransactionsForAddressFilters.fromJson,
      ),
    );
  }

  /// The address whose transactions are being queried.
  final String address;

  /// Whether to return only signatures (`signatures`, the default) or full
  /// transactions (`full`).
  final String? transactionDetails;

  /// Optional commitment level for the query.
  final CommitmentLevel? commitment;

  /// Prevents accessing stale data by enforcing that the node has processed
  /// transactions up to this slot.
  final int? minContextSlot;

  /// Encoding used for each returned transaction.
  final String? encoding;

  /// The newest transaction version the caller wants to receive.
  final int? maxSupportedTransactionVersion;

  /// Optional maximum number of transactions to return.
  final int? limit;

  /// Cursor from a previous response.
  final String? paginationToken;

  /// Result ordering by slot and position within the block (`asc` / `desc`).
  final String? sortOrder;

  /// Optional server-side filters for status, token transfers, slots, block
  /// times, and signature ranges.
  final GetTransactionsForAddressFilters? filters;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
    'address': address,
    if (transactionDetails != null) 'transactionDetails': transactionDetails,
    if (commitment != null) 'commitment': commitment!.toJson(),
    if (minContextSlot != null) 'minContextSlot': minContextSlot,
    if (encoding != null) 'encoding': encoding,
    if (maxSupportedTransactionVersion != null)
      'maxSupportedTransactionVersion': maxSupportedTransactionVersion,
    if (limit != null) 'limit': limit,
    if (paginationToken != null) 'paginationToken': paginationToken,
    if (sortOrder != null) 'sortOrder': sortOrder,
    if (filters != null) 'filters': filters!.toJson(),
  };
}

/// Server-side filters for `getTransactionsForAddress`.
///
/// Every filter is optional; supplying more than one combines them with AND
/// semantics.
class GetTransactionsForAddressFilters {
  /// Creates filters.
  const GetTransactionsForAddressFilters({
    this.status,
    this.tokenAccounts,
    this.tokenTransfer,
    this.slot,
    this.blockTime,
    this.signature,
  });

  /// Builds filters from a JSON map.
  factory GetTransactionsForAddressFilters.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    return GetTransactionsForAddressFilters(
      status: r.optString('status'),
      tokenAccounts: r.optString('tokenAccounts'),
      tokenTransfer: r.optDecoded(
        'tokenTransfer',
        TokenTransferFilter.fromJson,
      ),
      slot: r.optDecoded('slot', SlotFilter.fromJson),
      blockTime: r.optDecoded('blockTime', BlockTimeFilter.fromJson),
      signature: r.optDecoded('signature', SignatureFilter.fromJson),
    );
  }

  /// Filter by transaction status: `succeeded`, `failed`, or `any`.
  final String? status;

  /// How token accounts owned by the queried address are included.
  final String? tokenAccounts;

  /// Only transactions where the address sent or received a matching token
  /// transfer.
  final TokenTransferFilter? tokenTransfer;

  /// Filter by slot number.
  final SlotFilter? slot;

  /// Filter by block time (Unix seconds).
  final BlockTimeFilter? blockTime;

  /// Filter by signature (lexicographic comparison).
  final SignatureFilter? signature;

  /// Serializes these filters to a JSON map.
  Map<String, Object?> toJson() => {
    if (status != null) 'status': status,
    if (tokenAccounts != null) 'tokenAccounts': tokenAccounts,
    if (tokenTransfer != null) 'tokenTransfer': tokenTransfer!.toJson(),
    if (slot != null) 'slot': slot!.toJson(),
    if (blockTime != null) 'blockTime': blockTime!.toJson(),
    if (signature != null) 'signature': signature!.toJson(),
  };
}

/// A numeric range for transfer amounts.
class TransferComparisonFilter {
  /// Creates a comparison.
  const TransferComparisonFilter({this.gt, this.gte, this.lt, this.lte});

  /// Builds a comparison from a JSON map.
  factory TransferComparisonFilter.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return TransferComparisonFilter(
      gt: r.optInt('gt'),
      gte: r.optInt('gte'),
      lt: r.optInt('lt'),
      lte: r.optInt('lte'),
    );
  }

  /// Match values greater than this.
  final int? gt;

  /// Match values greater than or equal to this.
  final int? gte;

  /// Match values less than this.
  final int? lt;

  /// Match values less than or equal to this.
  final int? lte;

  /// Serializes this comparison to a JSON map.
  Map<String, Object?> toJson() => {
    if (gt != null) 'gt': gt,
    if (gte != null) 'gte': gte,
    if (lt != null) 'lt': lt,
    if (lte != null) 'lte': lte,
  };
}

/// Restricts results to token transfers matching the given fields.
class TokenTransferFilter {
  /// Creates a token-transfer filter.
  const TokenTransferFilter({
    this.withAddress,
    this.direction,
    this.mint,
    this.amount,
  });

  /// Builds a token-transfer filter from a JSON map.
  factory TokenTransferFilter.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return TokenTransferFilter(
      withAddress: r.optString('with'),
      direction: r.optString('direction'),
      mint: r.optString('mint'),
      amount: r.optDecoded('amount', TransferComparisonFilter.fromJson),
    );
  }

  /// Counterparty address on the other side of the transfer.
  final String? withAddress;

  /// Transfer direction relative to the queried address: `in`, `out`, or
  /// `any`.
  final String? direction;

  /// Token mint address.
  final String? mint;

  /// Raw on-chain amount range.
  final TransferComparisonFilter? amount;

  /// Serializes this filter to a JSON map.
  Map<String, Object?> toJson() => {
    if (withAddress != null) 'with': withAddress,
    if (direction != null) 'direction': direction,
    if (mint != null) 'mint': mint,
    if (amount != null) 'amount': amount!.toJson(),
  };
}

/// Slot equality and range comparison.
class SlotFilter {
  /// Creates a slot filter.
  const SlotFilter({this.eq, this.gte, this.gt, this.lte, this.lt});

  /// Builds a slot filter from a JSON map.
  factory SlotFilter.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return SlotFilter(
      eq: r.optInt('eq'),
      gte: r.optInt('gte'),
      gt: r.optInt('gt'),
      lte: r.optInt('lte'),
      lt: r.optInt('lt'),
    );
  }

  /// Equal to.
  final int? eq;

  /// Greater than or equal to.
  final int? gte;

  /// Greater than.
  final int? gt;

  /// Less than or equal to.
  final int? lte;

  /// Less than.
  final int? lt;

  /// Serializes this filter to a JSON map.
  Map<String, Object?> toJson() => {
    if (eq != null) 'eq': eq,
    if (gte != null) 'gte': gte,
    if (gt != null) 'gt': gt,
    if (lte != null) 'lte': lte,
    if (lt != null) 'lt': lt,
  };
}

/// Block-time equality and range comparison.
class BlockTimeFilter {
  /// Creates a block-time filter.
  const BlockTimeFilter({this.eq, this.gte, this.gt, this.lte, this.lt});

  /// Builds a block-time filter from a JSON map.
  factory BlockTimeFilter.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return BlockTimeFilter(
      eq: r.optInt('eq'),
      gte: r.optInt('gte'),
      gt: r.optInt('gt'),
      lte: r.optInt('lte'),
      lt: r.optInt('lt'),
    );
  }

  /// Equal to.
  final int? eq;

  /// Greater than or equal to.
  final int? gte;

  /// Greater than.
  final int? gt;

  /// Less than or equal to.
  final int? lte;

  /// Less than.
  final int? lt;

  /// Serializes this filter to a JSON map.
  Map<String, Object?> toJson() => {
    if (eq != null) 'eq': eq,
    if (gte != null) 'gte': gte,
    if (gt != null) 'gt': gt,
    if (lte != null) 'lte': lte,
    if (lt != null) 'lt': lt,
  };
}

/// Signature (lexicographic) comparison.
class SignatureFilter {
  /// Creates a signature filter.
  const SignatureFilter({this.gte, this.gt, this.lte, this.lt});

  /// Builds a signature filter from a JSON map.
  factory SignatureFilter.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return SignatureFilter(
      gte: r.optString('gte'),
      gt: r.optString('gt'),
      lte: r.optString('lte'),
      lt: r.optString('lt'),
    );
  }

  /// Greater than or equal to.
  final String? gte;

  /// Greater than.
  final String? gt;

  /// Less than or equal to.
  final String? lte;

  /// Less than.
  final String? lt;

  /// Serializes this filter to a JSON map.
  Map<String, Object?> toJson() => {
    if (gte != null) 'gte': gte,
    if (gt != null) 'gt': gt,
    if (lte != null) 'lte': lte,
    if (lt != null) 'lt': lt,
  };
}

/// Response containing transactions for an address.
class GetTransactionsForAddressResponse {
  /// Creates a response containing transactions for an address.
  const GetTransactionsForAddressResponse({
    required this.data,
    this.paginationToken,
  });

  /// Builds a response from a JSON map.
  ///
  /// The live endpoint returns `data` with a `paginationToken`; the legacy
  /// `transactions` key is also accepted so older fixtures keep parsing.
  factory GetTransactionsForAddressResponse.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    final entries =
        r.optList<Map<String, Object?>>('data') ??
        r.optList<Map<String, Object?>>('transactions') ??
        const [];

    return GetTransactionsForAddressResponse(
      data: entries.map(TransactionForAddressEntry.fromJson).toList(),
      paginationToken: r.optString('paginationToken'),
    );
  }

  /// The transaction entries returned for the queried address.
  ///
  /// Entries are [TransactionForAddress] for the default `signatures` detail
  /// level and [TransactionForAddressFull] for `full`.
  final List<TransactionForAddressEntry> data;

  /// Cursor for the next page, or `null` when there are no more results.
  final String? paginationToken;

  /// Signature-level entries, for callers using the default detail level.
  ///
  /// Full transaction entries are only available through [data].
  List<TransactionForAddress> get transactions =>
      data.whereType<TransactionForAddress>().toList();

  /// Serializes this response to a JSON map.
  Map<String, Object?> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    if (paginationToken != null) 'paginationToken': paginationToken,
  };
}

/// A single entry in a `getTransactionsForAddress` response.
sealed class TransactionForAddressEntry {
  /// Creates an entry.
  const TransactionForAddressEntry();

  /// Builds the entry matching the shape present in [json].
  factory TransactionForAddressEntry.fromJson(Map<String, Object?> json) {
    if (json.containsKey('transaction')) {
      return TransactionForAddressFull.fromJson(json);
    }

    return TransactionForAddress.fromJson(json);
  }

  /// Serializes this entry to a JSON map.
  Map<String, Object?> toJson();
}

/// A transaction signature associated with an address.
class TransactionForAddress extends TransactionForAddressEntry {
  /// Creates a transaction summary for an address.
  const TransactionForAddress({
    required this.signature,
    required this.slot,
    this.transactionIndex,
    this.blockTime,
    this.err,
    this.memo,
    this.confirmationStatus,
  });

  /// Builds a transaction summary from a JSON map.
  factory TransactionForAddress.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return TransactionForAddress(
      signature: r.requireString('signature'),
      slot: r.requireInt('slot'),
      transactionIndex: r.optInt('transactionIndex'),
      blockTime: r.optInt('blockTime'),
      err: r.raw('err'),
      memo: r.optString('memo'),
      confirmationStatus: r.optString('confirmationStatus'),
    );
  }

  /// The transaction signature.
  final String signature;

  /// The slot in which the transaction was included.
  final int slot;

  /// The transaction's position within its slot.
  final int? transactionIndex;

  /// The block time of the transaction, if available.
  final int? blockTime;

  /// The transaction error, if any.
  final Object? err;

  /// The transaction memo, if present.
  final String? memo;

  /// Confirmation status reported by the node.
  final String? confirmationStatus;

  @override
  Map<String, Object?> toJson() => {
    'signature': signature,
    'slot': slot,
    if (transactionIndex != null) 'transactionIndex': transactionIndex,
    if (blockTime != null) 'blockTime': blockTime,
    if (err != null) 'err': err,
    if (memo != null) 'memo': memo,
    if (confirmationStatus != null) 'confirmationStatus': confirmationStatus,
  };
}

/// A full transaction returned with `transactionDetails: full`.
class TransactionForAddressFull extends TransactionForAddressEntry {
  /// Creates a full transaction entry.
  const TransactionForAddressFull({
    required this.slot,
    required this.transactionIndex,
    required this.transaction,
    this.meta,
    this.blockTime,
  });

  /// Builds a full transaction entry from a JSON map.
  factory TransactionForAddressFull.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return TransactionForAddressFull(
      slot: r.requireInt('slot'),
      transactionIndex: r.requireInt('transactionIndex'),
      transaction: r.requireMap('transaction'),
      meta: r.optMap('meta'),
      blockTime: r.optInt('blockTime'),
    );
  }

  /// The slot in which the transaction was included.
  final int slot;

  /// The transaction's position within its slot.
  final int transactionIndex;

  /// The encoded transaction.
  final Map<String, Object?> transaction;

  /// Transaction metadata, when available.
  final Map<String, Object?>? meta;

  /// The block time of the transaction, if available.
  final int? blockTime;

  @override
  Map<String, Object?> toJson() => {
    'slot': slot,
    'transactionIndex': transactionIndex,
    'transaction': transaction,
    if (meta != null) 'meta': meta,
    if (blockTime != null) 'blockTime': blockTime,
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

/// Position in history for the historical account methods (upstream beta,
/// mainnet only from slot 444959999 onward).
///
/// An absent query reads the latest indexed slot, a [slot]-only query reads
/// the end of that slot, and a [slot] plus [transactionIndex] query reads
/// the state right after that transaction within the slot.
class HistoricalAccountQuery {
  /// Creates a historical account query.
  const HistoricalAccountQuery({this.slot, this.transactionIndex});

  /// Builds a query from a JSON map.
  factory HistoricalAccountQuery.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return HistoricalAccountQuery(
      slot: r.optInt('slot'),
      transactionIndex: r.optInt('transactionIndex'),
    );
  }

  /// The slot to read, or the latest indexed slot when absent.
  final int? slot;

  /// The transaction within [slot] whose immediate aftermath is read.
  final int? transactionIndex;

  /// Serializes this query to a JSON map.
  Map<String, Object?> toJson() => {
    if (slot != null) 'slot': slot,
    if (transactionIndex != null) 'transactionIndex': transactionIndex,
  };
}

/// Configuration for [GetHistoricalAccountInfoRequest] and
/// [GetHistoricalTokenAccountsByOwnerRequest].
class GetHistoricalAccountInfoConfig {
  /// Creates a historical account config.
  const GetHistoricalAccountInfoConfig({
    this.encoding,
    this.dataSliceOffset,
    this.dataSliceLength,
    this.commitment,
    this.minContextSlot,
  });

  /// Builds a config from a JSON map.
  factory GetHistoricalAccountInfoConfig.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    final dataSlice = r.optMap('dataSlice');
    return GetHistoricalAccountInfoConfig(
      encoding: r.optString('encoding'),
      dataSliceOffset: dataSlice?['offset'] as int?,
      dataSliceLength: dataSlice?['length'] as int?,
      commitment: r.optString('commitment'),
      minContextSlot: r.optInt('minContextSlot'),
    );
  }

  /// Encoding for the returned account data: `base64` (default),
  /// `base64+zstd`, or `jsonParsed`. `base58` and `processed` are not
  /// supported.
  final String? encoding;

  /// Offset of the requested data slice.
  final int? dataSliceOffset;

  /// Length of the requested data slice.
  ///
  /// A slice is rejected alongside `jsonParsed`, matching the account data
  /// contract the slice belongs to.
  final int? dataSliceLength;

  /// Commitment for the read: `finalized` or `confirmed`.
  final String? commitment;

  /// Minimum ledger slot the read may be served from.
  final int? minContextSlot;

  /// Serializes this config to a JSON map.
  Map<String, Object?> toJson() => {
    if (encoding != null) 'encoding': encoding,
    if (dataSliceOffset != null || dataSliceLength != null)
      'dataSlice': {
        if (dataSliceOffset != null) 'offset': dataSliceOffset,
        if (dataSliceLength != null) 'length': dataSliceLength,
      },
    if (commitment != null) 'commitment': commitment,
    if (minContextSlot != null) 'minContextSlot': minContextSlot,
  };
}

/// An account as it was at the requested historical position.
///
/// With `jsonParsed`, accounts that cannot be parsed fall back to the encoded
/// `[data, 'base64']` form, so [data] can be either a two-element list or a
/// parsed object; it is kept raw, mirroring upstream's open `parsed` shape.
class HistoricalAccount {
  /// Creates a historical account.
  const HistoricalAccount({
    required this.lamports,
    required this.owner,
    required this.data,
    required this.executable,
    required this.rentEpoch,
    required this.space,
    required this.lastUpdatedSlot,
    required this.lastUpdatedTransactionIndex,
  });

  /// Builds a historical account from a JSON map.
  factory HistoricalAccount.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    final lastUpdated = JsonReader(r.requireMap('lastUpdatedAt'));
    return HistoricalAccount(
      lamports: r.optInt('lamports') ?? 0,
      owner: r.requireString('owner'),
      data: switch (json['data']) {
        final Map<String, Object?> parsed => parsed,
        final List<Object?> encoded => encoded,
        final other => throw FormatException(
          'Historical account data must be a parsed object or an encoded '
          '[data, encoding] pair, got ${other.runtimeType}',
        ),
      },
      executable: r.optBool('executable') ?? false,
      rentEpoch: r.optInt('rentEpoch') ?? 0,
      space: r.optInt('space') ?? 0,
      lastUpdatedSlot: lastUpdated.requireInt('slot'),
      lastUpdatedTransactionIndex: lastUpdated.optInt('transactionIndex'),
    );
  }

  /// The account's lamport balance.
  final int lamports;

  /// The program that owns the account.
  final String owner;

  /// The raw account data: a parsed object, or an encoded `[data, encoding]`
  /// pair.
  final Object? data;

  /// Whether the account holds executable program code.
  final bool executable;

  /// The rent epoch of the account.
  final int rentEpoch;

  /// The account's data size.
  final int space;

  /// The slot of the write that produced this state.
  final int lastUpdatedSlot;

  /// The transaction index of the write that produced this state; null for
  /// writes outside a transaction, such as epoch rewards.
  final int? lastUpdatedTransactionIndex;

  /// Serializes this account to a JSON map.
  Map<String, Object?> toJson() => {
    'lamports': lamports,
    'owner': owner,
    'data': data,
    'executable': executable,
    'rentEpoch': rentEpoch,
    'space': space,
    'lastUpdatedAt': {
      'slot': lastUpdatedSlot,
      'transactionIndex': lastUpdatedTransactionIndex,
    },
  };
}

/// A token account entry in a `getHistoricalTokenAccountsByOwner` page.
class HistoricalKeyedAccount {
  /// Creates a historical keyed account entry.
  const HistoricalKeyedAccount({required this.pubkey, required this.account});

  /// Builds an entry from a JSON map.
  factory HistoricalKeyedAccount.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return HistoricalKeyedAccount(
      pubkey: r.requireString('pubkey'),
      account: HistoricalAccount.fromJson(r.requireMap('account')),
    );
  }

  /// The public key of the token account.
  final String pubkey;

  /// The account as it was at the requested position.
  final HistoricalAccount account;

  /// Serializes this entry to a JSON map.
  Map<String, Object?> toJson() => {
    'pubkey': pubkey,
    'account': account.toJson(),
  };
}

/// Request for `getHistoricalAccountInfo`.
class GetHistoricalAccountInfoRequest {
  /// Creates a historical account info request.
  const GetHistoricalAccountInfoRequest({
    required this.address,
    this.query,
    this.config,
  });

  /// Builds a request from a JSON map.
  factory GetHistoricalAccountInfoRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return GetHistoricalAccountInfoRequest(
      address: r.requireString('address'),
      query: r.optDecoded(
        'query',
        HistoricalAccountQuery.fromJson,
      ),
      config: r.optDecoded(
        'config',
        GetHistoricalAccountInfoConfig.fromJson,
      ),
    );
  }

  /// The account address to read.
  final String address;

  /// The historical position to read; absent reads the latest indexed slot.
  final HistoricalAccountQuery? query;

  /// Encoding, slice, and commitment options.
  final GetHistoricalAccountInfoConfig? config;

  /// Serializes this request to the JSON-RPC params array.
  ///
  /// An omitted query or config is sent as `{}`: the server rejects a `null`
  /// slot, so the empty object stands for "latest indexed slot".
  List<Object?> toJson() => [
    address,
    query?.toJson() ?? const <String, Object?>{},
    config?.toJson() ?? const <String, Object?>{},
  ];
}

/// Response for `getHistoricalAccountInfo`.
class GetHistoricalAccountInfoResponse {
  /// Creates a historical account info response.
  const GetHistoricalAccountInfoResponse({required this.slot, this.value});

  /// Builds a response from a JSON map.
  factory GetHistoricalAccountInfoResponse.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    final context = JsonReader(r.requireMap('context'));
    final value = r.optMap('value');
    return GetHistoricalAccountInfoResponse(
      slot: context.requireInt('slot'),
      value: value == null ? null : HistoricalAccount.fromJson(value),
    );
  }

  /// The latest slot Helius had indexed when the read was served — not the
  /// slot that was queried.
  final int slot;

  /// The account at the requested position, or null when it did not exist
  /// there (not created yet, or closed). Absence is not an error.
  final HistoricalAccount? value;

  /// Serializes this response to a JSON map.
  Map<String, Object?> toJson() => {
    'context': {'slot': slot},
    'value': value?.toJson(),
  };
}

/// Request for `getHistoricalTokenAccountsByOwner`.
class GetHistoricalTokenAccountsByOwnerRequest {
  /// Creates a historical token accounts by owner request.
  const GetHistoricalTokenAccountsByOwnerRequest({
    required this.ownerAddress,
    this.query,
    this.mint,
    this.programId,
    this.encoding,
    this.dataSliceOffset,
    this.dataSliceLength,
    this.commitment,
    this.minContextSlot,
    this.limit,
    this.paginationKey,
  });

  /// Builds a request from a JSON map.
  factory GetHistoricalTokenAccountsByOwnerRequest.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    final query = r.optDecoded('query', HistoricalAccountQuery.fromJson);
    final config = r.optMap('config');
    final dataSlice = config?['dataSlice'] as Map<String, Object?>?;
    return GetHistoricalTokenAccountsByOwnerRequest(
      ownerAddress: r.requireString('ownerAddress'),
      query: query,
      mint: config?['mint'] as String?,
      programId: config?['programId'] as String?,
      encoding: config?['encoding'] as String?,
      dataSliceOffset: dataSlice?['offset'] as int?,
      dataSliceLength: dataSlice?['length'] as int?,
      commitment: config?['commitment'] as String?,
      minContextSlot: config?['minContextSlot'] as int?,
      limit: config?['limit'] as int?,
      paginationKey: config?['paginationKey'] as String?,
    );
  }

  /// The owner address whose token accounts are being queried.
  final String ownerAddress;

  /// The historical position to read; absent reads the latest indexed slot.
  final HistoricalAccountQuery? query;

  /// Optional mint address to filter token accounts. At most one of [mint]
  /// and [programId] may be set.
  final String? mint;

  /// Optional token program id to filter token accounts. At most one of
  /// [mint] and [programId] may be set.
  final String? programId;

  /// Optional encoding for the returned account data.
  final String? encoding;

  /// Offset of the requested data slice.
  final int? dataSliceOffset;

  /// Length of the requested data slice.
  final int? dataSliceLength;

  /// Commitment for the read: `finalized` or `confirmed`.
  final String? commitment;

  /// Minimum ledger slot the read may be served from.
  final int? minContextSlot;

  /// Page size, 1–25,000; the server defaults to 25,000.
  final int? limit;

  /// Cursor used to fetch the next page of results.
  final String? paginationKey;

  /// Serializes this request to the JSON-RPC params array.
  ///
  /// An omitted query or config is sent as `{}`: the server rejects a `null`
  /// slot, so the empty object stands for "latest indexed slot".
  List<Object?> toJson() => [
    ownerAddress,
    query?.toJson() ?? const <String, Object?>{},
    {
      if (mint != null) 'mint': mint,
      if (programId != null) 'programId': programId,
      if (encoding != null) 'encoding': encoding,
      if (dataSliceOffset != null || dataSliceLength != null)
        'dataSlice': {
          if (dataSliceOffset != null) 'offset': dataSliceOffset,
          if (dataSliceLength != null) 'length': dataSliceLength,
        },
      if (commitment != null) 'commitment': commitment,
      if (minContextSlot != null) 'minContextSlot': minContextSlot,
      if (limit != null) 'limit': limit,
      if (paginationKey != null) 'paginationKey': paginationKey,
    },
  ];
}

/// Response for `getHistoricalTokenAccountsByOwner`.
class GetHistoricalTokenAccountsByOwnerResponse {
  /// Creates a historical token accounts by owner response.
  const GetHistoricalTokenAccountsByOwnerResponse({
    required this.slot,
    required this.accounts,
    this.paginationKey,
  });

  /// Builds a response from a JSON map.
  factory GetHistoricalTokenAccountsByOwnerResponse.fromJson(
    Map<String, Object?> json,
  ) {
    final r = JsonReader(json);
    final context = JsonReader(r.requireMap('context'));
    final value = JsonReader(r.requireMap('value'));
    return GetHistoricalTokenAccountsByOwnerResponse(
      slot: context.requireInt('slot'),
      accounts:
          value.optMappedList(
            'accounts',
            (entry) =>
                HistoricalKeyedAccount.fromJson(entry! as Map<String, Object?>),
          ) ??
          const <HistoricalKeyedAccount>[],
      paginationKey: value.optString('paginationKey'),
    );
  }

  /// The latest slot Helius had indexed when the read was served — not the
  /// slot that was queried.
  final int slot;

  /// The token accounts on this page.
  final List<HistoricalKeyedAccount> accounts;

  /// Cursor for the next page; null when the scan reached the end.
  ///
  /// A short or empty page can still carry a cursor — each call scans at most
  /// 25,000 accounts — so stop only when this is null, and pin the query's
  /// slot across pages so every page reads the same state.
  final String? paginationKey;

  /// Serializes this response to a JSON map.
  Map<String, Object?> toJson() => {
    'context': {'slot': slot},
    'value': {
      'accounts': accounts.map((e) => e.toJson()).toList(),
      'paginationKey': paginationKey,
    },
  };
}
